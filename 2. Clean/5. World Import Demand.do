/*******************************************************************************
Description: 	Merge with trade data  
				
				
			
			
Date created: 	November 6th, 2023
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

***********************************************************************************

clear all
set more off
local path "C:\Users\pedro\Dropbox\VietNam Technology\data\Trade Data\"

use "$datafolder\IMP_kct_HS4_v2.dta", clear

**merge with weights for vietnam
merge m:1 reporter hs4_product using "$datafolder\VTN_X_2001weights_v2.dta"
keep if _merge==3

	**variable wid_kt**	
gen wid_it=imp_kct*w_kc
collapse (sum) wid_it, by(year hs4_product)
replace wid_it=wid_it/1000
save "$workingfolder\hs4_WID4VTN.dta",replace


*merge with hs04d_isic3
forvalues i=0(1)3 {
use "$workingfolder\hs4_WID4VTN.dta", clear
rename hs4_product hs0_4d
gen hs0_3d_m=hs0_4d+"_"+"`i'"
merge m:1 hs0_3d_m using "$workingfolder\hs04d_isic3.dta", keep(3) keepusing(isic3_3d rep) nogen
save temp_part`i'.dta, replace
}

use temp_part0.dta, clear
forvalues i=1(1)3 {
append using temp_part`i'.dta
erase temp_part`i'.dta
}
erase temp_part0.dta
gen wid_kt=wid_it/rep
collapse (sum) wid_kt, by(isic3_3d year)
tostring(year), gen(t)
gen merge_id=isic3_3d+t
drop t
drop if year<2000
*drop if year==2015

erase "$workingfolder\hs4_WID4VTN.dta"

label var wid_kt "WID of VTN of ISIC3-3d industry (mln. USD)"

drop merge_id
save "$workingfolder\clean_wid_isic3.dta", replace
