---
# Elmo — Public Pipeline Repository

## Overview

This repository contains the public version of the Elmo fluorescence-image analysis pipeline, including:

- Elmo_25 Fiji/ImageJ macro
- Python notebook (Google Colab–compatible)
- Example input dictionary
- Documentation (README files) for each module

The goal is to provide researchers with a fully operational toolkit for image organisation, preprocessing, segmentation, and quantitative analysis of histological fluorescence data.

## Repository Structure

```
Elmo-pipeline-public/
├── macro/
│ ├── Elmo_25_final.ijm
│ ├── README.md
│
├── notebook/
│ ├── Elmo_notebook.ipynb
│ ├── README.md
│
├── example_dictionary/
│ ├── sample_dictionary.txt
│
└── README.md ← (this main file)
```

Each folder contains its own dedicated README explaining usage, requirements, and workflow.

## Included Components

### 1. Fiji/ImageJ Macro — Elmo_25

Located in macro/

- Performs optical density analysis
- Runs StarDist (TensorFlow) for nuclear segmentation
- Handles multi-channel fluorescence datasets
- Exports labeled images, ROI files, and measurement tables

The folder contains its own detailed documentation (macro/README.md).

### 2. Python Notebook

Located in notebook/

- Designed to run directly in Google Colab
- Performs additional data processing and visualization
- Accepts output from the macro as input
- Includes instructions for environment setup

See notebook/README.md for details.

### 3. Sample Dictionary

Located in example_dictionary/

A text file demonstrating how to structure the sample-key dictionary required by the macro or for downstream analysis.

## Usage

1. Download or clone the repository.
2. Prepare your datasets following the folder hierarchy described in macro/README.md.
3. Run the Elmo_25 macro in Fiji/ImageJ.
4. (Optional) Upload the .ipynb notebook to Google Colab for extended analysis.
5. Use the sample dictionary as a template for your own experiments.

## Requirements

- Fiji/ImageJ ≥ 1.54
- StarDist plugin (TensorFlow version)
- Python 3.10+ (if running notebook locally)
- Google Colab (recommended for easy execution)

## Authors

- Susana I. Sá, Faculdade de Medicina, Universidade do Porto
- Sandra I. Marques, Faculdade de Farmácia, Universidade do Porto

## License

This repository is provided for academic use only.
Please cite the authors if you use this pipeline in publications.
