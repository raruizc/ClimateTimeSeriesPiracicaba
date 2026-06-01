# 🌦️ Historical Analysis and Climate Prediction - Piracicaba (1950 - 2026)

Welcome to the repository for the climate data analysis project focused on the Piracicaba region, SP, Brazil. This project was developed as part of the **LCF5900 - Open Science and Reproducible Data** course.

Our main objective is to investigate the behavior of long-term seasonal trends and statistically evaluate the impact of oceanic anomalies (El Niño and La Niña) on extreme local weather events.

---

## 🎯 What You Will Find Here

This repository contains the R script (and the R Markdown report) documenting a complete and reproducible scientific workflow. The analysis was structured into **14 analytical and predictive steps**:

<details>
<summary><b>📊 1. Descriptive and Exploratory Analyses (Click to expand)</b></summary>

* **Cleaning and Structuring:** Filtering historical data from 1950 onwards to ensure data density and reliability[cite: 1].
* **Maximum Temperature:** Table of descriptive statistics segmented by seasons and a detailed time series[cite: 1].
* **Thermal Amplitude:** Ribbon chart highlighting the daily variation range between minimum and maximum temperatures[cite: 1].
* **Precipitation and Seasonality:** Scatter plots of rainfall and application of 30-day Moving Averages chronologically faceted by quarter to isolate daily noise[cite: 1].

</details>

<details>
<summary><b>🌊 2. The Impact of El Niño / La Niña (ENSO)</b></summary>

* **Historical Frequency:** Construction of a NOAA-style timeline showing the cycles of anomalies over the decades[cite: 1].
* **Temperature Extremes:** Boxplots proving the general increase in maximum temperatures under the influence of severe phenomena[cite: 1].

</details>

<details>
<summary><b>📐 3. Statistical Tests and Correlations</b></summary>

* **Kruskal-Wallis (Non-Parametric):** Tests applied to the complete series and isolated for Summer, statistically proving that La Niña and neutral years favor torrential rains in the region[cite: 1].
* **Spearman Correlation:** Correlogram matrix robust to *outliers*, crossing local climatic variables with the Oceanic Niño Index (ONI)[cite: 1].
* **Thermal Extremes:** Proportion charts identifying the times of day with the highest incidence of heat and cold peaks[cite: 1].

</details>

<details>
<summary><b>🤖 4. Advanced Predictive Modeling (Time-Series)</b></summary>

* **ARIMA:** Econometric predictive models applied to the ONI index, including short-term forecasts (24 months) and long-term simulations (until 2050) to demonstrate the limitations of purely statistical models[cite: 1].
* **Machine Learning with Prophet (Meta):** Use of the Prophet algorithm for robust projection of climate scenarios, decomposing seasonal cycles and interannual trends[cite: 1].

</details>

---

## 🚀 How to Reproduce This Project

Our group's philosophy is heavily based on **Open Science**. To reproduce our analyses:

1. **Clone this repository:**
```bash
   git clone [https://github.com/raruizc/ClimateTimeSeriesPiracicaba.git](https://github.com/raruizc/ClimateTimeSeriesPiracicaba.git)
