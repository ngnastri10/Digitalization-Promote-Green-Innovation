/*******************************************************************************
Description: 	This program takes data from the "wipe scrapped" folder for years
				2000-2019 and pulls variables of interest. Then combines all of 
				the waves into one dataset.
				
				
			
			
Date created: 	September 15th, 2023
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
/* Un-comment this if you want to run the do file alone
* Set up global directories
global project "C:\Users\nn3495a\Desktop\Work\Brunel & Poole"
global datafolder "$project\Data"
global workingfolder "$project\Working"
global resultsfolder "$project\Results"

* Set up folders if necessary
cap mkdir "$workingfolder"
*/ 

* Install libraries
ssc install fastreshape

********************************************************************************


************************************
** List variables we want to drop **
************************************
local var_drop_all /*

Characteristic variables
*/ applicationnumber title country applicationdate


local var_drop_priority /*

Characteristic variables
*/ applicationnumber country applicationdate


********************************************************************************

* Import Excel Sheet

forvalues y = 2000/2019 {
	 foreach x in "priority" "all" {
	 	
		***************
		** Pull Data **
		***************
		
		* Import file
		import excel "$datafolder\Wipo scrapped/`y'/`y'`x'.xlsx", sheet("ResultSet") cellrange(A7) firstrow case(lower) clear
		
		* Gen year variable
		gen year = `y'
		
		* Drop unecessary variables (priority & all have different variables)
		if "`x'" == "priority" | ("`x'" == "all" & `y' == 2003) {	
			drop `var_drop_priority'
		}
		else {
			drop `var_drop_all'
		}
		
		* Rename variable "g" or "prioritiesdata" (different varname in 2003 & 2019)
		if `y' == 2003 | (`y' == 2019 & "`x'" == "priority") {
			gen family = ""
		}
		else {
			rename g family
		}
		
		* Generate famsize - # of patent codes in the family varaible 
		gen famsize = length(family) - length(subinstr(family, ";", "", .)) + 1
		replace famsize = famsize + 1 if family != ""
		
		* Generate triadic - 1 if family patent code includes US, JP & EP, else 0 
		gen triadic = cond(strpos(family, "US") & strpos(family, "JP") & strpos(family, "EP"), 1, 0, .)
		
		* Generate dummy for patents that have a match in the "all" dataset
		if "`x'" == "priority" {
			gen transfer = 1
		}
		
		* Make directory & save files
		cap mkdir "$workingfolder\WIPO"
		cap mkdir "$workingfolder\WIPO/`y'"
		
		save "$workingfolder\WIPO/`y'\Raw_`x'.dta", replace
	
	}
	
	****************
	** Merge Data **
	****************
	
	* Merge "All" file and "Priority" files
	use "$workingfolder\WIPO/`y'\Raw_all.dta", clear
	merge 1:1 applicationid using "$workingfolder\WIPO/`y'\Raw_priority.dta", nogen
	
	* Fix "transfer" variable 
	replace transfer = 0 if transfer == .
	
	*******************
	** Fix IPC Codes **
	*******************
	
	/*putexcel set "$resultsfolder\Share Patents w No IPC.xlsx", modify
	* Count share of patents without IPC code & export number to excel
	qui gen check_patent = cond(ipc == "", 1, 0, .)
	qui sum check_patent
	qui local i = `y'- 1999
	qui putexcel A`i' = `y'
	qui putexcel B`i' = `r(sum)'
	qui putexcel C`i' = `r(N)'
	qui putexcel D`i' = `r(mean)'*/
	
	* Prepare IPC Codes to be Split
	replace ipc = subinstr(ipc, "//", "/", .)
	replace ipc = subinstr(ipc, "/;", ";", .)
	replace ipc = substr(ipc, 1, length(ipc) - 1) if substr(ipc, -1, 1) ==  "/"

	* Split IPC Codes (note they are separated by ";")
	split ipc, gen(ipc_code) parse(;)

	* Remove Spaces in between codes
	gen ipc_len = length(ipc) - length(subinstr(ipc, ";", "", .)) + 1
	sum ipc_len

	forvalues z = 1/`r(max)' {
		qui replace ipc_code`z' = subinstr(ipc_code`z', " ", "", .)
	
	}
	
	* Prepare for reshaping
	drop ipc_len
	drop if ipc == ""

	* Make Long dataset with all the IPC Codes
	fastreshape long ipc_code, i(applicationid) j(index)
	drop if ipc_code == ""

	* Drop duplicates
	bysort applicationid ipc_code: gen dup = _n
	keep if dup == 1
	drop dup
	
	* Save cleaned data
	qui save "$workingfolder\WIPO/`y'\Merged_`y'.dta", replace

}

/*

	use "$workingfolder\WIPO/2019\Merged_2019.dta", clear


* Prepare IPC Codes to be Split
replace ipc = subinstr(ipc, "//", "/", .)
replace ipc = subinstr(ipc, "/;", ";", .)
replace ipc = substr(ipc, 1, length(ipc) - 1) if substr(ipc, -1, 1) ==  "/"

* Split IPC Codes (note they are separated by ";")
split ipc, gen(ipc_code) parse(;)

* Remove Spaces in between codes
qui gen ipc_len = length(ipc) - length(subinstr(ipc, ";", "", .)) + 1
qui sum ipc_len

forvalues z = 1/`r(max)' {
	qui replace ipc_code`z' = subinstr(ipc_code`z', " ", "", .)
	
}

drop ipc_len

* Make Long dataset with all the IPC Codes
reshape long ipc_code, i(applicationid) j(index)
drop if ipc_code == ""

* Drop duplicates
bysort applicationid ipc_code: gen dup = _n
keep if dup == 1
drop dup