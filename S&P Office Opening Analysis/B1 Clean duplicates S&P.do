cd "$CLEAN"
use "SPratings.dta", replace

* Remove SPratings' duplicates that have identical values in all variables
unab vlist : _all
sort `vlist'
quietly by `vlist':  gen dup = cond(_N==1,0,_n)
drop if dup>1
drop dup


* Make ISIN Unique
** Divide SPratings into parts w/ and w/o ISIN #
keep if ISIN == "-"
save "SPratings_noISIN.dta", replace

use "SPratings.dta", replace
keep if ISIN != "-"
save "SPratings_ISIN.dta", replace


use "SPratings_ISIN.dta", replace
* Remove SPratings' duplicates that have identical values in all variables
unab vlist : _all
sort `vlist'
quietly by `vlist':  gen dup = cond(_N==1,0,_n)
drop if dup>1
drop dup

* Remove SPratings' duplicates that have identical values in all important variables
global important_identifiers CompanyName SPEntityID SPEntityCreditRatingHistory GeographicRegion CountryRegionofIncorporation PrimaryAddress ExcelCompanyID LEICICI SICCodesPrimaryCodeOnly CIK CompanyCUSIP Website
sort $important_identifiers
quietly by $important_identifiers:  gen dup = cond(_N==1,0,_n)
drop if dup>1
drop dup

save "SPratings_deduped", replace

distinct ISIN

** Investigate into duplicated ISIN
sort ISIN
quietly by ISIN:  gen dupISIN = cond(_N==1,0,_n)
keep if dupISIN > 0
order dupISIN
sort dupISIN ISIN 

save "ISIN dups", replace

** Divide duplicates into 2 parts; 1 with entries differing with each other ONLY in LEICIC; the other with entries that are VERY different from each other
use "ISIN dups.dta", replace
global all_but_LEICICI CompanyName ExchangeTicker SPEntityID SPEntityCreditRatingHistory GeographicRegion CountryRegionofIncorporation HeadquartersCountryRegion PrimaryAddress StateofIncorporation StateRegionFromPrimaryAddres HeadquartersCountryRegionof ISIN ExcelCompanyID LEICICI SICCodesPrimaryCodeOnly CIK CompanyCUSIP Website CompanyType
sort $all_but_LEICICI
quietly by $all_but_LEICICI:  gen dup = cond(_N==1,0,_n)
keep if dup > 0
order dup ISIN LEICICI
sort ISIN
drop dup
save "ISINduplicates that differ ONLY in LEICICI", replace // this is part 1

use "ISIN dups.dta", replace
sort $all_but_LEICICI
quietly by $all_but_LEICICI:  gen dup = cond(_N==1,0,_n)
keep if dup == 0
order dup ISIN LEICICI
sort ISIN
drop dup
*** now we have part 2; as we can see, 9 pairs of ISIN-duplicates have different company names, rating history, or websites
** Save them and append to the S&P data without ISIN, to match based on variables other than ISIN
drop dupISIN
sort ISIN

append using "SPratings_noISIN.dta"
save "SPratings_noISIN.dta", replace


** Revmove ISIN-duplicates that are only different in LEICICI
*** Build a dataset with unique ISINs or duplicated-1st occurence
use "SPratings_deduped", replace

sort ISIN
quietly by ISIN:  gen dupISIN = cond(_N==1,0,_n)
keep if dupISIN <= 1
order dupISIN
sort dupISIN ISIN 
save "SPratings_unique ISIN or 1st occurence", replace

use "ISIN dups.dta", replace
keep if dupISIN == 2
rename LEICICI LEICICI2
keep ISIN LEICICI2
save "dupISIN 2nd occurence", replace

use "ISIN dups.dta", replace
keep if dupISIN == 3
rename LEICICI LEICICI3
keep ISIN LEICICI3
save "dupISIN 3rd occurence", replace 

use "ISIN dups.dta", replace
keep if dupISIN == 4
rename LEICICI LEICICI4
keep ISIN LEICICI4
save "dupISIN 4th occurence", replace

use "SPratings_unique ISIN or 1st occurence", replace
merge 1:1 ISIN using "dupISIN 2nd occurence.dta"
drop _merge
merge 1:1 ISIN using "dupISIN 3rd occurence.dta"
drop _merge
merge 1:1 ISIN using "dupISIN 4th occurence.dta"
drop _merge

drop dupISIN
distinct ISIN // ISIN dataset cleaned; all entries are unique

cd "$MERGE"
save "SP ratings ISIN clean ready to merge.dta", replace