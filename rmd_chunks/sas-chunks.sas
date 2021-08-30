## ---- sas-install -----
/* source the dca macros from GitHub.com */
/* you can also navigate to GitHub.com and save the macros locally */
FILENAME dca URL "https://raw.githubusercontent.com/ddsjoberg/dca.sas/main/dca.sas";
FILENAME stdca URL "https://raw.githubusercontent.com/ddsjoberg/dca.sas/main/stdca.sas";
%INCLUDE dca;
%INCLUDE stdca;

## ---- sas-import_cancer -----
FILENAME data_binary URL "https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_cancer_dx.csv";

PROC IMPORT FILE = data_binary OUT = work.data_binary DBMS = CSV;
RUN;

## ---- sas-model -----
* Test whether family history is associated with cancer;
PROC LOGISTIC DATA = data_binary DESCENDING;
  MODEL cancer = famhistory;
RUN;

## ---- sas-dca_famhistory -----
* Run the decision curve: family history is coded as 0 or 1, i.e. a probability, so no need to specify the “probability” option;
%DCA(data = dca, outcome = cancer, predictors = famhistory, graph = yes);

## ---- sas-dca_famhistory2 -----
%DCA(data = dca, outcome = cancer, predictors = famhistory, graph = yes, xstop = 0.35);

## ---- sas-model_multi -----
* run the multivariable model;
PROC LOGISTIC DATA = data_binary DESCENDING;
  MODEL cancer = marker age famhistory;
  * save out predictions in the form of probabilities;
  SCORE CLM OUT=dca (RENAME=(P_1 = cancerpredmarker));
RUN;

## ---- sas-dca_multi -----
%DCA(data = dca, outcome = cancer, predictors = cancerpredmarker famhistory, graph = yes, xstop = 0.35);

## ---- sas-pub_model -----
DATA data_binary;
  SET data_binary;
  * use the coefficients from the Brown model;
  logodds_Brown = 0.75 * (famhistory) + 0.26 * (age) - 17.5;
  * convert to predicted probability;
  phat_Brown = exp(logodds_Brown) / (1 + exp(logodds_Brown));
RUN;

* run the decision curve;
%DCA(data = data_binary, outcome = cancer, predictors = phat_Brown, xstop = 0.35);

## ---- sas-joint -----
* Create a variable for the strategy of treating only high risk patients;
* This will be 1 for treat and 0 for don't treat;
DATA data_binary;
  SET data_binary;

  high_risk = (risk_group = "high");
  LABEL high_risk="Treat Only High Risk Group";

  * Treat based on joint approach;
  joint = (risk_group="high") | (cancerpredmarker > 0.15);
  LABEL joint = "Treat via Joint Approach";

  * Treat based on conditional approach;
  conditional = (risk_group = "high") | (risk_group = "intermediate" & cancerpredmarker > 0.15);
  LABEL conditional = "Treat via Conditional Approach";
RUN;

## ---- sas-dca_joint -----
%DCA(data = data_binary, outcome = cancer,
     predictors = high_risk joint conditional,
     graph = yes, xstop = 0.35);

## ---- sas-dca_harm -----
* the harm of measuring the marker is stored as a macro variable;
%LET harm_marker = 0.0333;

*in the conditional test, only patients at intermediate risk have their marker measured;
DATA data_binary;
  SET data_binary;
  intermediate_risk = (risk_group = "intermediate");
RUN;

* calculate the proportion of patients who have the marker and save out mean risk;
PROC MEANS DATA = data_binary;
 VAR intermediate_risk;
 OUTPUT OUT = meanrisk MEAN = meanrisk;
RUN;

DATA _NULL_;
  SET meanrisk;
  CALL SYMPUT("meanrisk", meanrisk);
RUN;

* harm of the conditional approach is proportion of patients who have the marker measured multiplied by the harm;
%LET harm_conditional = %SYSEVALF(&meanrisk.*&harm_marker.);

* Run the decision curve;
%DCA(data = data_binary, outcome = cancer, predictors = high_risk joint conditional,
     harm = 0 &harm_marker. &harm_conditional., xstop = 0.35);

## ---- sas-dca_table -----
*Run the decision curve and save out net benefit results, specify xby=0.05 since we want 5% increments;
%DCA(data = data_binary, outcome = cancer, predictors = marker,
     probability = no, xstart = 0.05,
     xstop = 0.35, xby = 0.05, graph = no, out = dcamarker);

* Load the data set with the net benefit results;
DATA dcamarker;
  SET dcamarker;
  * Calculate difference between marker and treat all;
  * Our standard approach is to biopsy everyone so this tells us how much better we do with the marker;
  advantage = marker - all
RUN;

## ---- sas-dca_intervention -----
%DCA(data = data_binary, outcome = cancer, predictors = marker, probability = no,
     intervention = yes, xstart = 0.05, xstop = 0.35);

## ---- sas-import_ttcancer -----

## ---- sas-coxph -----

## ---- sas-stdca_coxph -----

## ---- sas-stdca_cmprsk -----

## ---- sas-import_case_control -----

## ---- sas-dca_case_control -----

## ---- sas-cross_validation -----
