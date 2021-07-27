## ---- r-model -----
# build logistic regression model
mod <- glm(am ~ mpg, data = mtcars, family = binomial)
# model summary
gtsummary::tbl_regression(mod, intercept = TRUE)

## ---- r-model2 -----
# model summary
gtsummary::tbl_regression(mod, intercept = TRUE)
