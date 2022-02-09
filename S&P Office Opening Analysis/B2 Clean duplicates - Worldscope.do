/* Cleaning /de-dup Roadmap

1. Among the raw data, subset the unique ISIN data, save to PART1
2. Among the rest, i.e. the ISIN dups, remove type-S data
3. Among the rest, save the subset of unique ISIN data to PART2
4. Among the rest, keep the subset of unique ISIN entries with the most asset info, save to PART3
5. Bind together PART 1,2, and 3
*/


cd "$CLEAN"

use "Worldscope_company.dta", replace
drop if ISIN == ""
distinct ISIN

* Investigate in Worldscope ISIN duplicates
sort ISIN
quietly by ISIN:  gen dupISIN = cond(_N==1,0,_n)


tab dupISIN // note: most (6525) duplicates are pairs; 7 trios


* 1. Save Unique ISIN data
keep if dupISIN == 0 
save "WS clean unique pt1", replace

* 2. Look into ISIN-dups
use "Worldscope_company.dta", replace
drop if ISIN == ""
sort ISIN
quietly by ISIN:  gen dupISIN = cond(_N==1,0,_n)
keep if dupISIN > 0 // Keep only ISIN dups
drop dupISIN

	* 2. Save only "C" and remove "S" first
	keep if ITEM6100 == "C"
	distinct ISIN

* 3. Save the unique ISIN entries
sort ISIN
quietly by ISIN:  gen dupISIN = cond(_N==1,0,_n)
tab dupISIN
keep if dupISIN == 0
save "WS clean unique pt2", replace

* 4. Look into the type-C ISIN-dups 

use "Worldscope_company.dta", replace
drop if ISIN == ""
sort ISIN
quietly by ISIN:  gen dupISIN = cond(_N==1,0,_n)
keep if dupISIN > 0 // Keep only ISIN dups
drop dupISIN
keep if ITEM6100 == "C"
sort ISIN
quietly by ISIN:  gen dupISIN = cond(_N==1,0,_n)
keep if dupISIN > 0
order ISIN dupISIN WSID WSIDP

	* 4. Merge with WSFinancials
	merge 1:1 WSID ISIN WSIDP using "wrds_worldscope_funda_renamed_deduped.dta"
	keep if _merge==3 | _merge == 1


	order   ISIN dupISIN WSID WSIDP _merge  

	* 4. Remvoe entries with financial data missing IF its ISIN-dup counterpart has financial data
	sort ISIN _merge
	quietly by ISIN _merge:  gen dupISINmerge = cond(_N==1,0,_n)
	sort ISIN dupISIN _merge
	order dupISINmerge
	drop if (dupISINmerge == 0 & _merge == 1)
	
	distinct ISIN

	drop dupISINmerge dupISIN

	sort ISIN
	quietly by ISIN :  gen dupISIN = cond(_N==1,0,_n)
	sort ISIN dupISIN
	order ISIN dupISIN
	
	* 4. Save the de-dupded data
	savesome if dupISIN==0 using "WS clean unique pt3A", replace  
	drop if dupISIN==0

	* 4. Among the data not yet de-duped, keep the data with the largest gross income (if gross income is missing, use operating income)
	order ISIN dupISIN item1100 item1250
	gsort ISIN  item1100 item1250 item1250
	duplicates drop ISIN,force
	
	* 4. Save this last de-duped data
	cd "$CLEAN"
	save "WS clean unique pt3B", replace

		* 4. Warning: there is an ISIN "US89157A1016" associated with 3 different entries (WSID: 063554208	89157A101	063554208, WSIDP: missing), where none of the ISIN or WSID could match any record in the financial data. I have de-duped this casually.
		
* 5 Append all clean de-duped data together
append using "WS clean unique pt1" "WS clean unique pt2" "WS clean unique pt3A"

drop dup*
drop _merge
		
distinct ISIN

cd "$MERGE"
save "WS clean unique full", replace