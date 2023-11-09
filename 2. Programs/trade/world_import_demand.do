clear all
set more off
cd "C:\Users\pedro\Dropbox\VietNam Technology\data\"
local path "C:\Users\pedro\Dropbox\VietNam Technology\data\Trade Data\"

use "`path'\Raw data\World Import Demand\IMP_kct_HS4_v2.dta", clear

**merge with weights for vietnam
merge m:1 reporter hs4_product using "`path'/Raw data\World Import Demand/VTN_X_2001weights_v2.dta"
keep if _merge==3

	**variable wid_kt**	
gen wid_it=imp_kct*w_kc
collapse (sum) wid_it, by(year hs4_product)
replace wid_it=wid_it/1000
save "`path'/Raw data\World Import Demand/hs4_WID4VTN.dta",replace


*merge with hs04d_isic3
forvalues i=0(1)3 {
use "`path'/Raw data\World Import Demand/hs4_WID4VTN.dta", clear
rename hs4_product hs0_4d
gen hs0_4d_m=hs0_4d+"_"+"`i'"
merge m:1 hs0_4d_m using "concordances\industry\hs04d_isic3.dta", keep(3) keepusing(isic3_2d rep) nogen
save temp_part`i'.dta, replace
}

use temp_part0.dta, clear
forvalues i=1(1)3 {
append using temp_part`i'.dta
erase temp_part`i'.dta
}
erase temp_part0.dta
gen wid_kt=wid_it/rep
collapse (sum) wid_kt, by(isic3_2d year)
tostring(year), gen(t)
gen merge_id=isic3_2d+t
drop t
drop if year<2000
*drop if year==2015

erase "`path'/Raw data\World Import Demand/hs4_WID4VTN.dta"

label var wid_kt "WID of VTN of ISIC3-2d industry (mln. USD)"

drop merge_id
save "`path'\Clean data\wid_isic3.dta", replace
