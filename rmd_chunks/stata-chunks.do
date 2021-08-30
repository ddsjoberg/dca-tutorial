## ---- stata-install -----
* install dca functions from GitHub.com
net install dca, from("https://raw.github.com/ddsjoberg/dca.stata/master/") replace

## ---- stata-import_cancer -----
* import data
import delimited "https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_cancer_dx.csv", clear

## ---- stata-model -----
* Test whether family history is associated with cancer
logit cancer famhistory

## ---- stata-dca_famhistory -----
* Run the decision curve: family history is coded as 0 or 1, i.e. a probability
* so no need to specify the “probability” option
dca cancer famhistory

## ---- stata-dca_famhistory2 -----
dca cancer famhistory, xstop(0.35) xlabel(0(0.05)0.35)

## ---- stata-model_multi -----
* run the multivariable model
logit cancer marker age famhistory

* save out predictions in the form of probabilities
predict cancerpredmarker

## ---- stata-dca_multi -----
dca cancer cancerpredmarker famhistory, xstop(0.35) xlabel(0(0.05)0.35)

## ---- stata-pub_model -----
* Use the coefficients from the Brown model
g logodds_Brown = 0.75*(famhistory) + 0.26*(age) - 17.5

* Convert to predicted probability
g phat_Brown = invlogit(logodds_Brown)
label var phat_Brown "Risk from Brown Model"

* Run the decision curve
dca cancer phat_Brown, xstop(0.35) xlabel(0(0.05)0.35)

## ---- stata-joint -----
* Create a variable for the strategy of treating only high risk patients
* This will be 1 for treat and 0 for don’t treat
g high_risk = risk_group=="high"
label var high_risk "Treat Only High Risk Group"

* Treat based on Joint Approach
g joint = risk_group =="high" | cancerpredmarker > 0.15
label var joint "Treat via Joint Approach"

* Treat based on Conditional Approach
g conditional = risk_group=="high" | ///
  (risk_group == "intermediate" & cancerpredmarker > 0.15)
label var conditional "Treat via Conditional Approach"

## ---- stata-dca_joint -----
dca cancer high_risk joint conditional, xstop(0.35) xlabel(0(0.05)0.35)

## ---- stata-dca_harm -----
* the harm of measuring the marker is stored in a local
local harm_marker = 0.0333
* in the conditional test, only patients at intermediate risk have their marker measured
g intermediate_risk = (risk_group=="intermediate")

* harm of the conditional approach is proportion of patients who have the marker measured multiplied by the harm
sum intermediate_risk
local harm_conditional = r(mean)*`harm_marker'

* Run the decision curve
dca cancer high_risk joint conditional, ///
 harm(0 `harm_marker' `harm_conditional') xstop(0.35) xlabel(0(0.05)0.35)

## ---- stata-dca_table -----
* Run the decision curve and save out net benefit results
* Specifying xby(.05) since we’d want 5% increments
dca cancer marker, prob(no) xstart(0.05) xstop(0.35) xby(0.05) nograph ///
 saving("DCA Output marker.dta", replace)

* Load the data set with the net benefit results
use "DCA Output marker.dta", clear

* Calculate difference between marker and treat all
* Our standard approach is to biopsy everyone so this tells us
* how much better we do with the marker
g advantage = marker – all
label var advantage "Increase in net benefit from using Marker model"

## ---- stata-dca_intervention -----
dca cancer marker, prob(no) intervention xstart(0.05) xstop(0.35)

## ---- stata-import_ttcancer -----
* import data
import delimited "https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_time_to_cancer_dx.csv", clear

* Declaring survival time data: follow-up time variable is ttcancer and the event is cancer
stset ttcancer, f(cancer)

## ---- stata-coxph -----
* Run the cox model and save out baseline survival in the “surv_func” variable
stcox age famhistory marker, basesurv(surv_func)

* get linear predictor for calculation of risk
predict xb, xb

* Obtain baseline survival at 1.5 years = 18 months
sum surv_func if _t <= 1.5

* We want the survival closest to 1.5 years
* This will be the lowest survival rate for all survival times ≤1.5
local base = r(min)

* Convert to a probability
g pr_failure18 = 1 - `base'^exp(xb)
label var pr_failure18 "Probability of Failure at 18 months"

## ---- stata-stdca_coxph -----
stdca pr_failure18, timepoint(1.5) xstop(0.5) smooth

## ---- stata-stdca_cmprsk -----
g status = 0
replace status = 1 if cancer==1
replace status = 2 if cancer==0 & dead==1

* We declare our survival data with the new event variable
stset ttcancer, f(status=1)

* Run the decision curve specifying the competing risk option
stdca pr_failure18, timepoint(1.5) compet1(2) smooth xstop(.5)

## ---- stata-import_case_control -----
* import data
import delimited "https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_cancer_dx_case_control.csv", clear

## ---- stata-dca_case_control -----
dca casecontrol cancerpredmarker, prevalence(0.20) xstop(0.50)

## ---- stata-cross_validation -----
