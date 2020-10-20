[![Abcdspec-compliant](https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg)](https://github.com/soichih/abcd-spec)
[![Run on Brainlife.io](https://img.shields.io/badge/Brainlife-bl.app.282-blue.svg)](https://doi.org/10.25663/brainlife.app.282)

# app-intersect-tract-roi
This app will intersect chosen tract with the selected ROI from either a freesurfer parcellation, atlas parcellation or uploaded ROI. ROIs will are transformed to vistasoft compatible format. You can specify the minimum distance between the ROI and tract to assign it to the intersected group (default 0.87). The output will be a new tract file that traverses through the selected ROI. App can work in two modes "and" selecting the fibers passing throught the ROI and "not" selecting only the fibers that are not passing through the ROI

### Authors
- Brad Caron (bacaron@iu.edu)
- Jan Kurzawski (jk7127@nyu.edu)

### Contributors
- Soichi Hayashi (hayashi@iu.edu)
- Franco Pestilli (franpest@indiana.edu)

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
