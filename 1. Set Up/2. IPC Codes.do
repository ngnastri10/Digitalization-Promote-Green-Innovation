/*******************************************************************************
Description: 	This program takes raw IPC codes from the WIPO website and prepares
				it to be matched with the WIPO patent data. 
				
				
			
			
Date created: 	September 18th, 2023
Created by: 	Nico Nastri

Date edited:	
Edited by:	
*******************************************************************************/ 

****************
* Set Up Files *
****************
***********************************************************************************
* NOTE: To run this code change the PROJECT global variable to your own directory *
***********************************************************************************
clear all

* Set up global directories
global project "C:\Users\nn3495a\Desktop\Brunel & Poole"
global datafolder "$project\Data"
global workingfolder "$project\Working"

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
	
	* Calculate difference between upper & lower bound
	gen dif`x' = dpref`x'_2_2 - dpref`x'_1_2
	
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
	
	forvalues x = 2/`top`y'' {
	
		* Parse out all numbers in each set of codes with "-"
		local i = `x'-1
		gen dif`y'_h`x' = dif`y'_h`i'+1 if dif`y'_h`i' < dpref`y'_2_2
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
		
		* Merge with stub
		replace dif`y'_h`x' = dpref`y'_1_1 + "/" + dif`y'_h`x' if dif`y'_h`x' != ""
	}
}



** NOTE: NEED TO CHECK HOW TO MAKE "00" INSTEAD OF "0"


* Fix names & datatype of variables to be consistent 
qui sum dif1
local y = `r(max)'+1
forvalues x = 1/`top' {
	local ++y
	
	* Rename all of variables with dif2 to dif1 starting from where dif1 ends
	rename dif2_h`x' dif1_h`y'
	
}

* Want to string all variables so we can combine with the stubs to get final codes
forvalues x = 1/2 {
	
	* Get total number of variables we created
	qui sum dif`x'
	local test`x' = `r(max)'+1
	
}

* This is total number of variables we created
local var_num = `test1' + `test2'


drop dif1_* dif2_*


drop ndash* rc_dash* dpref* dif*



		


