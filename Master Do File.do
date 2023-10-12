/*******************************************************************************
Description: 	This is a master do file for the Digitalization in Vietnam project
				with Professors Brunel & Poole. Running this code will produce 
				(so far) 3 final datasets. 
				
				1. Unweighted
				2. Weighted by Patent Family Size
				3. Weighted by if Patent is from US, EU, or Japan
				
				This code has 3 sections:
				
				1. Set Up: Sets up the raw data to be cleaned
				2. Clean: Generates the final dataset
				3. Results: Runs summary statistics & regressions on final dataset
				
			
			
Date created: 	October 10th, 2023
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
global codefolder "$project\Code\Digitalization-Promote-Green-Innovation"

* Set up folders if necessary
cap mkdir "$workingfolder"

* Other set up 
*set maxvar 10000
cap mkdir "$workingfolder\Logs"
cap log close
log using "$workingfolder\Logs\Log_9.15.23", text replace

********************************************************************************



********************************************************************************
****************************** Part 1: Set Up Data *****************************
********************************************************************************

* Set up WIPO Codes
do "$codefolder\1. Set Up\1. Wipo.do"

* Set up IPC Codes
do "$codefolder\1. Set Up\2. IPC Codes.do"

* Set up ISIC Codes
do "$codefolder\1. Set Up\3. ISIC Codes.do"

* Merge WIPO, IPC, ISIC codes. Generate patent-ISIC level files for each year. 
* Note: This doesn't merge all the years together because the file is very large. 
do "$codefolder\1. Set Up\4. Merge Files.do"


********************************************************************************
****************************** Part 2: Clean Data ******************************
********************************************************************************


* Generate Green variables
do "$codefolder\2. Clean\1. Generate Green Variables.do"

* Generate Digitalization variables
* Note: This also creates our final dataset. Will break this up when finalizing the code.
do "$codefolder\2. Clean\2. Generate Digitalization Variables.do"

********************************************************************************
************************* Part 3: Generate Results Data ************************
********************************************************************************
/*

Commenting out the results part for now because there is some repeat code in these files
that I need to clean up before this runs seamlessly. 

* Generate green variable summary statistics
do "$codefolder\4. Results\1. Green Var Summary Statistics.do"

* Generate Patent counts by ISIC Codes (2 digit level)
do "$codefolder\4. Results\2. Patents by ISIC Code.do"


