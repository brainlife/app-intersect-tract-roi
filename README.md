[![Abcdspec-compliant](https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg)](https://github.com/soichih/abcd-spec)
[![Run on Brainlife.io](https://img.shields.io/badge/Brainlife-bl.app.282-blue.svg)](https://doi.org/10.25663/brainlife.app.282)

# app-intersect-tract-roi

<!-- brainlife-app:begin (generated from the App manifest; edit the manifest, not this block) -->

**Segments a whole-brain tractogram by including or excluding streamlines that reach selected ROIs, using MRtrix3 tckedit, and outputs the new tractogram and classification.**

For each line of roiNames, filters the whole-brain tractogram with tckedit -include or -exclude for the listed ROIs (endpoints only or anywhere along the streamline, optionally inverted), then merges the resulting tracts into one tractogram and a classification with one tract per line. ROIs must be in the same space as the tractogram.

Run it on brainlife.io: [https://doi.org/10.25663/brainlife.app.556](https://doi.org/10.25663/brainlife.app.556)

| Input | Datatype | Required | Description |
|---|---|---|---|
| `track` | `neuro/track/tck` | yes | The path to the track/tck datatype |
| `rois` | `neuro/rois` | yes | The path to the rois datatype. Must be in the same space as the tractogram. |
| `dwi` | `neuro/dwi` | yes | DWI image used only as the reference anatomy for saving the classification. |

| Output | Datatype | Description |
|---|---|---|
| `track` | `neuro/track/tck` | Tractogram (.tck) concatenating the ROI-filtered tracts. |
| `wmc` | `neuro/wmc` | The classification structure including a classification.mat structure that contains the streamline indices in the whole-brain tractogram. |
| `raw` | `raw` | Intermediate .tck files and track name lists. |

| Parameter | Type | Default | Description |
|---|---|---|---|
| `roiNames` | string |  | names of the rois to intersect. multiple rois can be used at one time to generate a single track, and multiple tracks can be generated at one time. groupings of rois go on a single line, multiple tracks goes on multiple lines. roi names come directly from input roi datatype, and text should match the text inbetween the .nii.gz and ROI entensions and prefixes. example: freesurfer-11121 freesurfer-11161 freesurfer-parietal_L freesurfer-11121 freesurfer_occipital_R |
| `intersect_type` | string |  | two types: 1) "include": include streamlines that have endpoints in rois 2) "exclude": include all other streamlines except those that end in rois one type per track. for example, for three tracks: include exclude include |
| `inverse` | boolean | `false` | If you want the inverse of the operation (i.e. all streamlines that don't end in a roi), set this to true. default = false |
| `endpoints_only` | boolean | `true` | If you want to only segment based on endpoints, set this to true. else, set to false. default = true |

Runtime: container `brainlife/mrtrix3:3.0_RC3`; 8 CPUs; 32 GB memory; 1.5 h walltime.

Please cite:
- Tournier J-D, Smith RE, Raffelt D, et al. MRtrix3: A fast, flexible and open software framework for medical image processing and visualisation. NeuroImage 202:116137 (2019).

<!-- brainlife-app:end -->

This app will intersect chosen tract with the selected ROI from either a freesurfer parcellation, atlas parcellation or uploaded ROI. ROIs will are transformed to vistasoft compatible format. You can specify the minimum distance between the ROI and tract to assign it to the intersected group (default 0.87). The output will be a new tract file that traverses through the selected ROI. App can work in two modes "and" selecting the fibers passing throught the ROI and "not" selecting only the fibers that are not passing through the ROI

### Authors
- Brad Caron (bacaron@iu.edu)
- Jan Kurzawski (jk7127@nyu.edu)

### Contributors
- Soichi Hayashi (hayashi@iu.edu)
- Franco Pestilli ([@francopestilli](https://github.com/francopestilli))

### Funding
[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-1636893](https://img.shields.io/badge/NSF_BCS-1636893-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1636893)

## Running the App 

### On Brainlife.io

You can submit this App online at [https://doi.org/10.25663/brainlife.app.282](https://doi.org/10.25663/brainlife.app.282) via the "Execute" tab.

### Running Locally (on your machine)

1. git clone this repo.
2. Inside the cloned directory, create `config.json` with something like the following content with paths to your input files.

```json
{
        "rois": "./input/rois/",
        "wma": "./input/wma/",
        "tractk/tck": "./input/tract/",
        "intersect_type": "and/not",     
        "minimum_distance": "0.87",      

}
```

### Sample Datasets

You can download sample datasets from Brainlife using [Brainlife CLI](https://github.com/brain-life/cli).

```
npm install -g brainlife
bl login
mkdir input
bl dataset download 5b96bc8b059cf900271924f4 && mv 5b96bc8b059cf900271924f4 input/rois
bl dataset download 5b96bc8d059cf900271924f5 && mv 5b96bc8d059cf900271924f5 input/wma
bl dataset download 5b96bc8d059cf900271924f5 && mv 5b96bc8d059cf900271924f5 input/tract

```


3. Launch the App by executing `main`

```bash
./main
```

## Output

The main outputs of this App is a 'wma' file containing selectect fibers accordingly to the and/not parameter

#### Product.json
The secondary output of this app is `product.json`. This file allows web interfaces, DB and API calls on the results of the processing. 

### Dependencies

This App requires the following libraries when run locally.

  - singularity: https://singularity.lbl.gov/
  - VISTASOFT: https://github.com/vistalab/vistasoft/
  - ENCODE: https://github.com/brain-life/encode
  - SPM 8 or 12: https://www.fil.ion.ucl.ac.uk/spm/software/spm8/
  - WMA: https://github.com/brain-life/wma
  - Freesurfer: https://hub.docker.com/r/brainlife/freesurfer/tags/6.0.0
  - mrtrix: https://hub.docker.com/r/brainlife/mrtrix_on_mcr/tags/1.0
  - jsonlab: https://github.com/fangq/jsonlab.git
