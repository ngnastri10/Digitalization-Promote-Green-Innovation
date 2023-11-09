/*******************************************************************************
Description: 	This is a master do file for the Digitalization in Vietnam project
				with Professors Brunel & Poole. Running this code will produce 
				(so far) 3 final datasets. 
				
				1. Unweighted
				2. Weighted by Patent Family Size
				3. Weighted by if Patent is from US, EU, or Japan
				
				The code proceeds in 3 parts:
				
				Part 1: Set up Patent data
				Part 2: Set up Concordance & Trade data
				Part 3: Set up Digitalization data & merge all variables together
				
			
			
Date created: 	October 10th, 2023
Created by: 	Nico Nastri

Date edited:	November 8, 2023
Edited by:		Nico Nastri
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
global datafolder "$project\1. Data"
global workingfolder "$project\Working"
global resultsfolder "$project\Results"
global codefolder "$project\Code\Digitalization-Promote-Green-Innovation\2. Programs"

* Set up folders if necessary
cap mkdir "$workingfolder"

* Other set up 
*set maxvar 10000
cap mkdir "$workingfolder\Logs"
cap log close
log using "$workingfolder\Logs\Log_9.15.23", text replace

********************************************************************************



********************************************************************************
************************** Part 1: Set Up Patent Data **************************
********************************************************************************

* Set up WIPO Codes
do "$codefolder\patent\1. Wipo.do"

* Set up IPC Codes
do "$codefolder\patent\2. IPC Codes.do"

* Set up ISIC Codes
do "$codefolder\patent\3. ISIC Codes.do"

* Merge WIPO, IPC, ISIC codes. Generate patent-ISIC level files for each year. 
* Note: This doesn't merge all the years together because the file is very large. 
do "$codefolder\patent\4. Merge Files.do"


********************************************************************************
********* Part 2: Set Up Concordances & Trade/WID/Digitalization Data **********
********************************************************************************


* Make Concordance btwn HS1 & ISIC3 Codes
do "$codefolder\concordances\1. HS1 to ISIC3.do"

* Generate Total Trade Variable
do "$codefolder\trade\1. Trade ISIC 3 Digit.do"

* Generate World Import Demand Variable
do "$codefolder\trade\2. World Import Demand.do"

* Generate Digitalization Data
do "$codefolder\digitalization\1. Generate Digitalization Variables.do"


********************************************************************************
************************* Part 3: Create Final Dataset *************************
********************************************************************************

do "$codefolder\final dataset\1. Make Final Dataset.do"


/*

Commenting out the results part for now because there is some repeat code in these files
that I need to clean up before this runs seamlessly. 

* Generate green variable summary statistics
do "$codefolder\4. Results\1. Green Var Summary Statistics.do"

* Generate Patent counts by ISIC Codes (2 digit level)
do "$codefolder\4. Results\2. Patents by ISIC Code.do"


