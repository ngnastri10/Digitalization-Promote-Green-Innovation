clear all
set more off
cd "C:\Users\pedro\Dropbox\VietNam Technology\data\Trade Data\Raw data\Exports and total trade data"
local path "C:\Users\pedro\Dropbox\VietNam Technology\data\Trade Data\"
local concordance "C:\Users\pedro\Dropbox\VietNam Technology\data\concordances"


import delimited "DataJobID-1749557_1749557_TradeVNM.csv", clear

keep productcode partneriso3 year tradevaluein1000usd

rename (productcode partneriso3 year tradevaluein1000usd)(hs0_4d partner year value)

tostring hs0_4d, format(%04.0f) replace

forvalues i=0(1)3 {
preserve
gen hs0_4d_m=hs0_4d+"_"+"`i'"
merge m:1 hs0_4d_m using "`concordance'\industry\hs04d_isic3.dta", keep(3) keepusing(isic3_2d rep) nogen
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
collapse (sum) value, by(isic3_2d year)
rename value tot_trade_isic3_2d
replace tot_trade_isic3_2d=tot_trade_isic3_2d/1000
tostring(year), gen(t)
gen merge_id=isic3_2d+t
drop t
label var tot_trade_isic3_2d "Total exports of VTN (mln) USD)"

destring(isic3_2d), gen(ind_num)

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
save "`path'\Clean data\total_trade.dta", replace
