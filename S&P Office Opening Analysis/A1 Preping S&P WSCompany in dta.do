* Appending two Company Screeen Reports
cd "$DATA"
import excel using "Company Screening Report (1).xls", cellrange (A8) firstrow
cd "$CLEAN"
save "Company Screening Report p2.dta", replace

clear

cd "$DATA"
import excel using "Company Screening Report.xls", cellrange (A8) firstrow
cd "$CLEAN"
save "Company Screening Report p1.dta", replace

append using "Company Screening Report p2.dta"

save "Company Screening Report.dta", replace

* Converting Worldscope data into dta
clear

cd "$DATA"
import sas using "wrds_worldscope_company.sas7bdat"

cd "$CLEAN"
save "wrds_worldscope_company.dta", replace

clear