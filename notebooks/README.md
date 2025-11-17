# **Determination of Optical Density from FIJI analysis**

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/<YOUR_ORG_OR_USER>/<YOUR_REPO>/blob/main/notebooks/DO_Determination_Elmo.ipynb)

> TL;DR — Compute optical density (OD) metrics from **FIJI/ImageJ** exports, build a treatment dictionary, and generate summary tables and plots (per tissue/subarea) directly in **Google Colab**.

## Overview
This repository provides a Colab-friendly notebook to determine optical density (OD) from outputs produced by **FIJI**. It guides you to:
- Build and use a *treatment dictionary* (`treatment_dict.txt`).
- Load input measurement files exported from FIJI.
- Compute OD/OD pond metrics.
- Export tidy tables and generate bar plots by tissue and subarea.

## Why Colab & Google Drive?
This notebook is designed to run on **Google Colab**. Upload the notebook and your data to **Google Drive**, then open it with Colab.

If you open from GitHub via the Colab badge, you can still access files stored on Drive by mounting Drive in the notebook.

---

## Notebook
- **File:** `notebooks/DO_Determination_Elmo.ipynb`
- **Main sections:**  
  Dictionary construction and use, How to create the file ("treatment_dict.txt"), How to run, Optic density determination, Prerequisites, How to use, DO and DOpond Visualization, Instructions

## Requirements
- Python 3.10+ (handled by Colab)
- Recommended packages (auto-installed in Colab if missing):
  - ast, glob, google, matplotlib, numpy, openpyxl, os, pandas, pathlib, pprint, re, shutil

> If running locally, ensure JupyterLab/Notebook is installed.

## Run on Google Colab (recommended)
1. Open the notebook via the badge above, **or** upload `notebooks/DO_Determination_Elmo.ipynb` to your Drive and choose **Open with → Google Colab**.
2. (Optional) Mount Drive to read/write files:
   ```python
   from google.colab import drive
   drive.mount('/content/drive')
   # Your Drive path typically becomes: /content/drive/MyDrive/
   ```
3. Install dependencies if needed:
   ```python
   %pip install -q pandas numpy matplotlib openpyxl
   ```
4. Follow the "**How to use**" and "**How to run**" sections inside the notebook and execute the cells in order.

## Input data
Common inputs detected from the notebook:
- `treatment_dict.txt`
- `/content/{basename}*.txt`
- `_processed.xlsx`
- `all_concatenated.xlsx`
- `by_mouse.xlsx`
- `.xlsx`
- `/content/by_mouse.xlsx`

> Place input files in your Drive and update paths in the notebook if required.

## Outputs
Figures and tables are saved under the working directory in Colab. Examples detected:
- `{outfile_stem}_{cat}.png`
- `bar_DO_by_Tissue_TRAT.png`
- `bar_DOpond_by_Tissue_TRAT.png`
- `bar_DO_by_Subarea_TRAT.png`
- `bar_DOpond_by_Subarea_TRAT.png`

## Project structure (suggested)
```
.
├── notebooks/
│   └── DO_Determination_Elmo.ipynb
├── data/                 # (optional) input files if running locally
├── outputs/              # generated plots/tables
└── README.md
```

## Reproducibility
- Set a fixed random seed (if applicable).
- Keep FIJI export settings consistent across datasets.
- Document the tissue/subarea naming used in `treatment_dict.txt`.

## Troubleshooting
- **ModuleNotFoundError** → Run the install cell (`%pip install ...`) and re-run the imports.
- **FileNotFoundError** → Verify Drive is mounted and the file paths point to `/content/drive/MyDrive/...`.
- **Excel read errors** → Ensure `openpyxl` is installed for `.xlsx` and the file is not open elsewhere.
- **Plots not generated** → Confirm the expected columns exist (as per the notebook instructions).

## Citation / Credits
If you use this notebook in academic work, please cite your FIJI/ImageJ version and this repository.

---

*Last updated: 2025-11-17*
