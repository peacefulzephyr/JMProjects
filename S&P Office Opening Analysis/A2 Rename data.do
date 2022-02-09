* Renaming variables
cd "$CLEAN"

use "wrds_worldscope_company.dta"
rename ITEM6008 ISIN
rename ITEM6003 Name
rename ITEM6004 CUSIP
rename ITEM6006 SEDOL
rename ITEM6030 Website
rename ITEM6031 Phone
rename ITEM6033 Fax
rename ITEM7041 Refinitiv
rename ITEM6035 WSID
rename ITEM6105 WSIDP
save "Worldscope_company.dta", replace

use "Company Screening Report.dta"
rename PrimaryISIN ISIN

save "SPratings.dta", replace

