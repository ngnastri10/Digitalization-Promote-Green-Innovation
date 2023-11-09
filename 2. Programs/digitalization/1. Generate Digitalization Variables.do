/*******************************************************************************
Description: 	Generate digitalization in Vietnam variables.
				
				
			
			
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
/* Un-comment this if you want to run the do file alone
* Set up global directories
global project "C:\Users\nn3495a\Desktop\Work\Brunel & Poole"
global datafolder "$project\Data"
global workingfolder "$project\Working"
global resultsfolder "$project\Results"

* Set up folders if necessary
cap mkdir "$workingfolder"
*/ 

***********************************************************************************

*******************************************
** Prepare Digitalization Data for Merge **
*******************************************

use "$datafolder\digitalization\raw\province-digitalization.dta", clear
rename dc_code province 

* Join digitalization & empshare datasets
joinby province using "$datafolder\digitalization\raw\VN_empshare.dta", _merge(join_empsh) unm(b)

* String the ISIC Codes
tostring industry, gen(isic3_3d) format(%03.0f)

* Make sure we have unique values in our merge variable
drop if year == . 
 
* Create Weighted "Digitalization" Variable by Industry
collapse computer internet [pw = employment_share], by(year isic3_3d)

* Save as a temporary file that we will merge back into our main dataset later
save "$workingfolder\digitalization_clean.dta", replace