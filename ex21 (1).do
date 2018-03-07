**************************
** Law of Large Numbers **
**************************

set obs 100000

* set seed 0

generate y = uniform()
gen roll = int(6 * y) + 1
tab roll
hist(roll)

g sum_roll = sum(roll)

* Note the difference: egen sum = sum(roll) !!!

g n = _n
g mean_roll = sum_roll / n

twoway(line mean_roll n)
twoway(line mean_roll n) if n< 50

* or

tsset n
tw(tsline mean_roll)

* mean roll

**************************************
** Cumulative Distribution Function **
**************************************

* displays probability of a standard normal variable x being smaller or equal to sqrt(2)
display normal(sqrt(2))
* displays the value on x-axis such that 50% of the probability mass is to the left of that value, or 50% of values of x are smaller or equal t this value 
display invnormal(0.5)



***********************************************************************************************************************
*****************  REDUNDANT *********
*****************  SOME INTUITION ****
twoway function y=normalden(x), range(-4 4) xtitle("{it: x}") ytitle("Density") title("Standard Normal Distribution")
twoway function y=normalden(x,2,10), range(-48 52) xtitle("{it: x}") ytitle("Density") title("Standard Normal Distribution")



* percent of points lying to the left of 0. OR probability of x, drawn from standard normal, being smaller than 0.
display normal(0)    
* displays the value on x-axis such that 50% of the probability mass is to the left of that value, or 50% of values of x are smaller or equal t this value 
display invnormal(0.5)


* ten tsds from the mean to the right:
display normal(1)


* 3.a
display normal(2/sqrt(2))
* 3.b
display normal(-1/3)


********************** CALCULATE *****
**************************************
di .005/.34

