## **README — Elmo_25 ImageJ/Fiji Macro**

### **Overview**

**Elmo_25** is an automated ImageJ/Fiji pipeline for the **quantitative analysis of fluorescence microscopy images**.
It measures **optical density (OD)**, extracts **intensity-based features**, and performs **nuclear segmentation** using **StarDist (TensorFlow)**.

The macro is designed for datasets organized hierarchically into four folder levels and supports manual ROI definition to exclude artifacts or non-specific labeling.

---

### **Folder Organization**

The macro requires a strict 4-level folder structure:

```
Level 1 → Group
Level 2 → Sample
Level 3 → Tissue (histological region)
Level 4 → Field (individual image files)
```

#### **Example:**

```
Elmo_10-25/
 ├── Control/
 │    ├── Rat01/
 │    │    ├── DG/
 │    │    │    ├── field1_c0.tif
 │    │    │    ├── field1_c1.tif
 │    │    │    └── field1_c2.tif
 │    │    └── CA3/
 │    │         ├── field1_c0.tif
 │    │         ├── field1_c1.tif
 │    │         └── field1_c2.tif
 │    └── Rat02/
 │         └── DG/ ...
 └── Treated/ ...
```

**Important:**

* Folder names must **not contain spaces or special characters**.
* The **Tissue folder name (Level 3)** must **exactly match** the tissue name entered in the *Settings* dialog (e.g., “DG”, “CA3”).
  If the names do not match, the macro will abort processing for that sample.

---

### **Macro Workflow**

1. Checks folder structure consistency before starting.
2. Prompts the user to define identifiers for each fluorescence channel (e.g., `c0`, `c1`, `c2`).
3. Performs preprocessing (background subtraction, contrast enhancement).
4. Allows manual ROI drawing to exclude artifacts or non-specific labeling.
5. Runs **StarDist (TensorFlow)** for DAPI segmentation.
6. Measures intensity and optical density within selected ROIs.
7. Exports results and processed images into structured *Results* folders.

---

### **Settings Parameters Explained**

When running the macro, the *Settings* dialog will appear.
Each parameter defines how images are selected and processed:

| **Parameter**           | **Description**                                                                               |
| ----------------------- | --------------------------------------------------------------------------------------------- |
| **DAPI (c0)**           | Selects whether DAPI images (typically nuclei) are analyzed.                                  |
| **Green (c1)**          | Enables processing of the green fluorescence channel.                                         |
| **Red (c2)**            | Enables processing of the red fluorescence channel.                                           |
| **Area to analyze**     | Choose the target histological region (must match the folder name at Level 3).                |
| **Channel identifiers** | Strings (e.g., `c0`, `c1`, `c2`) that define how each channel is identified in the filenames. |
| **StarDist thresholds** | Predefined parameters for segmentation sensitivity (can be tuned in code).                    |

---

### **Image Magnification (Calibration)**

The image magnification can be defined **either outside or inside the macro**:

* **Option A — Before running the macro:**
  Calibrate your images manually in Fiji using
  `Analyze → Set Scale…`
  Set the appropriate pixel size and unit (e.g., inches or µm).

* **Option B — Inside the macro:**
  The macro can apply an internal calibration (default: `1 inch = 149.9957 pixels`),
  automatically converting pixel-based measurements to physical units.

Make sure that **all images use the same magnification and scale** to ensure consistent results.

---

### **Output**

Results are stored automatically in the output folder chosen at runtime:

```
Results/
 ├── Group/
 │    ├── Sample/
 │    │    ├── Measurements.csv
 │    │    ├── SUM_Stack_SubArea.tif
 │    │    ├── Label_Image.tif
 │    │    └── ROI_DG.zip
 │    └── ...
 └── ...
```

Each folder includes:

* Processed image stacks
* Labeled segmentation results
* ROI sets for defined regions
* Measurement tables with OD and intensity per ROI

---

### **Requirements**

* **Fiji/ImageJ** ≥ 1.54
* **Plugins:** Bio-Formats, StarDist (TensorFlow backend)
* **Image format:** `.tif` (one file per channel)
* **System:** Windows, macOS, or Linux

---

### **Credits**

Developed by:
**Susana I. Sá** & **Sandra I. Marques**
Faculdade de Medicina / Faculdade de Farmácia, Universidade do Porto

---

### **Version History**

| **Version** | **Date**   | **Notes**                                                                      |
| ----------- | ---------- | ------------------------------------------------------------------------------ |
| 3.0         | 2025-10-07 | Initial release with TensorFlow StarDist integration.                          |
| 3.1         | 2025-10-11 | Added flexible channel identifiers, ROI validation, and updated documentation. |

---

### **Citation**

If you use this macro in your research, please cite:

> Sá, S.I. & Marques, S.I. (2025). *Elmo_25: Automated Fluorescence Image Quantification in Fiji*.
> Faculdade de Medicina & Faculdade de Farmácia, Universidade do Porto.
> (File location: https://github.com/up246512-ui/Elmo-pipeline-public/blob/main/macro/Elmo_25.ijm)
