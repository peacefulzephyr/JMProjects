* Clean the financial data
cd "$DATA"
use "wrds_worldscope_funda.dta", replace
rename item6035 WSID
rename item6008 ISIN
rename item6105 WSIDP


sort ISIN WSID WSIDP
quietly by ISIN WSID WSIDP:  gen dup = cond(_N==1,0,_n)
keep if dup < 2 // Keep only ISIN dups

distinct ISIN WSID WSIDP, joint

cd "$CLEAN"
save "wrds_worldscope_funda_renamed_deduped.dta", replace

