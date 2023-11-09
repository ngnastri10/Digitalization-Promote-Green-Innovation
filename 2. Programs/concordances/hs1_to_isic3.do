clear all
set more off
cd "C:\Users\pedro\Dropbox\VietNam Technology\data\concordances\industry"

import delimited  "JobID-19_Concordance_H1_to_I3.CSV"

keep hs1996productcode isicrevision3productcode
rename (hs1996productcode isicrevision3productcode) (h1 isic3)

gen hs0_4d=int(h1/100)
gen isic3_2d=int(isic3/100)

gen a=1

collapse (sum) a, by(hs0_4d isic3_2d)
drop a

tostring hs0_4d, replace format(%04.0f)
tostring isic3_2d, replace format(%02.0f)

g a=1
egen rep=sum(a), by( hs0_4d)
egen dup=seq(), by( hs0_4d)
replace dup=0 if rep==1
tostring dup, gen(d)
egen hs0_4d_m=concat(hs0_4d d), p(_)
drop a

order hs0_4d isic3_2d dup d hs0_4d_m rep

save hs04d_isic3, replace
