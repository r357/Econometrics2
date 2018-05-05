*** 	ECONOMETRICS II
*** 	EXERCISE CLASS #6 - TIME SERIES 1 (Univariate)
***

* preliminary settings
set more off
set memory 1g // not needed in Stata versions >10

* global path "insert location of your folder" 
	* global path "/path/to/your/dataset/may-need-one-final-slash/" // UNIX/MAC systems
	* global path "C:/Documents and Settings..." // WINDOWS
* or use the "cd" trick - cd "C:/..."
use "$path/SBITop_030406_220313.dta", clear // use global variable "$" called "path"

* generate counter variable - time index
gen t = _n
* set time index (MANDATORY to access Stata's TS toolbox)
tsset t
* plot univariate TS (plot >1 variable against time index)
tsline  sbitop

** STATIONARITY TESTS & DATA TRANSFORMATIONS **
* ADF Test for (non-)stationarity (H0: Unit root, H1: stationarity)
dfuller  sbitop
	* note: for HW type "help dfuller" to see other options like including trend, drift, excluding constants
* Phillips-Perron Test for unit roots (H0: Unit root, H1: stationarity), 
* PP Test uses Newey-West SEs to account for possible serial correlation whereas ADF Test includes lagged differences
* PP Test is outperformed by ADF Test in small samples [Davidson Mackinnon, 2009]
pperron sbitop

* From both test statistics it is obvious that H0: "sbitop has a unit root" cannot be rejected. 
* Need to transform the data to deal with the unit root.

*1st Solution: log tranform
gen ln_sbitop = ln(sbitop)
tsline  ln_sbitop
dfuller  ln_sbitop

*2nd Solution: detrending
reg sbitop t
predict trend, xb
tsline sbitop trend
gen detrend_sbitop =  sbitop - trend
tsline detrend_sbitop
dfuller detrend_sbitop

*3rd Solution: take differences 
gen d_sbitop = sbitop - sbitop[_n-1]
tsline d_sbitop
dfuller d_sbitop

*4th solution: take differences of logs = transform to GROWTH RATES
gen r = ln_sbitop -  l.ln_sbitop
tsline r
dfuller r

*5th solution: apply a TS filter - here we go with HP filter to extract the CYCLICAL component
	* problematic as frequencies get mixed up and time causality is NOT preserved (mixing of t, t-1 and t+1)
tsfilter hp hp_sbitop = sbitop, smooth(110930628906.25) trend(hp_sbitrend)
	* set smoothing parameter lambda = 1600*(365/4)^4 = as we're dealing with daily data (Ravn-Uhlig)
tsline hp_sbitop hp_sbitrend
dfuller hp_sbitop

********************************
*IDENTIFICATION OF ARIMA MODELS*
********************************

* calculate a correlogram
corrgram sbitop
* graph autocorrelations
ac sbitop, name(graph1) // plot autocorrelations of sbitop, save graph in memory under "name(graph1)"

ac r, name(graph2)
graph combine graph1 graph2 // combine and stack both graphs together, default is columnwise
graph combine graph1 graph2, cols(1) // stack graphs in rows

* Different ways to specify an AR(1) model in Stata
gen lag_r = r[_n-1] // generate lagged growth rates r
reg r lag_r // AR(1) model r(t) = rho * r(t-1) + alpha + u(t)
		estimates store Rreg
reg r l.r  // alternative specification of AR(1) model, avoids generating a new variable
		estimates store RregLR
arima r, ar(1) // maximize likelihood for ARIMA(1,0,0) = AR(1) 
		estimates store Rarima100
		estimates table Rreg RregLR Rarima100	
	* all three procedures produce (almost) identical estimates for autoregressive coefficient

* graph (partial) autocorrelations for growth rates 
pac r
ac r

* specify and maximize different ARMA models
arima r, ar(1) // ARIMA(1,0,0)=ARMA(1,0)=AR(1)
estat ic // calculate the Information Criterion
	* as part of its post-estimation options Stata has the ability to calculate various Infomation Criteria 
	* like AIC (Akaike), BIC (Bayesian), the log-likelihood... to help a practitioner assess which model should 
	* be selected optimally (viz., one that minimizes the chosen IC!).

* Some other options :
arima r, ar(1/2) // ARMA(2,0)=AR(2)
estat ic

arima r, arima(1,0,1) //ARIMA(1,0,1)=ARMA(1,1)
estat ic

arima r, arima(2,0,1) //ARIMA(2,0,1)=ARMA(2,1)

* BTW: order of integration can be included directly in ARIMA specifiactions
* thus allowing one to work with original variable
arima r, arima(1,0,1) // r = ln(sbitop[t]) - ln(sbitop[t-1]) = ln(sbitop[t]/sbitop[t-1])
		estimates store Rarima101
arima ln_sbitop, arima(1,1,1) 
		estimates store LSarima111
		estimates table Rarima101 LSarima111 //identical.

* BTW : use this loop for model selection
forv i=1(1)5{
quietly arima sbitop,arima(`i',1,0)
estat ic
}
* according to BIC AR(2) model is the best 
		
********************
*HETEROSKEDASTICITY*
********************

* let's keep the AR(1) model from before
reg r l.r

* is there a potential heteroskedasticity problem?
estat archlm // H0 clearly rejected

* what exactly is this LM test?
predict e, residuals
	tsline e, name(resids) // plot residuals
gen e2 = e^2
	tsline e2, name(resids2) // plot squared residuals
	graph combine resids resids2, cols(1)
		* notice time variation in residuals and squared residuals exhibiting "volatility bunching"
reg e2 l.e2  // regress eps^2[t] on eps^2[t-1] ~ essence of ARCH here
scalar LM = e(N) * e(r2)
scalar p_value = chi2tail(1, LM)
scalar list LM p_value

* fit an ARCH model, compare volatilities 
reg r l.r
estat archlm, lags(1)
arch r, arch(1)
predict volatility, variance // predict calculates the volatility part of the ARCH model
	tsline volatility, name(volatility) //plot volatility
graph combine resids resids2 volatility, cols(1)

* compare ARCH and GARCH models
arch r, arch(1) garch(1) // GARCH(1,1)
estat ic
arch r, arch(1) // GARCH(1,0)=ARCH(1)
estat ic

*ARMA-GARCH model
arch  r l.r, arch(1) garch(1) // ARMA(1,0) + GARCH(1,1) part
estat ic

* Concluding note: We didn't dvelve into the field of Model Selection too much here.
* The "estat ic" command lets one extract LL, AIC, BIC values which are then used to compare models and allow
* a practitioner selects the optimal model based on some selection criterion. 
