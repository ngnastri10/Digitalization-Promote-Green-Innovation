/*******************************************************************************
Description: 	Generate green variables
				
				
			
			
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
********************************************************************************
******************************* Notes On The Code ******************************
********************************************************************************

/* 

	This code generates two measures of green patent:

		1) "green_broad": For each patent, create a dummy equal to 1 if the patent
		   cites any code that is from the climate list
		   
		2) "green_narrow": For each patent, create a variable that is the share
			of IPC codes that are from the climate list
	
*/


* Use final merged codes
use "$workingfolder\Final_Merged_IPC_WIPO_Codes", clear

* Generate dummy for green_broad & green_narrow
gen green_broad = _merge == 3
gen green_narrow = _merge == 3

* Generate obs to get number of codes in each patent
gen total_ipc = 1
gen total_green_ipc = 1 if _merge == 3

* Drop missing applicationid (not sure why this is happening)
drop if applicationid == ""

* Collapse by applicationid to get final versions of variables
collapse green_narrow (max) green_broad (first) year (rawsum) total_green_ipc total_ipc, by(applicationid)


save "$workingfolder\green_variables.dta", replace
