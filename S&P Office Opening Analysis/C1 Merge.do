clear

** Set macros
global dir "C:\My documents\Siko"
global DATA "$dir/Data"
global OUTPUT "$dir/Output"
global CODE "$dir/Code"
global CLEAN "$dir/Data/AB Cleaning"
global MERGE "$dir/Data/C Merging"
matrix drop _all
scalar drop _all


cd "$MERGE"
use "SP ratings ISIN clean ready to merge.dta", replace
distinct ISIN

merge 1:1 ISIN using "WS clean unique full"
keep if _merge != 2

cd "$OUTPUT"
save "S&P-WS merged", replace