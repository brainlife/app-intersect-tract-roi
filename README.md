<h1 align="center">Segment tracts with ROIs</h1>

<p align="center">
  New tracts selected from a whole-brain tractogram, or from the tracts of a classification, by the streamlines that do or do not reach chosen ROIs.
</p>

<p align="center">
  <a href="https://github.com/brainlife/abcd-spec"><img src="https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg" alt="ABCD Spec v1.1"></a>
  <a href="https://doi.org/10.25663/brainlife.app.556"><img src="https://img.shields.io/badge/Brainlife-brainlife.app.556-blue.svg" alt="Run on brainlife.io"></a>
  <a href="https://github.com/brainlife/app-intersect-tract-roi/blob/master/LICENSE"><img src="https://img.shields.io/badge/License-MIT-lightgrey.svg" alt="MIT license"></a>
</p>

> **This branch, `wholebrain-v1.0`, is the brainlife.io App Segment Wholebrain Tractogram with ROIs** ([doi:10.25663/brainlife.app.556](https://doi.org/10.25663/brainlife.app.556)). The other Apps in this repository are listed under **Versions on brainlife.io** below.

## At a glance

<!-- brainlife-app:begin (generated from the App manifest; edit the manifest, not this block) -->

> **Segments a whole-brain tractogram by including or excluding streamlines that reach selected ROIs, using MRtrix3 tckedit, and outputs the new tractogram and classification.**

For each line of roiNames, filters the whole-brain tractogram with tckedit -include or -exclude for the listed ROIs (endpoints only or anywhere along the streamline, optionally inverted), then merges the resulting tracts into one tractogram and a classification with one tract per line. ROIs must be in the same space as the tractogram.

| | |
|---|---|
| **Inputs** | `neuro/track/tck` · `neuro/rois` · `neuro/dwi` |
| **Outputs** | `neuro/track/tck` · `neuro/wmc` · `raw` |
| **Container** | `brainlife/mrtrix3:3.0_RC3` |
| **Resources** | 8 CPUs · 32 GB memory · 1.5 h walltime |
| **Run it** | [doi.org/10.25663/brainlife.app.556](https://doi.org/10.25663/brainlife.app.556) |

#### Inputs

| Input | Datatype | Required | Description |
|---|---|---|---|
| `track` | `neuro/track/tck` | yes | The path to the track/tck datatype |
| `rois` | `neuro/rois` | yes | The path to the rois datatype. Must be in the same space as the tractogram. |
| `dwi` | `neuro/dwi` | yes | DWI image used only as the reference anatomy for saving the classification. |

#### Outputs

| Output | Datatype | Description |
|---|---|---|
| `track` | `neuro/track/tck` | Tractogram (.tck) concatenating the ROI-filtered tracts. |
| `wmc` | `neuro/wmc` | The classification structure including a classification.mat structure that contains the streamline indices in the whole-brain tractogram. |
| `raw` | `raw` | Intermediate .tck files and track name lists. |

<details>
<summary><b>Parameters</b> (4)</summary>

| Parameter | Type | Default | Description |
|---|---|---|---|
| `roiNames` | string |  | names of the rois to intersect. multiple rois can be used at one time to generate a single track, and multiple tracks can be generated at one time. groupings of rois go on a single line, multiple tracks goes on multiple lines. roi names come directly from input roi datatype, and text should match the text inbetween the .nii.gz and ROI extensions and prefixes. example: freesurfer-11121 freesurfer-11161 freesurfer-parietal_L freesurfer-11121 freesurfer_occipital_R |
| `intersect_type` | string |  | two types: 1) "include": include streamlines that have endpoints in rois 2) "exclude": include all other streamlines except those that end in rois one type per track. for example, for three tracks: include exclude include |
| `inverse` | boolean | `false` | If you want the inverse of the operation (i.e. all streamlines that don't end in a roi), set this to true. default = false |
| `endpoints_only` | boolean | `true` | If you want to only segment based on endpoints, set this to true. else, set to false. default = true |

</details>

<!-- brainlife-app:end -->

## Versions on brainlife.io

Each App is built from its own branch of this repository.

| App | Starts from | Branch | Run it | Status |
|---|---|---|---|---|
| **Segment Wholebrain Tractogram with ROIs** (this branch) | a whole-brain tractogram | [`wholebrain-v1.0`](https://github.com/brainlife/app-intersect-tract-roi/tree/wholebrain-v1.0) | [doi:10.25663/brainlife.app.556](https://doi.org/10.25663/brainlife.app.556) | current |
| Segment Tracts with ROIs | the tracts of a white matter classification | [`v1.1`](https://github.com/brainlife/app-intersect-tract-roi/tree/v1.1) | [doi:10.25663/brainlife.app.282](https://doi.org/10.25663/brainlife.app.282) | current |
| Intersect Tracts with ROI - deprecated | a tract and one ROI (vistasoft, minimum distance) | [`master`](https://github.com/brainlife/app-intersect-tract-roi/tree/master) | [doi:10.25663/brainlife.app.545](https://doi.org/10.25663/brainlife.app.545) | deprecated |

The deprecated App intersected a chosen tract with one ROI in vistasoft format, in `and` mode (keep the streamlines that pass through the ROI) or `not` mode (keep those that do not), with a minimum distance between ROI and streamline (default 0.87).

## How it works

The current Apps use MRtrix3 `tckedit`. Each line of `roiNames` defines one new tract:

- the ROIs on a line are applied one after the other, so a line with several ROIs keeps only the streamlines that satisfy all of them;
- the matching line of `intersect_type` says whether the ROIs are used with `include` (keep streamlines that reach the ROIs) or `exclude` (keep all other streamlines);
- `endpoints_only` (default `true`) considers only streamline endpoints; set it to `false` to use streamlines that pass anywhere through the ROI;
- `inverse` inverts the selection.

ROI names are the part of the ROI file name between the `ROI` prefix and the `.nii.gz` extension in the input `neuro/rois` dataset. For example, three new tracts:

```text
roiNames:                                   intersect_type:
freesurfer-11121 freesurfer-11161           include
freesurfer-parietal_L freesurfer-11121      exclude
freesurfer_occipital_R                      include
```

Tracts with no streamlines left are dropped, and the rest are merged into one tractogram and a new classification with one tract per line. The *Segment Tracts with ROIs* App first splits each tract of the input classification into its own `.tck` and applies the ROI lines to each one. The ROIs must be in the same space as the tractogram.

## Running the App

### On brainlife.io

Open the App at [doi.org/10.25663/brainlife.app.556](https://doi.org/10.25663/brainlife.app.556) and choose a `neuro/track/tck` tractogram, a `neuro/rois` dataset and a `neuro/dwi` dataset (used only as the reference anatomy); the *Segment Tracts with ROIs* App also takes the `neuro/wmc` classification of the tractogram. Enter `roiNames` and `intersect_type` and press **Execute**. The App writes a new tractogram (`neuro/track/tck`) and classification (`neuro/wmc`), both tagged `intersected`, and a `raw` dataset with the intermediate files.

### Locally

You need [Singularity/Apptainer](https://apptainer.org/) and [`jq`](https://jqlang.github.io/jq/). `main` runs the steps in the `brainlife/mrtrix3:3.0_RC3`, `brainlife/dipy:1.4.0` and `brainlife/pythonvtk:1.1` containers.

1. Clone this repository and check out the App's branch: `git checkout wholebrain-v1.0`.
2. Create `config.json` with the paths to your inputs and the ROI lines (use `\n` between lines):

   ```json
   {
       "track": "/input/track/track.tck",
       "rois": "/input/rois/rois",
       "reference_anatomy": "/input/dwi/dwi.nii.gz",
       "bvals": "/input/dwi/dwi.bvals",
       "bvecs": "/input/dwi/dwi.bvecs",
       "roiNames": "freesurfer-11121 freesurfer-11161\nfreesurfer_occipital_R",
       "intersect_type": "include\ninclude",
       "inverse": false,
       "endpoints_only": true
   }
   ```

3. Run the App:

   ```bash
   ./main
   ```

### Sample data

Download sample ROIs and a classification from brainlife.io with the [brainlife CLI](https://github.com/brainlife/cli):

```bash
npm install -g brainlife
bl login
mkdir input
bl dataset download 5b96bc8b059cf900271924f4 && mv 5b96bc8b059cf900271924f4 input/rois
bl dataset download 5b96bc8d059cf900271924f5 && mv 5b96bc8d059cf900271924f5 input/wma
```

## Outputs

```text
track/
└── track.tck              the selected streamlines of all new tracts
wmc/
├── classification.mat     one tract per roiNames line
├── tracts/
└── surfaces/              surface meshes of the ROIs, for the brainlife.io viewer
raw/                       per-tract .tck files and track name lists
```

## Troubleshooting

- **`something went wrong. check derivatives and logs`**: no streamlines survived the ROI filtering, so no tractogram was written. Check the ROI names, `intersect_type` and `endpoints_only`, and make sure the ROIs overlap the tracts.

## Citing

> [!TIP]
> If you use this App in your work, please cite the App, the software it builds on and brainlife.io (below). GitHub's **Cite this repository** button gives the App citation in APA and BibTeX.

- Tournier J-D, Smith RE, Raffelt D, Tabbara R, Dhollander T, Pietsch M, Christiaens D, Jeurissen B, Yeh C-H, Connelly A. MRtrix3: a fast, flexible and open software framework for medical image processing and visualisation. *NeuroImage* 202:116137 (2019).
- Segment Wholebrain Tractogram with ROIs. brainlife.io App. [doi:10.25663/brainlife.app.556](https://doi.org/10.25663/brainlife.app.556)
- Tournier J-D, Smith RE, Raffelt D, et al. MRtrix3: A fast, flexible and open software framework for medical image processing and visualisation. NeuroImage 202:116137 (2019).
- Tournier et al. MRtrix3: A fast, flexible and open software framework for medical image processing and visualisation. *NeuroImage* 202:116137 (2019). [doi:10.1016/j.neuroimage.2019.116137](https://doi.org/10.1016/j.neuroimage.2019.116137)
- Garyfallidis et al. Dipy, a library for the analysis of diffusion MRI data. *Frontiers in Neuroinformatics* 8 (2014). [doi:10.3389/fninf.2014.00008](https://doi.org/10.3389/fninf.2014.00008)
- Hayashi S, Caron BA, Heinsfeld AS, et al. brainlife.io: a decentralized and open-source cloud platform to support neuroscience research. *Nature Methods* 21:809–813 (2024). [doi:10.1038/s41592-024-02237-2](https://doi.org/10.1038/s41592-024-02237-2)
- Avesani P, McPherson B, Hayashi S, et al. The open diffusion data derivatives, brain data upcycling via integrated publishing of derivatives and reproducible open cloud services. *Scientific Data* 6:69 (2019). [doi:10.1038/s41597-019-0073-y](https://doi.org/10.1038/s41597-019-0073-y)

## Authors

- Franco Pestilli (project director)
- Brad Caron
- Jan Kurzawski

**Contributors:** Soichi Hayashi

## Funding

[![Wellcome-226486/Z/22/Z](https://img.shields.io/badge/Wellcome-226486%2FZ%2F22%2FZ-purple.svg)](https://wellcome.org/)
[![NIH-NINDS-U24NS140384](https://img.shields.io/badge/NIH_NINDS-U24NS140384-green.svg)](https://reporter.nih.gov/project-details/11261037)
[![NIH-NINDS-UM1NS132207](https://img.shields.io/badge/NIH_NINDS-UM1NS132207-green.svg)](https://reporter.nih.gov/project-details/11411328)
[![NIH-NIBIB-R01EB029272](https://img.shields.io/badge/NIH_NIBIB-R01EB029272-green.svg)](https://reporter.nih.gov/project-details/10262925)
[![NIH-NIBIB-R01EB030896](https://img.shields.io/badge/NIH_NIBIB-R01EB030896-green.svg)](https://reporter.nih.gov/project-details/10428625)
[![NIH-NIMH-R01MH126699](https://img.shields.io/badge/NIH_NIMH-R01MH126699-green.svg)](https://reporter.nih.gov/project-details/10460628)
[![NIH-NIDCD-R01DC020088](https://img.shields.io/badge/NIH_NIDCD-R01DC020088-green.svg)](https://reporter.nih.gov/project-details/11140284)
[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-2203524](https://img.shields.io/badge/NSF_BCS-2203524-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2203524)
[![NSF-IIS-1636893](https://img.shields.io/badge/NSF_IIS-1636893-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1636893)
[![NSF-OAC-2148729](https://img.shields.io/badge/NSF_OAC-2148729-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148729)
[![NSF-IIS-1912270](https://img.shields.io/badge/NSF_IIS-1912270-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1912270)
[![NSF-IIS-2148700](https://img.shields.io/badge/NSF_IIS-2148700-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148700)
[![NSF-OAC-1916518](https://img.shields.io/badge/NSF_OAC-1916518-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1916518)

<sub>brainlife.io is publicly funded, and acknowledging that support helps keep it running. This App was developed with support from Wellcome, the U.S. National Institutes of Health (including the BRAIN Initiative BRAIN CONNECTS program: The Axonal Projectome EXchange, U24NS140384, and the Center for Mesoscale Connectomics, UM1NS132207) and the U.S. National Science Foundation.</sub>

## License

[MIT](https://github.com/brainlife/app-intersect-tract-roi/blob/master/LICENSE). MRtrix3 is distributed under its own [license](https://www.mrtrix.org/).
