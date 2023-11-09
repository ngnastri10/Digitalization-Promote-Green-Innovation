/*******************************************************************************
Description: 	This program cleans & prepares the ISIC rev 3 codes for merging
				
				
			
			
Date created: 	October 5th, 2023
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

********************************************************************************

local isic_code = "2 3 4"

foreach x in `isic_code' {
	
	* Import codes
	import delimited "$datafolder\Concordance patent\Latest version\ISIC_Rev3\ipc4_to_isic_rev3_`x'_excl_service.txt", clear

* Save as dta file
save "$workingfolder\ISIC`x'_Codes.dta", replace

}