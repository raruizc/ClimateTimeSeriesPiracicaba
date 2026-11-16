# 🌦️ Historical Analysis and Climate Prediction - Piracicaba (1950 - 2026)

Welcome to the repository for the climate data analysis project focused on the Piracicaba region, SP, Brazil. This project was developed as part of the **LCF5900 - Open Science and Reproducible Data** course.

Our main objective is to investigate the behavior of long-term seasonal trends and statistically evaluate the impact of oceanic anomalies (El Niño and La Niña) on extreme local weather events.

---

## 🎯 What You Will Find Here

This repository contains the R script (and the R Markdown report) documenting a complete and reproducible scientific workflow. The analysis was structured into **14 analytical and predictive steps**:

<details>
<summary><b>📊 1. Descriptive and Exploratory Analyses (Click to expand)</b></summary>

* **Cleaning and Structuring:** Filtering historical data from 1950 onwards to ensure data density and reliability.
* **Maximum Temperature:** Table of descriptive statistics segmented by seasons and a detailed time series.
* **Thermal Amplitude:** Ribbon chart highlighting the daily variation range between minimum and maximum temperatures.
* **Precipitation and Seasonality:** Scatter plots of rainfall and application of 30-day Moving Averages chronologically faceted by quarter to isolate daily noise.

</details>

<details>
<summary><b>🌊 2. The Impact of El Niño / La Niña (ENSO)</b></summary>

* **Historical Frequency:** Construction of a NOAA-style timeline showing the cycles of anomalies over the decades.
* **Temperature Extremes:** Boxplots proving the general increase in maximum temperatures under the influence of severe phenomena.

</details>

<details>
<summary><b>📐 3. Statistical Tests and Correlations</b></summary>

* **Kruskal-Wallis (Non-Parametric):** Tests applied to the complete series and isolated for Summer, statistically proving that La Niña and neutral years favor torrential rains in the region.
* **Spearman Correlation:** Correlogram matrix robust to *outliers*, crossing local climatic variables with the Oceanic Niño Index (ONI).
* **Thermal Extremes:** Proportion charts identifying the times of day with the highest incidence of heat and cold peaks.

</details>

<details>
<summary><b>🤖 4. Advanced Predictive Modeling (Time-Series)</b></summary>

* **ARIMA:** Econometric predictive models applied to the ONI index, including short-term forecasts (24 months) and long-term simulations (until 2050) to demonstrate the limitations of purely statistical models.
* **Machine Learning with Prophet (Meta):** Use of the Prophet algorithm for robust projection of climate scenarios, decomposing seasonal cycles and interannual trends.

</details>

---

## 🚀 How to Reproduce This Project

Our group's philosophy is heavily based on **Open Science**. To reproduce our analyses:

1. **Clone this repository:**
```bash
   git clone https://github.com/raruizc/ClimateTimeSeriesPiracicaba.git
   ```
2. **Install the R packages:**
   ```r
   install.packages(c("tidyverse", "readxl", "rio", "lubridate", "zoo", "forecast",
                      "prophet", "ggcorrplot", "gganimate", "gifski", "av"))
   ```
3. **Run the analysis:** open `Report_Climate.Rmd` in RStudio and click **Knit**, or run `Script_Climate.R` line by line. The data file `DadosClima_Piracicaba.xlsx` is read from the project root.

## 📂 Repository Structure

| File | Description |
|---|---|
| `DadosClima_Piracicaba.xlsx` | Historical daily weather records for Piracicaba |
| `Script_Climate.R` | Full analysis as a plain R script |
| `Report_Climate.Rmd` | Reproducible R Markdown report |
| `Report_Climate.html` / `.pdf` | Rendered reports |

## 👥 Authorship

Team project for the LCF5900 Open Science course (ESALQ/USP, 2026). Repository maintained by **Ricardo Antonio Ruiz-Cardozo**, PhD candidate in Statistics and Agricultural Experimentation.

Code released under the [MIT License](LICENSE).
