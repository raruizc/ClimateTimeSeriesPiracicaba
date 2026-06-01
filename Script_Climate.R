# ==============================================================================
# Script 02 Class -  LCF5900 Open Science and Reproducible Data
# Author: Ricardo Antonio Ruiz Cardozo
# ==============================================================================

# 1. SETUP AND MEMORY CLEANUP ==================================================
rm(list=ls(all=TRUE))
gc()

# Load Packages
library(tidyverse)
library(rio); install_formats()
library(gganimate)
library(gifski)
library(av)
library(lubridate)
library(readxl)
library(zoo)

# 2. DATA IMPORT ===============================================================
# Define GitHub URL where climate data is stored
url_1   <- "https://github.com/raruizc/ClimateTimeSeriesPiracicaba/blob/main/"
xls_2   <- "DadosClima_Piracicaba.xlsx"
prm_3   <- "?raw=true"
gitFile <- paste0(url_1, xls_2, prm_3)

# Imports the Excel spreadsheet from GitHub, converts it to tibble, and adjusts classes
sheetName    <- "DadosClima_Piracicaba"
my_col_types <- c(rep("text", 8), rep("numeric", 16))

df <- import(gitFile, which = sheetName, col_types = my_col_types)
df <- df %>% 
  mutate(across(4:7, factor)) %>% 
  tibble()

df$TMED <- as.numeric(df$TMED)

# Initial structure verification
# colnames(df)
# str(df)
# levels(df$Trimestre)


# 3. GENERAL DATA PREPARATION ==================================================
# Creating a unified Date column and ensuring correct data types
df_clima <- df %>%
  mutate(
    Data    = make_date(Ano, Mes, Dia),
    TMAX    = as.numeric(TMAX),
    Estacao = as.factor(Estacao)
  ) %>%
  drop_na(TMAX, Estacao)

# Filtering data from 1950 onwards for analysis
df_recente <- df_clima %>%
  filter(Ano >= 1950)


# 4. DESCRIPTIVE ANALYSIS: MAXIMUM TEMPERATURE =================================
tabela_descritiva <- df_recente %>%
  group_by(Estacao) %>%
  summarise(
    Mean_TMAX      = round(mean(TMAX, na.rm = TRUE), 1),
    Max_Peak       = max(TMAX, na.rm = TRUE),
    Min_Registered = min(TMAX, na.rm = TRUE),
    Standard_Dev   = round(sd(TMAX, na.rm = TRUE), 2)
  )

print(tabela_descritiva)

# Plot: Time Series (TMAX)
grafico_tmax <- ggplot(df_recente, aes(x = Data, y = TMAX, color = Estacao)) +
  geom_line(alpha = 0.4) +
  geom_point(size = 1.5, alpha = 0.8) +
  # Translating legend labels while keeping the original data mapping
  scale_color_manual(
    name = "Season:",
    labels = c("VerC#o" = "Summer", "Outono" = "Autumn", "Inverno" = "Winter", "Primavera" = "Spring"),
    values = c("VerC#o" = "red", "Outono" = "orange", "Inverno" = "blue", "Primavera" = "forestgreen")
  ) +
  labs(
    title    = "Maximum Temperature Time Series in Piracicaba",
    subtitle = "Recent period (1950-2026) highlighted by seasons",
    x        = "Measurement Date",
    y        = "Maximum Temperature (B0C)"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    plot.title      = element_text(face = "bold", size = 14)
  )

print(grafico_tmax)


# 5. AREA CHART: THERMAL AMPLITUDE =============================================
df_plot_area <- df_recente %>%
  mutate(
    TMED = as.numeric(TMED),
    TMAX = as.numeric(TMAX),
    TMIN = as.numeric(TMIN)
  ) %>%
  drop_na(Data, TMED, TMAX, TMIN) 

grafico_area_clima <- ggplot(df_plot_area) +
  geom_ribbon(aes(x = Data, ymin = TMIN, ymax = TMAX, fill = "Thermal Amplitude (Min - Max)"), alpha = 0.3) +
  geom_line(aes(x = Data, y = TMED, color = "Average Temperature"), linewidth = 0.8) +
  scale_color_manual(name = "Line:", values = c("Average Temperature" = "black")) +
  scale_fill_manual(name = "Area:", values = c("Thermal Amplitude (Min - Max)" = "grey50")) +
  labs(
    title    = "Evolution of Thermal Amplitude in Piracicaba",
    subtitle = "Daily average temperature and its extremes",
    x        = "",
    y        = "Temperature (B0C)"
  ) +
  scale_x_date(date_labels = "%Y", date_breaks = "5 years") +
  theme(
    axis.text.x      = element_text(angle = 90, vjust = 0.4),
    panel.background = element_rect(fill = "white", color = "black"),
    panel.grid       = element_line(color = "grey90"),
    panel.border     = element_rect(color = "black", fill = NA),
    legend.position  = "bottom"
  )

print(grafico_area_clima)


# 6. TIME SERIES AND PRECIPITATION MOVING AVERAGE ==============================

# 6.1 Simple Rainfall Time Series
grafico_chuva <- ggplot(df_recente, aes(x = Data, y = Chuva, color = Estacao)) +
  geom_line(alpha = 0.4) + 
  geom_point(size = 1, alpha = 0.4) +
  scale_color_manual(
    name = "Season:",
    labels = c("VerC#o" = "Summer", "Outono" = "Autumn", "Inverno" = "Winter", "Primavera" = "Spring"),
    values = c("VerC#o" = "red", "Outono" = "orange", "Inverno" = "blue", "Primavera" = "forestgreen")
  ) +
  labs(
    title    = "Raw Rainfall Time Series in Piracicaba",
    subtitle = "Recent period highlighted by seasons",
    x        = "Measurement Date",
    y        = "Rainfall (mm)"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    plot.title      = element_text(face = "bold", size = 14)
  )

print(grafico_chuva)

# 6.2 Precipitation Moving Average by Quarter (Chronological Order)
ordem_trimestres <- c("JFM", "FMA", "MAM", "AMJ", "MJJ", "JJA", 
                      "JAS", "ASO", "SON", "OND", "NDJ", "DJF")

df_chuva <- df_recente %>%
  mutate(
    Chuva     = as.numeric(Chuva),
    Trimestre = factor(Trimestre, levels = ordem_trimestres)
  ) %>%
  arrange(Data) %>% 
  mutate(Chuva_Movel_30d = rollmean(Chuva, k = 30, fill = NA, align = "right")) %>%
  drop_na(Chuva_Movel_30d, Trimestre)

grafico_chuva_trimestre <- ggplot(df_chuva, aes(x = Data, y = Chuva_Movel_30d, color = Trimestre)) +
  geom_line(alpha = 0.8) +
  facet_wrap(~Trimestre, ncol = 4) + 
  scale_color_viridis_d(option = "turbo") + 
  labs(
    title    = "Precipitation Moving Average (30 days) by Quarter",
    subtitle = "Chronological progression of rainfall in Piracicaba (since 1950)",
    x        = "Year",
    y        = "Rainfall (30-day Moving Average in mm)"
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    strip.text      = element_text(face = "bold", size = 10),
    axis.text.x     = element_text(angle = 45, hjust = 1),
    panel.spacing   = unit(1, "lines"),
    panel.border    = element_rect(color = "grey80", fill = NA)
  )

print(grafico_chuva_trimestre)


# 7. ENSO PHENOMENON EXPLORATORY ANALYSIS (ClassNino) ==========================
df_nino <- df_clima %>%
  filter(!is.na(ClassNino) & ClassNino != "") %>%
  mutate(ClassNino = as.factor(ClassNino))

ano_inicio_nino <- min(df_nino$Ano, na.rm = TRUE)
cat("\n---> The ClassNino variable records start in the year:", ano_inicio_nino, "<---\n\n")

resumo_nino <- df_nino %>%
  group_by(ClassNino) %>%
  summarise(
    Total_Days_Recorded = n(),
    Mean_TMAX   = round(mean(TMAX, na.rm = TRUE), 1),
    Mean_Rain   = round(mean(Chuva, na.rm = TRUE), 1)
  )
print(resumo_nino)

# Impact on Temperatures (Boxplot)
grafico_impacto_nino <- ggplot(df_nino, aes(x = ClassNino, y = TMAX, fill = ClassNino)) +
  geom_boxplot(alpha = 0.7, outlier.alpha = 0.3) +
  scale_fill_brewer(palette = "Set2") +
  labs(
    title    = "Impact of Climatic Phenomena on Maximum Temperature",
    subtitle = paste("Data analyzed since", ano_inicio_nino, "in Piracicaba"),
    x        = "El NiC1o / La NiC1a Classification",
    y        = "Maximum Temperature (B0C)"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

print(grafico_impacto_nino)

# Timeline 
df_nino_mensal <- df_nino %>%
  group_by(Ano, Mes, ClassNino) %>%
  summarise(Contagem = n(), .groups = 'drop') %>%
  mutate(Data_Mes = make_date(Ano, Mes, 1))

grafico_timeline <- ggplot(df_nino_mensal, aes(x = Data_Mes, y = 1, fill = ClassNino)) +
  geom_tile() +
  scale_y_continuous(breaks = NULL) +
  labs(
    title    = "Timeline: El NiC1o and La NiC1a Phases",
    subtitle = "Occurrence frequency over the years",
    x        = "Year",
    y        = "",
    fill     = "Climate Phase:"
  ) +
  theme_minimal() +
  theme(
    legend.position    = "bottom",
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank()
  )

print(grafico_timeline)


# 8. STATISTICAL ANALYSIS (PRECIPITATION X ClassNino) ==========================

# 8.1 Kruskal-Wallis - Full Dataset
df_chuva_nino <- df_clima %>%
  filter(!is.na(ClassNino) & ClassNino != "", !is.na(Chuva)) %>%
  mutate(
    ClassNino = as.factor(ClassNino),
    Chuva     = as.numeric(Chuva)
  )

teste_kruskal <- kruskal.test(Chuva ~ ClassNino, data = df_chuva_nino)
cat("\n--- Kruskal-Wallis Test Result (Complete Series) ---\n")
print(teste_kruskal)

grafico_chuva_nino <- ggplot(df_chuva_nino, aes(x = ClassNino, y = Chuva, fill = ClassNino)) +
  geom_violin(alpha = 0.5, trim = FALSE) +
  geom_boxplot(width = 0.1, fill = "white", alpha = 0.8, outlier.size = 1) +
  scale_y_continuous(trans = "pseudo_log", breaks = c(0, 1, 5, 10, 50, 100)) +
  scale_fill_brewer(palette = "Set1") +
  labs(
    title    = "Precipitation Distribution by Climatic Phenomenon",
    subtitle = "Logarithmic scale to highlight extreme rain events",
    x        = "Climate Phase (El NiC1o / La NiC1a)",
    y        = "Rainfall Volume (mm) - Pseudo-Log Scale"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

print(grafico_chuva_nino)


# 8.2 Kruskal-Wallis - Summer Focus
df_verao <- df_clima %>%
  filter(Estacao == "VerC#o", !is.na(ClassNino), ClassNino != "", !is.na(Chuva)) %>%
  mutate(
    ClassNino = as.factor(ClassNino),
    Chuva     = as.numeric(Chuva)
  )

teste_kruskal_verao <- kruskal.test(Chuva ~ ClassNino, data = df_verao)
cat("\n--- Kruskal-Wallis Test Result (Summer Only) ---\n")
print(teste_kruskal_verao)

grafico_chuva_verao <- ggplot(df_verao, aes(x = ClassNino, y = Chuva, fill = ClassNino)) +
  geom_violin(alpha = 0.5, trim = FALSE) +
  geom_boxplot(width = 0.1, fill = "white", alpha = 0.8, outlier.size = 1) +
  scale_y_continuous(trans = "pseudo_log", breaks = c(0, 1, 5, 10, 50, 100)) +
  scale_fill_brewer(palette = "Dark2") +
  labs(
    title    = "Impact of El NiC1o / La NiC1a on Summer Rainfall",
    subtitle = "Daily precipitation distribution isolating only the rainy season (Piracicaba)",
    x        = "Climate Phase",
    y        = "Rainfall Volume (mm) - Pseudo-Log Scale"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

print(grafico_chuva_verao)


# 9. CORRELATION ANALYSIS: CLIMATIC VARIABLES ==================================
if(!require(ggcorrplot)) install.packages("ggcorrplot")
library(ggcorrplot)

# Preparation: Selecting only continuous numeric variables and dropping NAs
df_cor <- df_recente %>%
  select(TMED, TMAX, TMIN, Chuva, MeanONI) %>%
  mutate(across(everything(), as.numeric)) %>%
  drop_na() 

# Correlation Matrix (Spearman method)
matriz_cor <- cor(df_cor, method = "spearman")
p_mat <- cor_pmat(df_cor, method = "spearman")

# Correlogram Visualization
grafico_correlacao <- ggcorrplot(
  matriz_cor, 
  method = "square", 
  type = "lower",          
  lab = TRUE,              
  lab_size = 4,
  p.mat = p_mat,           
  sig.level = 0.05,        
  insig = "blank",         
  colors = c("#0072B2", "white", "#D55E00"), 
  title = "Correlation Matrix (Spearman) - Piracicaba",
  ggtheme = theme_minimal()
) +
  theme(plot.title = element_text(face = "bold", size = 14))

print(grafico_correlacao)


# 10. TEMPERATURE EXTREMES TIME ANALYSIS =======================================
df_horas <- df_recente %>%
  drop_na(TMAX_hora, TMIN_hora) %>%
  mutate(
    Hora_TMAX = floor(as.numeric(TMAX_hora) / 100),
    Hora_TMIN = floor(as.numeric(TMIN_hora) / 100)
  ) %>%
  mutate(
    Periodo_TMAX = case_when(
      Hora_TMAX >= 0 & Hora_TMAX < 6    ~ "1. Dawn (00h-05h)",
      Hora_TMAX >= 6 & Hora_TMAX < 12   ~ "2. Morning (06h-11h)",
      Hora_TMAX >= 12 & Hora_TMAX < 18  ~ "3. Afternoon (12h-17h)",
      Hora_TMAX >= 18 & Hora_TMAX <= 24 ~ "4. Night (18h-23h)",
      TRUE ~ NA_character_
    ),
    Periodo_TMIN = case_when(
      Hora_TMIN >= 0 & Hora_TMIN < 6    ~ "1. Dawn (00h-05h)",
      Hora_TMIN >= 6 & Hora_TMIN < 12   ~ "2. Morning (06h-11h)",
      Hora_TMIN >= 12 & Hora_TMIN < 18  ~ "3. Afternoon (12h-17h)",
      Hora_TMIN >= 18 & Hora_TMIN <= 24 ~ "4. Night (18h-23h)",
      TRUE ~ NA_character_
    )
  ) %>%
  drop_na(Periodo_TMAX, Periodo_TMIN)

df_horas_long <- df_horas %>%
  select(Data, Periodo_TMAX, Periodo_TMIN) %>%
  pivot_longer(
    cols = c(Periodo_TMAX, Periodo_TMIN),
    names_to = "Tipo_Extremo",
    values_to = "Periodo_do_Dia"
  ) %>%
  mutate(
    Tipo_Extremo = recode(Tipo_Extremo, 
                          "Periodo_TMAX" = "Maximum Temperature",
                          "Periodo_TMIN" = "Minimum Temperature")
  )

grafico_horarios <- ggplot(df_horas_long, aes(x = Tipo_Extremo, fill = Periodo_do_Dia)) +
  geom_bar(position = "fill", color = "white", width = 0.6) +
  scale_fill_viridis_d(option = "mako", begin = 0.2, end = 0.9) +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(
    title = "In which period of the day do temperature extremes occur?",
    subtitle = "Frequency of Maximum and Minimum Temperature records in Piracicaba",
    x = "",
    y = "Proportion of Occurrences",
    fill = "Time of Day:"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    axis.text.x = element_text(face = "bold", size = 12)
  )

print(grafico_horarios)


# 11. OCEANIC INDEX ANALYSIS (MeanONI) OVER TIME ===============================
df_oni <- df_recente %>%
  filter(!is.na(MeanONI)) %>%
  mutate(MeanONI = as.numeric(MeanONI)) %>%
  group_by(Ano, Mes) %>%
  summarise(
    MeanONI = mean(MeanONI, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  mutate(
    Data_Mes = make_date(Ano, Mes, 1)
  ) %>%
  arrange(Data_Mes)

grafico_oni <- ggplot(df_oni, aes(x = Data_Mes, y = MeanONI, fill = MeanONI)) +
  geom_col(width = 35) + 
  scale_fill_gradient2(
    low = "blue", mid = "white", high = "red", midpoint = 0,
    name = "ONI Index:"
  ) +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "darkred", alpha = 0.7) +
  geom_hline(yintercept = -0.5, linetype = "dashed", color = "darkblue", alpha = 0.7) +
  labs(
    title = "Evolution of the Oceanic NiC1o Index (MeanONI)",
    subtitle = "Dashed lines indicate thresholds (+0.5 and -0.5) for phenomenon configuration",
    x = "Year",
    y = "Ocean Temperature Anomaly (B0C)"
  ) +
  scale_x_date(date_labels = "%Y", date_breaks = "5 years") +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(face = "bold", size = 14)
  )

print(grafico_oni)


# 12. TIME SERIES FORECAST: ARIMA MODEL FOR MeanONI ============================
library(forecast)

ano_inicial <- min(as.numeric(df_oni$Ano))
mes_inicial <- min(as.numeric(df_oni$Mes[df_oni$Ano == ano_inicial]))

ts_oni <- ts(df_oni$MeanONI, start = c(ano_inicial, mes_inicial), frequency = 12)

modelo_arima <- auto.arima(ts_oni)

cat("\n--- Summary of Automatically Chosen ARIMA Model ---\n")
print(summary(modelo_arima))

previsao_oni <- forecast(modelo_arima, h = 24)

grafico_previsao <- autoplot(previsao_oni) +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "darkred", alpha = 0.7) +
  geom_hline(yintercept = -0.5, linetype = "dashed", color = "darkblue", alpha = 0.7) +
  labs(
    title = "Oceanic Index (MeanONI) Forecast with ARIMA Model",
    subtitle = "Projection for the next 24 months with confidence intervals (80% and 95%)",
    x = "Year",
    y = "Projected ONI Index",
    caption = "Critical Note: Univariate forecasts lose accuracy in the long run due to climate complexity."
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

print(grafico_previsao)


# 12. LONG-TERM FORECAST (UNTIL 2050): ARIMA MODEL FOR MeanONI =================
library(forecast)
library(lubridate)

ano_inicial <- min(as.numeric(df_oni$Ano))
mes_inicial <- min(as.numeric(df_oni$Mes[df_oni$Ano == ano_inicial]))

ts_oni <- ts(df_oni$MeanONI, start = c(ano_inicial, mes_inicial), frequency = 12)
modelo_arima <- auto.arima(ts_oni)

ultima_data <- max(df_oni$Data_Mes)
meses_ate_2050 <- (2050 - year(ultima_data)) * 12 + (12 - month(ultima_data))

previsao_oni_2050 <- forecast(modelo_arima, h = meses_ate_2050)

grafico_previsao_2050 <- autoplot(previsao_oni_2050) +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "darkred", alpha = 0.7) +
  geom_hline(yintercept = -0.5, linetype = "dashed", color = "darkblue", alpha = 0.7) +
  labs(
    title = "Long-Term Projection of the ONI Index (Until 2050)",
    subtitle = paste("ARIMA model projecting the next", meses_ate_2050, "months based on history"),
    x = "Year",
    y = "Projected ONI Index",
    caption = "Open Science Note: Purely statistical models lose cyclical capacity in long horizons."
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

print(grafico_previsao_2050)


# 13. TIME SERIES FORECAST: ETS MODEL FOR MeanONI ==============================
library(forecast)

ano_inicial <- min(as.numeric(df_oni$Ano))
mes_inicial <- min(as.numeric(df_oni$Mes[df_oni$Ano == ano_inicial]))

ts_oni <- ts(df_oni$MeanONI, start = c(ano_inicial, mes_inicial), frequency = 12)

modelo_ets <- ets(ts_oni)

cat("\n--- Summary of Chosen ETS Model ---\n")
print(summary(modelo_ets))

previsao_ets <- forecast(modelo_ets, h = 24)

grafico_previsao_ets <- autoplot(previsao_ets) +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "darkred", alpha = 0.7) +
  geom_hline(yintercept = -0.5, linetype = "dashed", color = "darkblue", alpha = 0.7) +
  labs(
    title = "Oceanic Index (MeanONI) Forecast with ETS Model",
    subtitle = "Exponential Smoothing Projection for the next 24 months",
    x = "Year",
    y = "Projected ONI Index",
    caption = "ETS Model automatically generated by the forecast package"
  ) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", size = 14))

print(grafico_previsao_ets)


# 14. ADVANCED FORECAST: PROPHET MODEL (META/FACEBOOK) FOR MeanONI =============
if(!require(prophet)) install.packages("prophet")
library(prophet)

df_prophet <- df_oni %>%
  select(Data_Mes, MeanONI) %>%
  rename(ds = Data_Mes, y = MeanONI)

modelo_prophet <- prophet(df_prophet)

futuro_oni <- make_future_dataframe(modelo_prophet, periods = 24, freq = 'month')
previsao_prophet <- predict(modelo_prophet, futuro_oni)

cat("\nGenerating Prophet Main Chart...\n")
grafico_previsao_prophet <- plot(modelo_prophet, previsao_prophet) +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "darkred", alpha = 0.7) +
  geom_hline(yintercept = -0.5, linetype = "dashed", color = "darkblue", alpha = 0.7) +
  labs(
    title = "ONI Index Forecast using Machine Learning (Prophet)",
    x = "Year",
    y = "ONI Index"
  ) +
  theme_minimal()

print(grafico_previsao_prophet)

cat("\nGenerating Components Chart...\n")
grafico_componentes <- prophet_plot_components(modelo_prophet, previsao_prophet)