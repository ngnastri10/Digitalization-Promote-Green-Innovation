/*******************************************************************************
Description: 	This program merged the cleaned IPC & WIPO codes
				
				
			
			
Date created: 	October 2nd, 2023
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
global resultsfolder "$project\Results"

* Set up folders if necessary
cap mkdir "$workingfolder"

* Other set up 
*set maxvar 10000
cap mkdir "$workingfolder\Logs"
cap log close
log using "$workingfolder\Logs\Log_9.15.23", text replace

********************************************************************************

cap mkdir "$workingfolder\Merged"

forvalues x = 2000/2019 {
	
	use "$workingfolder\WIPO/`x'\Merged_`x'.dta", clear
	
	**************************************
	** Fix Codes w/ Only First 4 Digits **
	**************************************
	* Generate check variable of first 4 codes
	qui gen check = substr(ipc_code, 1, 4)	
	
	* Loop through & check if they match with the 4 code digits from IPC dataset
	qui local var = "$four_digit_codes"
	foreach y in `var' {
		* Replace longer codes w/ 4 digit if they are only 4 digit in the IPC dataset
		qui replace ipc_code = "`y'" if check == "`y'"
	}
	
	****************************
	** Merge IPC & WIPO Codes **
	****************************
	
	merge m:1 ipc_code using "$workingfolder\all_ipc_codes
	
	save "$workingfolder\Merged/`x'.dta"
}


*****************************
** Append All Merged Files **
*****************************