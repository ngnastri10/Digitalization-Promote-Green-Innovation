/*******************************************************************************
Description: 	Convert HS1 codes to ISIC3 
				
				
			
			
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

********************************************************************************

import delimited "$datafolder\JobID-19_Concordance_H1_to_I3.CSV", clear

keep hs1996productcode isicrevision3productcode
rename (hs1996productcode isicrevision3productcode) (h1 isic3)

gen hs0_3d=int(h1/100)
gen isic3_3d=int(isic3/10)

gen a=1

collapse (sum) a, by(hs0_3d isic3_3d)
drop a

tostring hs0_3d, replace format(%03.0f)
tostring isic3_3d, replace format(%03.0f)

g a=1
egen rep=sum(a), by( hs0_3d)
egen dup=seq(), by( hs0_3d)
replace dup=0 if rep==1
tostring dup, gen(d)
egen hs0_3d_m=concat(hs0_3d d), p(_)
drop a

order hs0_3d isic3_3d dup d hs0_3d_m rep

save "$workingfolder\hs04d_isic3.dta", replace
