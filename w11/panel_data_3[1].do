 use "...\mus08psidextract.dta", replace

 desc

* Summary of dataset
summarize

* Declare individual identifier and time identifier
xtset id t

* Panel description of dataset
xtdescribe 

* Panel summary statistics: within and between variation
xtsum 

* Panel tabulation for a variable
xttab south

* Transition probabilities for a variable
xttrans south, freq

* Simple time-series plot for each of 20 individuals
quietly xtline lwage if id<=20, overlay 


* Optimal or two-step GMM for a pure time-series AR(2) panel model
xtabond lwage, lags(2) twostep vce(robust)

* Optimal or two-step GMM for a pure time-series AR(2) panel model
xtabond lwage, lags(2) twostep vce(robust) maxldep(1)
xtabond lwage, lags(2) twostep vce(robust) maxldep(2)
xtabond lwage, lags(2) twostep vce(robust) maxldep(3)

 * Optimal or two-step GMM for a dynamic panel model
xtabond lwage occ south smsa ind, lags(2) maxldep(3)     ///
  pre(wks,lag(1,2)) endogenous(ms,lag(0,2))              ///
  endogenous(union,lag(0,2)) twostep vce(robust) 
  
* Test whether error is serially correlated
estat abond, artests(3)


* Test of overidentifying restrictions (first estimate with no vce(robust))
quietly xtabond lwage occ south smsa ind, lags(2) maxldep(3) ///
  pre(wks,lag(1,2)) endogenous(ms,lag(0,2))              ///
  endogenous(union,lag(0,2)) twostep 
estat sargan


