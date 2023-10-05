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

* Import codes
import delimited "C:\Users\nn3495a\Desktop\Work\Brunel & Poole\Data\Concordance patent\Latest version\ISIC_Rev3\ipc4_to_isic_rev3_4_excl_service.txt", clear

* Save as dta file
save "$workingfolder\ISIC_Codes.dta", replace