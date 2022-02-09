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
use "S&P-WS merged", replace
distinct ISIN


* Temporarily drop all vars except rating history
keep SPEntityCreditRatingHistory ISIN WSID WSIDP
order ISIN SPEntityCreditRatingHistory

split SPEntityCreditRatingHistory, parse("Rating: ") gen(RatingHis)


unab RatingHiss : RatingHis*
local count : word count `RatingHiss' // return number of RatingHis vars
forvalues i = 2/`count' {
	display `i' 
	gen Rating`i' = substr(RatingHis`i', 1, strpos(RatingHis`i', "Rating Range: ")-1)
	gen RatingRange`i' = strtrim(substr(RatingHis`i', strpos(RatingHis`i',"Rating Range: ")+14, .))
	gen RatingRangeFrom`i' = substr(RatingRange`i', 1, strpos(RatingRange`i', " to "))
	//gen RatingRangeTo`i' = substr(RatingRange`i', strpos(RatingRange`i', " to ")+4, .)
}



forvalues i = 2/35 {
	gen Rating_Range_From`i' = date(subinstr(RatingRangeFrom`i',"-","", .), "MDY")
	//gen Rating_Range_To`i' = date(subinstr(RatingRangeTo`i',"-","", .), "MDY")
	format Rating_Range_From`i' %td
	//format Rating_Range_To`i' %td
}

egen startdate = rowmin(Rating_Range_From*)
format startdate`i' %td

drop RatingRange* RatingHis*
order ISIN SPEntityCreditRatingHistory startdate Rating* Rating_Range_From*

save "S&P history temp", replace

use "S&P history temp", replace