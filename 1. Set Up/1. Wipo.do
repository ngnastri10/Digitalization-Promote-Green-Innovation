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

* Set up global directories
global project "C:\Users\nn3495a\Desktop\Work\Brunel & Poole"
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

***************
** Pull Data **
***************

* Import Excel Sheet

forvalues y = 2000/2019 {
	 foreach x in "priority" "all" {
		
		* Import file
		import excel "$datafolder\Wipo scrapped/`y'/`y'`x'.xlsx", sheet("ResultSet") cellrange(A7) firstrow case(lower) clear
		
		* Gen year variable
		gen year = `y'
		
		* Drop unecessary variables (priority & all have different variables)
		if "`x'" == "priority" | "`x'" == "all" & `y' == 2003 {	
			drop `var_drop_priority'
		}
		else {
			drop `var_drop_all'
		}
		
		* Rename variable "g" or "prioritiesdata" (different varname in 2003 & 2019)
		if `y' == 2003 | (`y' == 2019 & "`x'" == "priority") {
			rename prioritiesdata family
		}
		else {
			rename g family
		}
		
		* Generate famsize - # of patent codes in the family varaible 
		gen famsize = length(family) - length(subinstr(family, ";", "", .)) + 1
		
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
	
	* Merge "All" file and "Priority" files
	use "$workingfolder\WIPO/`y'\Raw_all.dta", clear
	merge 1:1 applicationid using "$workingfolder\WIPO/`y'\Raw_priority.dta", nogen
	
	* Fix "transfer" variable 
	replace transfer = 0 if transfer == . 
	
	* Save cleaned data
	save "$workingfolder\WIPO/`y'\Merged_`y'.dta", replace

}

