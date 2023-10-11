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

* Dataset is too large to save, append all the files first.
********************************************
** Append All Merged IPC-WIPO-ISIC2 Files **
********************************************
cd 	"$workingfolder\Merged\IPC-WIPO-ISIC2"

*Append all waves to one dataset
local theFiles: dir . files "*.dta"
clear
append using `theFiles' 

********************************************************************************
************************ Merge FDI Data onto Patent Data ***********************
********************************************************************************

**************************************************
** Merge Patent Data w/ Industry-Trade-FDI File **
**************************************************

/* 
	Note: The "industry-trade-fdi" is only available from 2004-2019 on even years.
	We keep only the years that merge with the "industry-trade-fdi"data, so all 
	other years fall out. 
	
	Note: We create data for 2002 from data for 2003 to get more years.

*/ 

* String & reformat ID variable first to match the Vietnam dataset
tostring isic_rev3_2, gen(isic3_2d)
gen hold = "0"
replace isic3_2d = hold+isic3_2d if length(isic3_2d) == 1
drop hold

* Merge files together
merge m:1 isic3_2d year using "$datafolder\Digitalization Data\industry-trade-fdi.dta", keep(3) nogen

* Save as temporary file
tempfile main
save `main'


************************************************************************************
** Convert Province-Year Digitalization Measure into Industry-Year Digitalization **
************************************************************************************

********************************************************
** Merge Province Digitalization & LSS-DC Concordance **
********************************************************

/* Note about LSS - DC Concordance

	12 DC Codes don't match up perfectly with the LSS. In each case, 2 LSS codes 
	merge to the same DC code. For simplicity I take the average values of computer
	& internet for the two LSS codes that go into the DC code. The values across 
	the cells being averaged are usually very similar. 
*/ 

* Open Province Digitalization Code
use "$datafolder\Digitalization Data\province-digitalization.dta", clear

* String & Rename the ID code (which is incorrectly named in the raw data)
tostring dc_code, gen(lss_code)
drop dc_code

* Merge with LSS - DC Concordance Dataset
merge m:1 lss_code using "$datafolder\Digitalization Data\province-lss-dc-concordance.dta", keep(1 3) nogen

* Collapse to get unique DC code so we can merge onto other databases
*collapse computer internet, by(dc_code year)


***************************************
** Prepare to Merge with Patent Data **
***************************************

* Now Merge Digitalization w/ Industry Employment Shares
joinby dc_code using "$datafolder\Digitalization Data\industry-employment-share-in-province.dta", _merge(join_empsh) unm(b)

* Generate sum variables as well to have both 
gen computer_sum = computer
gen internet_sum = internet

* Create Weighted "Digitalization" Variable by Industry
collapse computer internet (sum) computer_sum internet_sum [pw = ind_share], by(year isic3_2d)

* Save as a temporary file that we will merge back into our main dataset later
tempfile digitalization
save `digitalization'

*************************************************
** Merge Province Digitalization & Patent Data **
*************************************************
use `main', clear

merge m:1 year isic3_2d using `digitalization', keep(3) nogen

****************************************************************
** Collapse Entire Dataset to Industry-Year Observation Level **
****************************************************************

* Generate variables to be collapsed as a sum rather than a mean

local vars = triadic transfer green_narrow green_broad
foreach x in `vars' {
	
	gen `x'_sum == `x'
}

collapse famsize triadic transfer green_narrow green_broad (sum)  (first)  [aweight = weight], by(year isic3_2d)

