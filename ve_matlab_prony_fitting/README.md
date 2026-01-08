# Viscoelastic Creep Fitting Routine

This folder provides MATLAB routines to fit **viscoelastic creep** data with a **Kelvin–Voigt model** (Prony series).

## Folder structure

- **`VE_Creep_Results`** → MAT files for each tested sample, collected and sorted into subfolders by sample type, together with a summary table containing the main information for all samples of that type, all generated after DIC analysis.  
- **`matlab-fitting-routine`** → MATLAB scripts and functions for performing the Prony fitting and exporting the results.  

## Main scripts to run

- **Run_Ftest_Prony.m** → Loads the creep datasets and tests candidate model orders (number of Kelvin–Voigt elements) using a Fisher test. Suggests the **optimal number of elements** to avoid overfitting.  

- **Fit_Prony_Creep.m** → Loads the creep datasets and performs compliance estimation for a given number of Kelvin–Voigt elements and characteristic times. Results are saved in:  
  - **samples_prony_compliance.mat** → characteristic times and element compliances per sample, together with time, strain, and creep compliance series.  
  - **general_prony_compliance.mat** → characteristic times and average element compliances per sample type, sorted by humidity and loading degree.  

- **convert_results_excel.m** → Converts the results into Excel files organized by sample type. Each file contains multiple sheets (one per experiment). Each sheet reports detailed information about the sample (dimensions, RH during the experiment, applied load, loading degree) along with time, creep strain, and creep compliance measurements.
