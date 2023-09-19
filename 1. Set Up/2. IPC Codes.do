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
		
* Check if code has "-".
gen dash = cond(strpos(B, "-"), 1, 0, .)
		
* Find prefix of each code
gen prefix = substr(B,1,4) 


		


