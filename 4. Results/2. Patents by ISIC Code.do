/*******************************************************************************
Description: 	This program generates results for number of patents by ISIC code.
				
			
			
Date created: 	October 6th 2023
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
cap mkdir "$workingfolder\ISIC Counts"

* Other set up 
*set maxvar 10000
cap mkdir "$workingfolder\Logs"
cap log close
log using "$workingfolder\Logs\Log_9.15.23", text replace

********************************************************************************

cap mkdir "$resultsfolder\ISIC Counts"

* Dataset is too large to save, append all the files first.
*****************************
** Append All Merged Files **
*****************************
cd 	"$workingfolder\Merged\IPC-WIPO-ISIC2"

*Append all waves to one dataset
local theFiles: dir . files "*.dta"
clear
append using `theFiles' 


********************************************************************************
****************** Unweighted Summary Statistics by ISIC Code ******************
********************************************************************************
/*
 Note on Double Counting:
	
	The applicationid & ISIC codes do not uniquely identify the observations. This means
	that when we do the unweighted count, there are some patents that would enter the 
	same ISIC code twice. 
	
	The idea is as follows; An applicationid has two different IPC codes that go to the
	same ISIC code via the crosswalk. Then we would say that in that ISIC code, there 
	are two patents when in reality it was only one patent with two different IPC 
	codes pointing to the same ISIC code. 
	
	Take this into account by making "double count" variables and then calculating the 
	net observations defined as total count - double count
*/ 
* Make variables to track double counting
sort year applicationid isic_rev3_2 

gen num_patents = 1
gen new = transfer == 0 
gen num_patents_flag = year == year[_n+1] & applicationid == applicationid[_n+1] & isic_rev3_2 == isic_rev3_2[_n+1]
gen transfer_flag = num_patents_flag == 1 & transfer == 1 & transfer[_n+1] == 1
gen new_flag = num_patents_flag == 1 & new == 1 & new[_n+1] == 1
gen green_broad_flag = num_patents_flag == 1 & green_broad == 1 & green_broad[_n+1] == 1
gen green_narrow_flag = num_patents_flag == 1 & green_narrow == 1 & green_narrow[_n+1] == 1

***********************
** By ISIC Code Only **
***********************

preserve 
local vars = "num_patents transfer new  green_broad green_narrow"

* Now collapse all variables of interest
collapse (sum) `vars' *_flag [pw = probability_weight], by(isic_rev3_2)

* Fix the double counting & prepare to export
foreach x in `vars' {
	
	rename `x'_flag flag_`x'
	rename `x' `x'_doublecount
	gen `x'_fixed = `x' - flag_`x'
	rename flag_`x' `x'_flag
}

* Order variables
order isic_rev3_2 *_fixed *_doublecount  *_flag


* Export to excel
export excel using "C:\Users\nn3495a\Desktop\Work\Brunel & Poole\Results\ISIC Counts\Counts_By_ISIC2.xls", sheet("Unweighted") sheetmodify firstrow(variables)

* Save file
save "$workingfolder\ISIC Counts\Unweighted", replace
restore

*************************
** By ISIC Code & Year **
*************************


preserve 
local vars = "num_patents transfer new  green_broad green_narrow"

* Now collapse all variables of interest
collapse (sum) `vars' *_flag [pw = probability_weight], by(isic_rev3_2 year)

* Fix the double counting & prepare to export
foreach x in `vars' {
	
	rename `x'_flag flag_`x'
	rename `x' `x'_doublecount
	gen `x'_fixed = `x' - flag_`x'
	rename flag_`x' `x'_flag
}

* Order variables
order isic_rev3_2 *_fixed *_doublecount  *_flag


* Export to excel
export excel using "C:\Users\nn3495a\Desktop\Work\Brunel & Poole\Results\ISIC Counts\Counts_By_ISIC2_Year.xls", sheet("Unweighted by Year") sheetmodify firstrow(variables)

* Save file
save "$workingfolder\ISIC Counts\Unweighted_by_Year", replace
restore

********************************************************************************
******************* Weighted Summary Statistics by ISIC Code *******************
********************************************************************************

* Remember to run the "Append code" above if you only run this block. 

preserve

local vars = "num_patents transfer new  green_broad green_narrow"
collapse (sum) `vars' [pw = weight], by(isic_rev3_2)


* Export to excel
export excel using "C:\Users\nn3495a\Desktop\Work\Brunel & Poole\Results\ISIC Counts\Counts_By_ISIC2.xls", sheet("Weighted") sheetmodify firstrow(variables)

* Save file
save "$workingfolder\ISIC Counts\Weighted", replace

restore

*************************
** By ISIC Code & Year **
*************************

preserve

local vars = "num_patents transfer new  green_broad green_narrow"
collapse (sum) `vars' [pw = weight], by(isic_rev3_2 year)


* Export to excel
export excel using "C:\Users\nn3495a\Desktop\Work\Brunel & Poole\Results\ISIC Counts\Counts_By_ISIC2_Year.xls", sheet("Weighted by Year") sheetmodify firstrow(variables)

* Save file
save "$workingfolder\ISIC Counts\Weighted_by_Year", replace

restore
