S&P ratings cleaning and analysis

Organization & Required Files

- root directory
	- Code
		all of the do & r files	
	- Data
		S&P ratings raw data "Company Screening Report.xls" & "Company Screening Report (1).xls"
		Worldscope company raw data "wrds_worldscope_company.sas7bdat"
		Worldscope financials raw data "wrds_worldscope_funda.dta"
		Letter-rating to numeric conversion table "Rating Numeric.xlsx"
		S&P office opening data
		- "AB Cleaning" (empty folder)
		- "C Merging" (empty folder)
	- Output (empty folder)


Sequence of running code files
1. In "Masterfile.do" & "E1 SP Analysis.do", change line [global dir ""] into [global dir "local directory"]
2. Run "Masterfile.do"
3. Run "Panel builder.R" (make sure to install packages first)
4. Run "D2 Panel builder.r" (make sure to install packages first)
5. Run "D3 Final Merging SP-WS & fonda.r"
6. Edit "E1 SP Analysis.do": 
	6.1 generate control variables (line 28-37)
	6.2 uncomment all lines starting with "//"
	6.3 make sure your computer is powerful, as "tsfill" command take a lot of computing power (line 40)
	6.4 add control variables to all xtreg models (line 47-59), following line 45
7. Run "E1 SP Analysis.do"

Key Files Produced
Regression Output: Output/table5.xml
Final Panel Data: Output/SP-WS-fonda.dta