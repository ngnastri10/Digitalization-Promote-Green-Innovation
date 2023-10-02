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