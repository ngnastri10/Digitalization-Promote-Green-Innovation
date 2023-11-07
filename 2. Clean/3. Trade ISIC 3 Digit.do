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

import delimited "$datafolder\DataJobID-1749557_1749557_TradeVNM.csv", clear

keep productcode partneriso3 year tradevaluein1000usd

rename (productcode partneriso3 year tradevaluein1000usd)(hs0_4d partner year value)

*replace hs0_4d = int(hs0_4d/10)

tostring hs0_4d, format(%03.0f) replace

forvalues i=0(1)3 {
preserve
gen hs0_3d_m=hs0_4d+"_"+"`i'"
merge m:1 hs0_3d_m using "$workingfolder\hs04d_isic3.dta", keep(3) keepusing(isic3_3d rep) nogen
save temp_part`i'.dta, replace
restore
}
use temp_part0.dta, clear
forvalues i=1(1)3 {
append using temp_part`i'.dta
erase temp_part`i'.dta
}
erase temp_part0.dta
replace value=value/rep
collapse (sum) value, by(isic3_3d year)
rename value tot_trade_isic3_3d
replace tot_trade_isic3_3d=tot_trade_isic3_3d/1000
tostring(year), gen(t)
gen merge_id=isic3_3d+t
drop t
label var tot_trade_isic3_3d "Total exports of VTN (mln) USD)"

destring(isic3_3d), gen(ind_num)

gen ind=0
replace ind=1 if ind_num>=01 & ind_num<=05
replace ind=2 if ind_num>=06 & ind_num<=14
replace ind=3 if ind_num>=15 & ind_num<=16
replace ind=3 if ind_num>=20 & ind_num<=37
replace ind=4 if ind_num>=17 & ind_num<=19
replace ind=5 if ind_num>=40 

# delimit ;
label define ind_lab 
 1 "Agriculture"
 2 "Primary Manuf."
 3 "Manufacture (excl.Textiles)"
 4 "Textiles"
 5 "Services" ;
#delimit cr
label values ind ind_lab

drop merge_id 
save "$workingfolder\total_trade.dta", replace
