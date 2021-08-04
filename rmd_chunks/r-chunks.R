## ---- r-install -----
# install dcurves, tidyverse, gtsummary, and broom from CRAN
install.packages(c("dcurves", "tidyverse", "gtsummary", "broom", "survival"))

# load package
library(dcurves)
library(tidyverse)
library(gtsummary)

## ---- r-import_cancer -----
# import data
df_cancer_dx <-
  readr::read_csv(
    file = "https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_cancer_dx.csv"
  )

# summarize data
df_cancer_dx %>%
  select(-patientid) %>%
  tbl_summary(type = all_dichotomous() ~ "categorical")

## ---- r-model -----
# build logistic regression model
mod1 <- glm(cancer ~ famhistory, data = df_cancer_dx, family = binomial)

# model summary
mod1_summary <- tbl_regression(mod1, exponentiate = TRUE)
mod1_summary

## ---- r-dca_famhistory -----
dca(cancer ~ famhistory, data = df_cancer_dx) %>%
  plot()

## ---- r-dca_famhistory2 -----
dca(cancer ~ famhistory,
    data = df_cancer_dx,
    thresholds = seq(0, 0.35, 0.01)) %>%
  plot()

## ---- r-model_multi -----
# build multivariable logistic regression model
mod2 = glm(cancer ~ marker + age + famhistory, data = df_cancer_dx, family=binomial)

# summarize model
tbl_regression(mod2, exponentiate = TRUE)

# add predicted values from model to data set
df_cancer_dx <-
  df_cancer_dx %>%
  mutate(
    cancerpredmarker =
      broom::augment(mod2, type.predict = "response") %>%
      pull(".fitted")
  )

## ---- r-dca_multi -----
dca(cancer ~ famhistory + cancerpredmarker,
    data = df_cancer_dx,
    thresholds = seq(0, 0.35, 0.01)) %>%
  plot(smooth = TRUE)

## ---- r-pub_model -----
# Use the coefficients from the Brown model
df_cancer_dx <-
  df_cancer_dx %>%
  mutate(
    logodds_brown = 0.75 * famhistory + 0.26 * age - 17.5,
    phat_brown = exp(logodds_brown) / (1 + exp(logodds_brown))
  )

# Run the decision curve
dca(cancer ~ phat_brown,
    data = df_cancer_dx,
    thresholds = seq(0, 0.35, 0.01)) %>%
  plot(smooth = TRUE)

## ---- r-joint -----
#Create a variable for the strategy of treating only high risk patients
df_cancer_dx <-
  df_cancer_dx %>%
  mutate(
    # This will be 1 for treat and 0 for don’t treat
    high_risk = ifelse(risk_group=="high", 1, 0),
    # Treat based on Joint Approach
    joint = ifelse(risk_group=="high" | cancerpredmarker > 0.15, 1, 0),
    # Treat based on Conditional Approach
    conditional =
      ifelse(risk_group=="high" | (risk_group=="intermediate" & cancerpredmarker > 0.15), 1, 0)
  )

## ---- r-dca_joint -----
dca(cancer ~ high_risk + joint + conditional,
    data = df_cancer_dx,
    thresholds = seq(0, 0.35, 0.01)) %>%
  plot(smooth = TRUE)

## ---- r-dca_harm -----
# the harm of measuring the marker is stored in a scalar
harm_marker <- 0.0333
# in the conditional test, only patients at intermediate risk
# have their marker measured
# harm of the conditional approach is proportion of patients who have the marker
# measured multiplied by the harm
harm_conditional <- mean(df_cancer_dx$risk_group == "intermediate") * harm_marker

# Run the decision curve
dca(cancer ~ high_risk + joint + conditional,
    data = df_cancer_dx,
    thresholds = seq(0, 0.35, 0.01),
    harm = list(joint = harm_marker, conditional = harm_conditional)) %>%
  plot(smooth = TRUE)


## ---- r-dca_table -----
dca(cancer ~ marker,
    data = df_cancer_dx,
    as_probability = "marker",
    thresholds = seq(0.05, 0.35, 0.15)) %>%
  as_tibble() %>%
  select(label, threshold, net_benefit) %>%
  gt::gt() %>%
  gt::fmt_percent(columns = threshold, decimals = 0) %>%
  gt::fmt(columns = net_benefit, fns = function(x) style_sigfig(x, digits = 3)) %>%
  gt::cols_label(label = "Strategy",
                 threshold = "Decision Threshold",
                 net_benefit = "Net Benefit") %>%
  gt::cols_align("left", columns = label)

## ---- r-dca_intervention -----
dca(cancer ~ marker,
    data = df_cancer_dx,
    as_probability = "marker",
    thresholds = seq(0.05, 0.35, 0.01)) %>%
  net_intervention_avoided() %>%
  plot(smooth = TRUE)

## ---- r-import_ttcancer -----
# import data
df_time_to_cancer_dx <-
  readr::read_csv(
    file = "https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_time_to_cancer_dx.csv"
  )

## ---- r-coxph -----
# Load survival library
library(survival)

# Run the cox model
coxmod = coxph(Surv(ttcancer, cancer) ~ age + famhistory + marker, data = df_time_to_cancer_dx)

df_time_to_cancer_dx <-
  df_time_to_cancer_dx %>%
  mutate(
    pr_failure18 =
      1 - summary(survfit(coxmod, newdata = df_time_to_cancer_dx), times=1.5)$surv[1,]
  )

## ---- r-stdca_coxph -----
dca(Surv(ttcancer, cancer) ~ pr_failure18,
    data = df_time_to_cancer_dx,
    time = 1.5,
    thresholds = seq(0, 0.5, 0.01)) %>%
  plot(smooth = TRUE)
