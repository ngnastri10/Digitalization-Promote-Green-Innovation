/*******************************************************************************
Description: 	This program takes raw IPC codes from the WIPO website and prepares
				it to be matched with the WIPO patent data. 
				
				
			
			
Date created: 	September 18th, 2023
Created by: 	Nico Nastri

Date edited:	September 25th, 2023
Edited by:		Nico Nastri
*******************************************************************************/ 

****************
* Set Up Files *
****************
***********************************************************************************
* NOTE: To run this code change the PROJECT global variable to your own directory *
***********************************************************************************
clear all

* Set up global directories
global project "C:\Users\nn3495a\Desktop\Work\Brunel & Poole"
global datafolder "$project\Data"
global workingfolder "$project\Working"
global resultsfolder "$project\Results"

* Set up folders if necessary
cap mkdir "$workingfolder"

* Other set up 
*set maxvar 10000
cap mkdir "$workingfolder\Logs"
cap log close
log using "$workingfolder\Logs\Log_9.15.23", text replace

********************************************************************************

* Import Raw IPC Codes
import excel "$datafolder\Raw IPC Codes.xlsx", sheet("Sheet1") clear

********************************************************************************
******************************* Notes On The Code ******************************
********************************************************************************

/* Notes on IPC Codes: 

		1) The WIPO website uses shorthand for every code that starts with the same
		   4 digits. This code explicitly makes all 4 or 8 digit codes. 
		   
		2) If we observed "-" this means every code in between the two numbers is 
		   a green patent. For example 01/05-01/44 means all patents between 05 & 44
		   are green.
		
		3) First Code Only: In the code there is a variable fcode_only. This 
		   is a dummy for IPC codes where the range of codes is (for example) 
		   17/00 - 20/00. We interpret this as every code 17/00, 18/00, 19/00, 20/00
		   is a green code. However if 17/01 etc. exists, those are not green.
*/

********************************************************************************
********* Generate Individual Codes for All IPC Codes Appearing as "-" *********
********************************************************************************

**********************************************************
** Split Codes Into Prefix & Codes We Want to Parse Out **
**********************************************************
		
* Find prefix of each code
gen prefix = substr(B,1,4) 

* Gen complement of prefix
gen comp = substr(B,5,.)

* Split the codes into seperate variables
split comp, gen(raw_code) parse(,) notrim

****************************************************
** Prepare All Info on Codes We Want to Parse Out **
****************************************************

* Make variable to determine how many codes we need to loop over
gen ncomm = length(B) - length(subinstr(B, ",", "", .)) + 1
gen ndash = length(B) - length(subinstr(B, "-", "", .))

* Make Dummy for codes that have "-"
qui sum ncomm
forvalues x = 1/`r(max)' {
	
	* Check if code has "-".
	gen ndash`x' = length(raw_code`x') - length(subinstr(raw_code`x', "-", "", .))

}

* Split codes that have "-" to find upper & lower bound
qui sum ndash
forvalues x = 1/`r(max)' {
	
	* Split again if we have codes with "-"
	split raw_code`x', gen(rc_dash`x'_) parse(-) notrim
	
	forvalues y = 1/2 {
		
		* Fix Split code for those that don't actually have "-"
		replace rc_dash`x'_`y' = "" if ndash`x' == 0 
		
		* Split upper & lower bound into their prefix & suffix
		split rc_dash`x'_`y', gen(dpref`x'_`y'_) parse(/) notrim
		
		forvalues z = 1/2 {
			
			* First destring last numbers
			destring dpref`x'_`y'_`z', replace

		}	
	
	}
	
	* Make dummy indicating only the first code changes
	gen fcode_only`x' = dpref`x'_1_1 != dpref`x'_2_1
	
	* Calculate difference between upper & lower bound
	gen dif`x' = dpref`x'_2_2 - dpref`x'_1_2
	replace dif`x' = dpref`x'_2_1 - dpref`x'_1_1 if fcode_only`x' == 1
	
}

****************************************************************
** Use Generated Variables to Create All Parsed Out IPC Codes **
****************************************************************

forvalues y = 1/2 {
	
	* Check how many variables we will need to generate
	qui sum dif`y' 
	local top`y' = `r(max)'+1
	
	* Generate starting point
	gen dif`y'_h1 = dpref`y'_1_2
	replace dif`y'_h1 = dpref`y'_1_1 if fcode_only`y' == 1
	
	forvalues x = 2/`top`y'' {
	
		* Parse out all numbers in each set of codes with "-"
		local i = `x'-1
		gen dif`y'_h`x' = dif`y'_h`i'+1 if dif`y'_h`i' < dpref`y'_2_2 & fcode_only`y' != 1
		replace dif`y'_h`x' = dif`y'_h`i'+1 if dif`y'_h`i' < dpref`y'_2_1 & fcode_only`y' == 1
		
	}	
	
}

* String all variables & merge with stubs
forvalues y = 1/2 {
	
	forvalues x = 1/`top`y'' {
	
		* Make All variables String
		qui tostring dif`y'_h`x', replace
		qui tostring dpref`y'_1_1, replace
	
		* Fix empty observations
		replace dif`y'_h`x' = "" if dif`y'_h`x' == "."
		
		* Add "0" infront of single digit codes
		qui gen test0 = length(dif`y'_h`x')
		qui replace dif`y'_h`x' = "0" + dif`y'_h`x' if test0 == 1 & fcode_only`y' != 1
		drop test0
		
		* Merge with stub
		replace dif`y'_h`x' = dpref`y'_1_1 + "/" + dif`y'_h`x' if dif`y'_h`x' != "" & fcode_only`y' != 1
		replace dif`y'_h`x' = dif`y'_h`x' + "/" + "00" if dif`y'_h`x' != "" & fcode_only`y' == 1
		
	}
}


* Fix names of variables to be consistent
qui sum dif1
local y = `r(max)'+1
qui sum dif2
local top = `r(max)'+1
forvalues x = 1/`top' {
	local ++y
	
	* Rename all of variables with dif2 to dif1 starting from where dif1 ends
	rename dif2_h`x' dif1_h`y'
	
}

* Merge with first 4 digit prefix
* First calculate total # of variables we created
forvalues x = 1/2 {
	
	* Get total number of variables we created
	qui sum dif`x'
	local test`x' = `r(max)'+1
	
}

* This is total number of variables we created
local var_num = `test1' + `test2'
display `var_num'

forvalues x = 1/`var_num' {
	
	* Add 4 digit prefix to parsed out codes
	replace dif1_h`x' = prefix + " " + dif1_h`x' if dif1_h`x' != ""
}


********************************************************************************
************ Generate Individual Codes for All IPC Codes Without "-" ***********
********************************************************************************

* Generate Individual IPC codes for all codes without "-"
qui sum ncomm
local y = `r(max)'
forvalues x = 1/`y' {
	
	* Generate final codes
	if `x' == 1 {
		gen green_code`x' = prefix + " " + raw_code`x' if ndash == 0
	}
	else {
		gen green_code`x' = prefix + " " + raw_code`x' if raw_code`x' != "" & ndash == 0
	}
}

********************************************************************************
******** Add Parsed Out Codes to "Green Codes" & Reshape for Final Copy ********
********************************************************************************

forvalues x = 1/`var_num' {
	
	local y = `x'+`r(max)'
	
	* Generate final codes
	gen green_code`y' = dif1_h`x'
}

* Keep variables we want before reshaping
bysort B: gen check = _n
drop if check > 1
keep A B green_code*

* Reshape file
reshape long green_code, i(B) j(index)
drop if green_code == ""

* Remove space in between the codes (strange non-space character appears)
forvalues x = 1/13 {
	gen check`x' = substr(green_code,`x', 1)
	gen type`x' = regexm(check`x', "[0-9A-Z/]$")
	replace check`x' = "" if type`x' == 0 

}

order check*, last
egen hold = concat(check1-check13)
replace green_code = hold

* Keep only Unique Green Code's
bys green_code: gen check = _n
keep if check == 1
keep green_code
rename green_code ipc_code

********************************************************************************
************* Create Global Macro w/ List of Variables of 4 Digits *************
********************************************************************************

preserve

* Keep the codes with 4
keep if length(ipc_code) == 4

* Create local variable with string of just those codes
levelsof ipc_code, local(ipc_code)
count if ipc_code != ""
local first = ipc_code[1]
local last = ipc_code[`r(N)']

foreach x in `ipc_code' {
	gen hold`x' = "`x'"
	gen s`x' = " "
	
}

egen args = concat(hold`first'-s`last')
local args = args[1]

* Generate the global variable
global four_digit_codes "`args'"

restore

* Save
save "$workingfolder\all_ipc_codes.dta", replace
