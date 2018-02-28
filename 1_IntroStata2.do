******************
** Global Macro **
******************
global path "insert location of your folder"

* Menu can be usful

********************
** Basic Settings **
********************

* In order to save results, you should start logging"
log using "$path\IntroStata.smcl", replace

* If you are using same commands frequently, it is wise to produce the .do file

query mem

* Change the memory settings
set matsize 500
set maxvar 4000
query mem

* Permanently changed settings
set matsize 400, perm


*********************
** Data Management **
*********************

* .dta files are opend with:
use "$path\mus03data.dta", clear

* .csv files are opened with:
insheet using "$path\test.csv", delimiter(;) clear

/* If you have the following data set:
	2005	7	John
	2006	9	Sarah
 in a .txt file, you should use infile command. But you have to list the names of the variables first. str20 before the variable name is needed, since names are strings (Stata 
 assumes that everyting is a number. */
 infile year grade str20 name using "$path\test.txt", clear

* Alternative way of creating a data set
clear
set obs 100

* Uniformly distributed random variable on interval [0,1)
generate x = uniform()

* Whatever
g we ="nbld"
drop we

* To get previously used commands - use the PageUp and PageDown keys


*****************
** Data Review **
*****************

use "$path\mus03data.dta", clear

describe
d age famsze

summarize
sum totexp if age>=70
sum famsze in 1/10
list famsze in 1/10
sum famsze, detail

*************************************
** Merging and Appending Data Sets **
*************************************

* Create two data sets with different variables

keep dupersid age educyr totexp
sort dupersid
save "$path\small", replace  

u "$path\mus03data", clear
drop age educyr totexp
sort dupersid 

*when merging two files, both have to be sorted by the merging variable
merge using "$path\small"
drop _merge
order du* age educyr totexp 

*Create two data sets with different observations
sort du*
preserve 
display _N
* Number of all observations: _N
keep in 1/100
dis _N
sa "$path\first100.dta", replace
restore
di _N
keep in 101/200

* Preserve - stores the current state of the data
* Restore - restores the preserved state of the data (can only be used once with each preserve command)

append using "$path\first100.dta"
dis _N

*************************
** Data Transformation **
*************************

rename dupersid id 

g lnexp = ln(totexp)
g age_sq = age^2
g MW_NE = mwest + northe

g lnincome = ln(income)
replace lnincome = 0 if lnincome == .
* Careful: double == in conditions
* Missing value: .
replace totexp = totexp/1000

sum income
egen max_inc = max(income)
bysort northe mwest south (id): egen mean_inc = mean(income)
* Mean calculated by region, sorted by region AND id

preserve
collapse (mean) avg_inc=income (median) med_income=income, ///
	 by(northe mwest south)
* In brackets: parameter for the variable that follows. Default: mean.	 
sa "$path\income.dta", replace
restore

label var age_sq "A square of age"

tabulate female white
label define labelfemale 0 "Male" 1 "Female"
label values female labelfemale 
tab female white


*************************************
** Plots and Distributional Graphs **
*************************************

twoway scatter totexp income 
twoway scatter totexp income if retire!=1, by(female)

twoway hist lnexp

******************
** Local Macros **
******************

local abc "totexp income female white famsze marry"
sum `abc'
* Careful with the single quotes! Left: AltGr+7, Right: usual English apostrophe
regress `abc'

local x=1
local y=2
scalar z=`x'+`y'
dis z

***************
** For loops **
***************

local abc "totexp income female white famsze marry"

foreach x of local abc {
	egen mean_`x' = mean(`x')
	label var mean_`x' "Mean of `x'"
}

forvalues i=0(1)17 {
	egen mean_inc_`i' = mean(income) if educyr == `i'
	label var mean_inc_`i' "Mean income for persons with `i' years of education"
}	

*************
** Program **
*************

* _n - a line space
* 1 - consecutive number of the argument (our little program has only one argument

program define MyProg
	dis _n "Description of `1'"
	describe `1'
	dis _n
	quietly gen log`1' = ln(`1')
	dis _n "Summary statistics"
	sum log`1' `1'
	dis _n
end

MyProg income
MyProg age

*******************************
** Basic matrix manipulation **
*******************************

matrix A = (1 , 2 \ 3, 0)
matrix list A
scalar a21 = A[2,1]
dis a21
matrix P = (A') * A
matrix list P
dis det(P)
dis trace(P)
matrix IP = inv(P)
matrix list IP
matrix U3 = I(3)
matrix list U3

*Mata module

mata
B = (1,2 \ 3,0)
B
B[2,1]
B'B
det(B'B)
trace(B'B)
pinv(B'B) 
*pseudoinverse
I(3)
end


********************
** End of Session **
********************

log close

exit
