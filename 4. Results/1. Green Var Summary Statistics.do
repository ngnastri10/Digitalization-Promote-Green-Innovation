/*******************************************************************************
Description: 	Generate summary statistics of our green_narrow & green_broad
				variables
				
				
			
			
Date created: 	October 2nd, 2023
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

********************************
** General Summary Statistics **
********************************

use "$workingfolder\green_variables.dta", clear

* Set excel sheet
putexcel set "$resultsfolder\Green Variable Sum Stat", modify sh(General Sum Stat)

foreach x in "broad" "narrow" {
	
	* Sum statistic
	qui sum green_`x', d
	
	local row = cond("`x'" == "broad", 4, cond("`x'" == "narrow", 5, 6))
	
	* Put excel
	putexcel C`row' = `r(mean)'
	putexcel D`row' = `r(sd)'
	putexcel E`row' = `r(min)'
	putexcel F`row' = `r(p10)'
	putexcel G`row' = `r(p25)'
	putexcel H`row' = `r(p50)'
	putexcel I`row' = `r(p75)'
	putexcel J`row' = `r(p90)'
	putexcel K`row' = `r(max)'
	putexcel L`row' = `r(N)'
	
}

* Same but if the variable is not equal to 0 
foreach x in "broad" "narrow" {
	
	* Sum statistic
	qui sum green_`x' if green_`x' != 0 , d 
	
	local row = cond("`x'" == "broad", 11, cond("`x'" == "narrow", 12, 13))
	
	* Put excel
	putexcel C`row' = `r(mean)'
	putexcel D`row' = `r(sd)'
	putexcel E`row' = `r(min)'
	putexcel F`row' = `r(p10)'
	putexcel G`row' = `r(p25)'
	putexcel H`row' = `r(p50)'
	putexcel I`row' = `r(p75)'
	putexcel J`row' = `r(p90)'
	putexcel K`row' = `r(max)'
	putexcel L`row' = `r(N)'
	
}


********************************
** Summary Statistics by Year **
********************************

* Set excel sheet
putexcel set "$resultsfolder\Green Variable Sum Stat", modify sh(Sum Stat by Year)

foreach x in "broad" "narrow" {
	
	forvalues y = 2000/2019 {
		
		* Sum statistic
		qui sum green_`x' if year == `y' , d 
		
		if "`x'" == "broad" {
			* Set local row condition
			local row = `y' - 1996
		}
		if "`x'" == "narrow" {
			local row = `y' - 1976 
			
		}
	
		* Put excel
		putexcel B`row' = `y'
		putexcel C`row' = `r(mean)'
		putexcel D`row' = `r(sd)'
		putexcel E`row' = `r(min)'
		putexcel F`row' = `r(p10)'
		putexcel G`row' = `r(p25)'
		putexcel H`row' = `r(p50)'
		putexcel I`row' = `r(p75)'
		putexcel J`row' = `r(p90)'
		putexcel K`row' = `r(max)'
		putexcel L`row' = `r(N)'
		
	}
	
}


* Set excel sheet
putexcel set "$resultsfolder\Green Variable Sum Stat", modify sh(Sum Stat by Year)

* Same but if the variable is not equal to 0 
foreach x in "broad" "narrow" {
	
	forvalues y = 2000/2019 {
		
		* Sum statistic
		qui sum green_`x' if year == `y' & green_`x' != 0  , d 
		
		if "`x'" == "broad" {
			* Set local row condition
			local row = `y' - 1952
		}
		if "`x'" == "narrow" {
			local row = `y' - 1932 
			
		}
	
		* Put excel
		putexcel B`row' = `y'
		putexcel C`row' = `r(mean)'
		putexcel D`row' = `r(sd)'
		putexcel E`row' = `r(min)'
		putexcel F`row' = `r(p10)'
		putexcel G`row' = `r(p25)'
		putexcel H`row' = `r(p50)'
		putexcel I`row' = `r(p75)'
		putexcel J`row' = `r(p90)'
		putexcel K`row' = `r(max)'
		putexcel L`row' = `r(N)'
		
	}
	
}




