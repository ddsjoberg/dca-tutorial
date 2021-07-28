## ---- sas-install -----
/* source the dca macros from GitHub.com */
/* you can also navigate to GitHub.com and save the macros locally */
filename dca url "https://raw.githubusercontent.com/ddsjoberg/dca.sas/main/dca.sas";
filename stdca url "https://raw.githubusercontent.com/ddsjoberg/dca.sas/main/stdca.sas";
%include dca;
%include stdca;

## ---- sas-model -----
/* build logistic regression model */
PROC LOGISTIC DATA = test DESCENDING;
  MODEL am = mpg;
RUN;
