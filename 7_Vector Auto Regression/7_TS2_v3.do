*** 	ECONOMETRICS II
*** 	EXERCISE CLASS #7 - TIME SERIES 2 (Multivariate)
***

************************************
*VAR (Vector AutoRegression models)* - models with more interdependent AR variables
************************************

/*
Description of variables:
time - time index
inflation - consumer price index
unrate - unemployment
fedfunds - interest rate
*/
clear
* preliminary settings
set more off
//set memory 1g // not needed in Stata versions >10

* global path "insert location of your folder" 
	* global path "/path/to/your/dataset/may-need-one-final-slash/" // UNIX/MAC systems
	* global path "C:/Documents and Settings..." // WINDOWS
use "monVAR.dta", clear

* do some summary statistics
summarize 

* set time as TS index variable
tsset date

* plot the original variables 
tsline fedfunds 
tsline inflation
tsline unrate //clearly non-stationary

* test dfuller
dfuller fedfunds
dfuller inflation
dfuller unrate //only one rejecting H0: unit root

* OR create growth rates
gen dinflation = D.inflation
gen dunrate = D.unrate
gen dfedfunds = D.fedfunds

tsline dinflation dunrate dfedfunds


* choosing the number of lags included on the basis of IC using "varsoc", VAR with the lowest IC is the best
varsoc inflation unrate fedfunds
varsoc inflation unrate fedfunds, maxlag(6) exog(date)
	* star denotes the best model

* estimate the VAR
var unrate inflation fedfunds, lags(1/4) 

* perform Wald lag-exclusion tests
varwle

* testing for residual autocorrelation (if sample is small AC may be detected too often...)
	* H0: no autocorrelation at lag
varlmar, mlag(4)

* test residuals for being normally distributed using Jarque-Berra test 
	* H0: normal distribution
* varnorm, jbera skewness kurtosis

* testing for model stability - if eigenvalue |z|>1 ~ model is explosive
	* Stata follows this: det( I - A1*z - A2*z^2 - A3*z^3 - ...) = 0
varstable

** testing Granger causality 
	* H0: no Granger-cause
* vargranger

*********************************
*IRF (Impulse Response Function)*
*********************************

* first we have to define a file that will contain the calculations
irf set "IRS1"

* first attempt at calculating IR1, time horizon is 12 periods, variable order as in economic theory 
* (from the most exogenous of the dependent variables to the most endogenous)
irf create IRS1, step(48) order(unrate inflation fedfunds)
* irf drop IRS1 //drop IR1 (if in memory)


*IRF Graphs
irf graph oirf, irf(IRS1)
*or separately
irf graph oirf, irf(IRS1) impulse(lnprod)
irf graph oirf, irf(IRS1) impulse(r)
irf graph oirf, irf(IRS) impulse(infl)



*********************************
*IRF (Impulse Response Function)*
*********************************
* FOR DIFFERENCES *
var dunrate dinflation dfedfunds, lags(1/4) 
varlmar, mlag(4)
varstable

* first we have to define a file that will contain the calculations
irf set "IRS2"

* first attempt at calculating IR1, time horizon is 12 periods, variable order as in economic theory 
* (from the most exogenous of the dependent variables to the most endogenous)
irf create IRS2, step(48) order(dunrate dinflation dfedfunds)


*IRF Graphs - note cirf - stands for cumulative IRS
irf graph cirf, irf(IRS2)

