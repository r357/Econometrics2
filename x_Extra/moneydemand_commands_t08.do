* a) Data exploration

tsset time

describe
sum hm1 ppr rvp rvv czp
inspect hm1
list hm1 ppr pgo pdr rvp rvv czp

scatter hm1 ppr
scatter hm1 rvp
scatter hm1 rvv
scatter hm1 czp

* b) Estimation of the linear money demand function

regress hm1 ppr rvp rvv czp

* c) Hypotheses testing

test rvp=10*rvv
test rvv=-czp

* d) Estimation of the log-linear money demand function

gen lhm1=log(hm1)
gen lppr=log(ppr)
gen lrvp=log(rvp)
gen lrvv=log(rvv)
gen lczp=log(czp)

regress lhm1 lppr lrvp lrvv lczp

* e) Model diagnostics - Normality of the disturbances

qui regress hm1 ppr rvp rvv czp

predict res, resid
predict fit, xb
list hm1 fit res

histogram res, normal
kdensity res, normal

sum res, detail
return list
scalar obs=r(N)
scalar sk=r(skewness)
scalar ku=r(kurtosis)
scalar jb=obs*(sk^2/6 + (ku-3)^2/24)
display jb
display chi2tail(2,jb)

jb6 res

* f) Model diagnostics - Multicollinearity

regress ppr rvp rvv czp /* Example of calculation for variable PPR */
scalar R2ppr=e(r2)
scalar VIFppr=1/(1-R2ppr)
display VIFppr

qui regress hm1 ppr rvp rvv czp
estat vif

* g) Model diagnostics - Homoscedasticity

gen res2=res^2

scatter res2 fit

scatter res2 ppr
scatter res2 rvp
scatter res2 rvv
scatter res2 czp

gen ppr2=ppr^2 /* Perform White test manually */
gen rvp2=rvp^2
gen rvv2=rvv^2
gen czp2=czp^2
gen pprrvp=ppr*rvp
gen pprrvv=ppr*rvv
gen pprczp=ppr*czp
gen rvprvv=rvp*rvv
gen rvpczp=rvp*czp
gen rvvczp=rvv*czp
regress res2 ppr rvp rvv czp ppr2 rvp2 rvv2 czp2 pprrvp pprrvv pprczp rvprvv rvpczp rvvczp
ereturn list
scalar theta=e(N)*e(r2)
display theta, chi2tail(e(rank)-1,theta)

qui regress hm1 ppr rvp rvv czp
estat imtest, white

regress hm1 ppr rvp rvv czp, robust

* h) Model diagnostics - Autocorrelation

twoway connected res time

scatter res l.res
scatter res l4.res

gen res_l1=res[_n-1] /* Perform Breusch-Godfrey test manually, AR(4) */
gen res_l2=res[_n-2]
gen res_l3=res[_n-3]
gen res_l4=res[_n-4]
regress res ppr rvp rvv czp res_l1 res_l2 res_l3 res_l4
scalar lm=e(N)*e(r2)
display lm, chi2tail(4,lm)

qui regress hm1 ppr rvp rvv czp
estat bgodfrey, lags(4) nomiss0

estat bgodfrey, lags(1 2 3 4 5 6 7 8 9 10 11 12)
estat bgodfrey, lags(1/12)
estat bgodfrey, lags(1/90)

newey hm1 ppr rvp rvv czp, lag(78)
