## ---- r-install -----
# install dcurves from CRAN
install.packages("dcurves")

# load package
library(dcurves)

## ---- r-model -----
# build logistic regression model
mod <- glm(am ~ mpg, data = mtcars, family = binomial)

# model summary
gtsummary::tbl_regression(mod, intercept = TRUE)
