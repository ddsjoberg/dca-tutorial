## ---- python-install -----
import dcurves
import pandas as pd
import numpy as np
import statsmodels.api as sm


## ---- python-import_cancer -----

df_cancer_dx = pd.read_csv('https://raw.githubusercontent.com/ddsjoberg/dca-tutorial/main/data/df_cancer_dx.csv')

## ---- python-model -----

mod1 = sm.GLM.from_formula('cancer ~ famhistory', data=df_cancer_dx, family=sm.families.Binomial())
mod1_results = mod1.fit()

print(mod1_results.summary())

## ---- python-dca_famhistory -----

dca_result_df1 = \
    dca(
        data=df_cancer_dx,
        outcome='cancer',
        modelnames=['famhistory']
    )

plot_graphs(
    plot_df=dca_result_df1
)

## ---- python-dca_famhistory2 -----

dca_result_df = \
        dca(
            data=df_cancer_dx,
            outcome='cancer',
            modelnames=['famhistory'],
            thresholds=np.arange(0, 0.36, 0.01),
        )

plot_graphs(
    plot_df=dca_result_df
)

## ---- python-model_multi -----

mod2 = sm.GLM.from_formula('cancer ~ marker + age + famhistory', data=df_cancer_dx, family=sm.families.Binomial())
mod2_results = mod2.fit()

print(mod2_results.summary())

## ---- python-dca_multi -----

dca_result_df = \
    dca(
        data=df_cancer_dx,
        outcome='cancer',
        modelnames=['famhistory', 'cancerpredmarker'],
        thresholds=np.arange(0,0.36,0.01)
    )

plot_graphs(
    plot_df=dca_result_df,
    y_limits=[-0.05, 0.2]
    )

## ---- python-dca_smooth -----

## ---- python-dca_smooth2 -----

## ---- python-pub_model -----

df_cancer_dx['logodds_brown'] = 0.75 * df_cancer_dx['famhistory'] + 0.26*df_cancer_dx['age'] - 17.5
df_cancer_dx['phat_brown'] = np.exp(df_cancer_dx['logodds_brown']) / (1 + np.exp(df_cancer_dx['logodds_brown']))

dca_result_df = \
    dca(
        data=df_cancer_dx,
        outcome='cancer',
        modelnames=['phat_brown'],
        thresholds=np.arange(0,0.36,0.01),
    )

plot_graphs(
    plot_df=dca_result_df,
    y_limits=[-0.05, 0.2],
    graph_type='net_benefit'
)

## ---- python-joint -----

## ---- python-dca_joint -----

## ---- python-dca_harm_simple -----

## ---- python-dca_harm -----

## ---- python-dca_table -----

## ---- python-dca_intervention -----

## ---- python-import_ttcancer -----

## ---- python-coxph -----

## ---- python-stdca_coxph -----

## ---- python-stdca_cmprsk -----

## ---- python-import_case_control -----

## ---- python-dca_case_control -----

## ---- python-cross_validation -----
