# Mechanosorptive Creep Evaluation Routines  

This repository contains routines related to the mechanosorptive experimental campaign performed under cyclic relative humidity (RH) between 30% and 90%.  

## Folder structure  

- **`MS_Creep_Tests_Dataset`**  
  Dataset folder with all experiments, sorted by sample and test type. Each file contains multiple sheets (one per sample). The dataset also includes results of tensile elastic tests [Ferrara and Wittel, 2024](), tensile creep tests [Ferrara and Wittel, 2025](), and Dynamic Vapor Sorption (DVS). DOI: [10.17632/rsrsw8h7mv.1](https://doi.org/10.17632/rsrsw8h7mv.1)  

- **MS_creep_evaluation**  
  Jupyter notebook for evaluating experimental datasets (previously obtained from MATLAB DIC analysis) to isolate the mechanosorptive strain from the total strain measured with Digital Image Correlation (DIC).

- **Create_excel_files_MS_creep_tests.ipynb**  
  Jupyter notebook to convert the results into Excel files organized by sample type. Each file contains multiple sheets (one per experiment), and each sheet reports detailed sample information (dimensions, applied load, loading degree) along with time, creep strain, creep compliance, and moisture measurements.   

- **MS_creep_tests_Ferrara_Wittel_2025**  
  Jupyter notebook provided as an analysis tool to generate boxplots summarizing all results (as in [Ferrara & Wittel, 2025]()). DOI: [10.5281/zenodo.14002650](https://doi.org/10.5281/zenodo.14002650)  

- **Test_MS_decomposition_routine_Ferrara_Wittel_2025**  
  Jupyter notebook provided as an analysis tool to implement and validate the incremental decomposition scheme on clean data. DOI: [10.5281/zenodo.14002650](https://doi.org/10.5281/zenodo.14002650)  
