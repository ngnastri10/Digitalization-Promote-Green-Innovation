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

These are for the years 2002-2014 (every two years), with the exception of FDI data which is only for 2003 on since we did not (and still do not) have FDI data before 2003. As I think about it, we may want to consider using 2003 FDI data in 2002—not ideal but could give us one more year of data?

Once the patents data is ready at the industry-year level (industry should be 2-digit ISIC Rev. 3—what we have elsewhere), we can merge to the following regressors:

Trade and FDI: industry-trade-fdi.dta This has year, industry, exports, world import demand (instrument), number of FDI projects, dollar value of FDI, and "jobs created" by FDI.

Digitalization: we are going to need 3 datasets to convert what is currently a province-year digitalization measure (province-digitalization.dta) into a industry-year digitalization measure (see below).

Province-digitalization.dta contains dc_code (province code from household survey), year, share of computer-using households and share of households with internet.
   NOTE: despite the name dc_code, this is the province code from the VHLSS

Province-lss-dc-concordance.dta concords the province codes between the Decennial Census and the Living Standards Survey. The codes are named *correctly* here: dc_code is the code the Decennial Census uses and lss_code is the code from VHLSS (which is named incorrectly dc_code in the province-digitalization.dta)

This concordance will be important because we need to match the industry's share of employment in a province (as calculated from Decennial Census) using the right codes. (industry-share-employment-in province.dta)

Ultimately, we want to calculate an industry-year measure of digitalization, based on where the industry is located and the amount of digitalization in that area. So we will:

Where internet_pt comes from what we have in province-digitalization. Weight those by the industry's share of employment in a province (time-invariant pre-period) from industry-share-employment-in-province.dta [being careful about current province codes), and then collapse by industry-year to create a industry-year digitalization.

 
	
*/

cap mkdir "$workingfolder\Vietnam Trade Data"

import delimited "C:\Users\nn3495a\Desktop\Work\Brunel & Poole\Data\Trade Data\Vietnamimports2000-07.csv", clear
save "$workingfolder\Vietnam Trade Data\2000-07.dta", replace

import delimited "C:\Users\nn3495a\Desktop\Work\Brunel & Poole\Data\Trade Data\Vietnamimports2008-15.csv", clear
save "$workingfolder\Vietnam Trade Data\2008-15.dta", replace


import delimited "C:\Users\nn3495a\Desktop\Work\Brunel & Poole\Data\Trade Data\Vietnamimports2016-20.csv", clear
save "$workingfolder\Vietnam Trade Data\2016-20.dta", replace

cd 	"$workingfolder\Vietnam Trade Data"

*Append all waves to one dataset
local theFiles: dir . files "*.dta"
clear
append using `theFiles' 



*******************************************
** Prepare Digitalization Data for Merge **
*******************************************

use "$datafolder\Digitalization Data\province-digitalization.dta", clear
rename dc_code province 

* Join digitalization & empshare datasets
joinby province using "$datafolder\Digitalization Data\VN_empshare.dta", _merge(join_empsh) unm(b)

* String the ISIC Codes
tostring industry, gen(isic3_3d) format(%03.0f)

* Make sure we have unique values in our merge variable
drop if year == . 
 
* Create Weighted "Digitalization" Variable by Industry
collapse computer internet [pw = employment_share], by(year isic3_3d)

* Save as a temporary file that we will merge back into our main dataset later
tempfile digitalization
save `digitalization'


********************************************
** Append All Merged IPC-WIPO-ISIC3 Files **
********************************************
* Dataset is too large to save, append all the files first.

cd 	"$workingfolder\Merged\IPC-WIPO-ISIC3"

*Append all waves to one dataset
local theFiles: dir . files "*.dta"
clear
append using `theFiles' 

tostring isic_rev3_3, gen(isic3_3d) format(%03.0f)

**********************************
** Merged All Datasets Together **
**********************************

* Merge Total Trade & Clean WID Data onto Patent data
merge m:1 isic3_3d year using "$workingfolder\total_trade.dta", keep(1 3) nogen 
merge m:1 isic3_3d year using "$workingfolder\clean_wid_isic3.dta", keep(1 3) nogen

* Generate Industriy Level Digitalization Measure
merge m:1 isic3_3d year using `digitalization', keep(1 3) nogen

* Drop "Odd" years we have no digitalization data
drop if year < 2001
drop if year > 2014
forvalues x = 2001(2)2013 {
	
	drop if year == `x'
}

****************************************************************
** Collapse Entire Dataset to Industry-Year Observation Level **
****************************************************************

* Gen count variables
gen num_patents = 1
gen new = transfer == 0 
foreach x in "narrow" "broad" {
	foreach y in "new" "transfer" {
		
		gen green_`x'_`y' = cond(`y' == 1, green_`x', .)

	}
}

* Generate weight vars
gen weight_fam = weight*famsize
gen weight_triadic = weight*triadic

foreach x in "weight" "weight_fam" "weight_triadic" {
	
	* Save conditions
	local suffix = cond("`x'"=="weight", "Original", cond("`x'" == "weight_fam", "Famsize", cond("`x'" == "weight_triadic", "Triadic", "Broken")))

	preserve
	* Collapse variables of interest
	collapse (sum) triadic transfer num_patents new green_narrow green_narrow_new green_narrow_transfer green_broad green_broad_new green_broad_transfer (firstnm) tot_trade_isic3_3d wid_kt computer internet [pweight = `x'], by(year isic3_3d)


	* Save Final Dataset
	save "$workingfolder\Final_Clean_Dataset_3Digit_`suffix'.dta", replace
	restore
}
