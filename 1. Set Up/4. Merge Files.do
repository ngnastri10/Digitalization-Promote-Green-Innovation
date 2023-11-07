/*******************************************************************************
Description: 	This program performs multiple merges of the cleaned datasets

				Part I: This part merges the cleaned IPC & WIPO codes
				
				Part II: This part merges the industry codes
				
				Part III: Appends all year files to create clean data set
				
			
			
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

***********************************************************************************
************************* PART I: Merge IPC & WIPO Codes **************************
***********************************************************************************

cap mkdir "$workingfolder\Merged"
cap mkdir "$workingfolder\Merged\IPC-WIPO"


forvalues x = 2000/2019 {
	
	use "$workingfolder\WIPO/`x'\Merged_`x'.dta", clear
	
	**************************************
	** Fix Codes w/ Only First 4 Digits **
	**************************************
	* Generate check variable of first 4 codes
	qui gen ipc4 = substr(ipc_code, 1, 4)	
	
	* Loop through & check if they match with the 4 code digits from IPC dataset
	qui local var = "$four_digit_codes"
	foreach y in `var' {
		* Replace longer codes w/ 4 digit if they are only 4 digit in the IPC dataset
		qui replace ipc_code = "`y'" if ipc4 == "`y'"
	}
	
	
	****************************
	** Merge IPC & WIPO Codes **
	****************************
	
	* Merge files
	merge m:1 ipc_code using "$workingfolder\all_ipc_codes", keep(1 3) gen(green_match)
	
	save "$workingfolder\Merged\IPC-WIPO/`x'.dta", replace
}


***********************************************************************************
**************************** PART II: Merge ISIC Codes ****************************
***********************************************************************************


local isic_code = "2 3 4"
foreach y in `isic_code' {
	
	* Make folder if necessary
	cap mkdir "$workingfolder\Merged\IPC-WIPO-ISIC`y'"

	forvalues x = 2000/2019 {
	
		use "$workingfolder\Merged\IPC-WIPO/`x'.dta", clear
	
		********************************************
		** Prepare Variables for Collapse & Merge **
		********************************************
	
		/* Note: We don't care about 8 digit IPC codes anymore. So first calculate 	
		   variables of interest & then collapse down to the 4 digit IPC level. */
	
		* Variables about IPC codes themselves
		gen num_green_codes = green_match == 3
		gen green_ipc = green_match == 3
		gen num_8d_codes = 1
	
		* Generate green broad & green narrow
		egen green_broad = max(green_ipc), by(applicationid)
		egen hold = total(green_ipc), by(applicationid)
		bysort applicationid: gen hold2 = _N
		gen green_narrow = hold/hold2
	
		****************************************
		** Collapse IPC Codes to 2 or 4 Digit **
		****************************************
	
		collapse (first) ipc family year famsize triadic transfer prioritiesdata green_narrow green_broad (max) green_ipc (rawsum) num_green_codes num_8d_codes, by(applicationid ipc4)
	
		*********************************
		** Merge IPC-WIPO & ISIC Codes **
		*********************************
	
		* Generate share of IPC4 codes in each patent
		egen ipc_tot_num = total(num_8d_codes), by(applicationid)
		gen share_ipc = num_8d_codes/ipc_tot_num

		* Join all matches of ISIC & IPC codes
		joinby ipc4 using "$workingfolder\ISIC`y'_Codes.dta", _merge(join) unm(m)
	
		* Generate combines weight
		gen weight = probability_weight*share_ipc
	
		* Tab for now
		tab applicationid if join == 1
	
		* Drop entire patent if any IPC code didn't merge
		gen check = join == 1
		egen check2 = max(check), by(applicationid)
		drop if check2 == 1
		drop check*
		
	
		save "$workingfolder\Merged\IPC-WIPO-ISIC`y'/`x'.dta", replace
	
	}
}



***********************************************************************************
************************ PART III: Append All Year Files **************************
***********************************************************************************
/* The computer doesn't have storage space for such a large file. Leave this commented out for now.
*****************************
** Append All Merged Files **
*****************************
cd 	"$workingfolder\Merged\IPC-WIPO-ISIC"

*Append all waves to one dataset
local theFiles: dir . files "*.dta"
clear
append using `theFiles' 

* Save
save "$workingfolder\Final_Merged_IPC_WIPO_Codes", replace

