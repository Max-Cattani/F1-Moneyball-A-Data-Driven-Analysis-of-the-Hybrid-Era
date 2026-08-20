# Data Folder

This folder contains the custom datasets built for the F1 Moneyball analysis. 

### Custom Datasets (Included)
* `f1_budget_2014-2025.csv`: Estimated team budgets. For the full methodology and sources of these financial data, please refer to my dedicated repository: https://github.com/Max-Cattani/f1-budget-hybrid-era.
* `DHL_pit_stop.csv`: Aggregated pit stop scores.
* `df_full_teamyear.csv`: The final panel dataset used for the analysis.

### Raw Datasets (Not Included)
Due to file size limits and best practices, the raw F1 race data are not uploaded in this repository. 

To run the `analysis.R` script from scratch, please download the following CSV files from the **Formula 1 World Championship (1950 - 2024)** (up to the 2024 season) at this link: https://www.kaggle.com/datasets/rohanrao/formula-1-world-championship-1950-2020
* `results.csv` (rename to `results_2024.csv`)
* `races.csv` (rename to `races_2024.csv`)
* `constructors.csv` (rename to `constructors_2024.csv`)
* `drivers.csv` (rename to `drivers_2024.csv`)

Place these downloaded files directly into this `data/` folder before running the script.

**⚠️ Important Note on CSV Export:** If you edit or recreate the custom CSVs locally, ensure your editor exports them using commas `,` as separators, not semicolons `;`, to avoid parsing errors in R.

# SOME PREMISES
## RAW FINANCIAL SOURCES

In case of any figure verification, check https://github.com/Max-Cattani/f1-budget-hybrid-era 

*Note: If some amount doesn't match perfectly, bear in mind that few data needed an adaptation of currency (e.g. past exchange rates) or even double check from sources. 
Hence some figures are simply an aproximation, but near enough to explain actual budgets*


## DHL PIT STOP AWARD

In case of any figure verification, check https://inmotion.dhl/en/formula-1/fastest-pit-stop-award/overview

*Note: The records begin in 2018, therefore the previous 4 F1 seasons data have been "manually" obtained by race data, which include pit stop times*
