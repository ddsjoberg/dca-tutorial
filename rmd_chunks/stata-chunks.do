## ---- stata-install -----
* install dca functions from GitHub.com
net install dca, from("https://raw.github.com/ddsjoberg/dca.stata/master/") replace

## ---- stata-model -----
* build logistic regression model
logit am mpg
