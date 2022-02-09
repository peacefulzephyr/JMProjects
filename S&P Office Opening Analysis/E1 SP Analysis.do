clear

** Set macros
global dir "C:/My documents/Siko"
global DATA "$dir/Data"
global OUTPUT "$dir/Output"
global CODE "$dir/Code"
global CLEAN "$dir/Data/AB Cleaning"
global MERGE "$dir/Data/C Merging"
matrix drop _all
scalar drop _all

cd "$OUTPUT"
use "SP-WS-fonda.dta"

** Reformat ISIN
encode ISIN,gen(ISIN1)
drop ISIN
rename ISIN1 ISIN


** Generate Variables
xtset ISIN FYend


rename SPopenbyFYend Local
gen Size = log(item7230)
//gen EBITDA = item1401 + item1251 + item1151 - item1255
//gen IntCov =  EBITDA / item1251
//gen EBSales = EBITDA / item1251
gen Lev = (item3255 + item3051) / item2999
//gen DebtEB = (item3255 + item3051) / EBITDA
//gen NegDebtEB = (DebtEB < 0)
//gen Cash = item2005
//gen PPE = item2501
//gen CAPEX = item4601 / item2999
//gen ROA = EBITDA / item2999

//ssc install asrol, replace // generate rolling variable EAVOL
//tsfill
//bys ISIN: asrol EBITDA, stat (sd)  win (FY 5)  min (3)
//rename EBITDA_sd5 EAVOL

* DiD Regressions
// xtreg rating3mafterFYend_num Local Size IntCov EBSales Lev DebtEB NegDebtEB Cash PPE Capex EAVol ROA

xtreg rating3mafterFYend_num Local Size Lev i.FY, vce(robust)
estimates store A, title(Rating_3mon_yearFE)
xtreg rating6mafterFYend_num Local Size Lev i.FY, vce(robust)
estimates store B, title(Rating_6mon_yearFE)
xtreg rating12mafterFYend_num Local Size Lev i.FY, vce(robust)
estimates store C, title(Rating_12mon_yearFE)

xtreg rating3mafterFYend_num Local Size Lev i.FY, fe vce(robust)
estimates store D, title(Rating_3mon_year+firmFE)
xtreg rating6mafterFYend_num Local Size Lev i.FY, fe vce(robust)
estimates store E, title(Rating_6mon_year+firmFE)
xtreg rating12mafterFYend_num Local Size Lev i.FY, fe vce(robust)
estimates store F, title(Rating_12mon_year+firmFE)

outreg2 [A B C D E F] using table5, keep(Local Size Lev) nocons replace excel