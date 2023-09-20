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

**********************************************
* Explicitly Generate All 4 or 8 Digit Codes *
**********************************************

/* Notes on IPC Codes: 

		1) The WIPO website uses shorthand for every code that starts with the same
		   4 digits. This code explicitly makes all 4 or 8 digit codes. 
		   
		2) If we observed "-" this means every code in between the two numbers is 
		   a green patent. For example 01/05-01/44 means all patents between 05 & 44
		   are green.
*/
		
* Find prefix of each code
gen prefix = substr(B,1,4) 

* Gen complement of prefix
gen comp = substr(B,5,.)

* Split the codes into seperate variables
split comp, gen(raw_code) parse(,) notrim
gen ndash = length(B) - length(subinstr(B, "-", "", .))

* Make local variable for how many codes we need to loop over
gen ncomm = length(B) - length(subinstr(B, ",", "", .)) + 1
qui sum ncomm

forvalues x = 1/`r(max)' {
	
	* Check if code has "-".
	gen ndash`x' = length(raw_code`x') - length(subinstr(raw_code`x', "-", "", .))

}

forvalues x = 1/`r(max)' {
	
	* Split again if we have codes with "-"
	split raw_code`x', gen(rc_dash`x'_) parse(-) notrim

}

drop ndash* rc_dash*



		


