*global path "insert location of your folder"
use "$path\NewGas.dta", clear

***************
** Problem 1 **
***************

* part a)

gen gasqpc = gasq / pop
gen t = _n

reg gasqpc gasp pcincome pd pn ps t
* we need this for later
predict e_a, resid
gen e2_a = e_a^2
scalar TSS_a = e(mss) + e(rss)
scalar list  TSS_a
/* or
predict fit_a, xb
gen e2_a = (gasqpc - fit_a)^2
*/ 
 

* part b)

gen lngasqpc = ln( gasqpc)
gen lngasp = ln(gasp)
gen lnpcincome = ln(pcincome)
gen lnpd=ln(pd)
gen lnpn=ln(pn)
gen lnps=ln(ps)
reg lngasqpc lngasp lnpcincome lnpd lnpn lnps t
predict fit_b, xb
gen e2_b = (gasqpc - exp(fit_b))^2

* R2 from the two regressions are not directly comparable
summ  e2_a e2_b
* can compare R2_a with modified R2_b
* display 1-(e2_a/TSS_a)   - need to check
display 1-(e2_b/TSS_a)


***************
** Problem 2 **
***************

gen upto73 = 0
replace  upto73 =  lngasp  if  year <= 1973
gen after73=0
replace  after73 =  lngasp  if  year >  1973

reg lngasqpc upto73 after73 lnpcincome t
reg lngasqpc lngasp after73 lnpcincome t

/* The coefficient for lngasp in the second regression is the same as the 
coefficient for upto73 in the first regression.
The coefficient for after73 in the second regression is a difference between 
the coefficients for after73 in the first regression 
and lngasp in the second regression. */
* intuition
display  -.1990931    + .0192078
* you could compute the second coeffs from the first one 
display -.1798853 - -.1990931

***************
** Problem 3 **
***************

reg gasqpc pcincome
reg gasqpc pcincome, noconst

* R2 for the model without a constant is higher?! 
* Remove the mean from the dfependent variable
egen gasqpc_mean = mean(gasqpc)
gen gasqpc_0mean = gasqpc - gasqpc_mean

reg gasqpc_0mean pcincome
reg gasqpc_0mean pcincome, noconst

egen pcincome_mean = mean(pcincome)
gen pcincome_0mean = pcincome - pcincome_mean
reg gasqpc_0mean pcincome_0mean, noconst


tw (sc gasqpc pcincome) (lfit gasqpc pcincome)
tw (sc gasqpc pcincome) (lfit gasqpc pcincome)


***************
** Problem 4 **
***************

reg lngasqpc lngasp lnpcincome lnpd lnpn lnps t

/* You can use the Menu: 
Statistics --> Linear models and related --> Constrained linear regression */
constraint define 1 lnpd+ lnpn+ lnps=1
constraint define 2 t=0
cnsreg lngasqpc lngasp lnpcincome lnpd lnpn lnps t, constraints(1 2)

* Calculate R2 for the constrained regression, total sum of squares remains the same
scalar rss = e(rmse) ^2 * e(df_r)
* scalar r_2 = 1 - rss / 2.90079713 (total sum of squares)
* Total sum of squares for a variable (dependent in this case) is used in calculating its variance:
* Variance = total sum of squares / (n -1)
sum lngasqpc
scalar r_2 = 1 - rss / ( r(sd)^2 * (_N- 1) )
dis r_2




*****************
*** Problem 5 ***
*****************

* part a)

corr lngasqpc lngasp
pwcorr lngasqpc lngasp, sig

reg lngasqpc lngasp lnpcincome

* Additional ..
*  correlate  lngasqpc lngasp, covariance
* b from reg lngasqpc lngasp:  display .137824/.461029 
* point is, like correlation coefficient b from reg lngasqpc lngasp accounts for total effect of lngasp on lngasqpc 
* b from reg lngasqpc lngasp lnpcincome accounts for net effect, the effect that occurs once you control for income
* more appropriate measure would be partial correlation coefficient!:
* pcorr lngasqpc lngasp lnpcincome

* part b)
reg lngasqpc lngasp lnpcincome lnpd lnpn lnps t
test lnpn = lnpd = lnps = 0

* Calculating the F-test value
scalar r2 = e(r2)
scalar df = e(df_r)

* Restricted regression
reg lngasqpc lngasp lnpcincome t
scalar r2_r = e(r2)

scalar F = ((r2 - r2_r) / 3) / ((1- r2) / df)
dis F

* Additional
* display Ftail(df1,df2,F) - computes right-tail p value
* display invFtail(df1,df2,alpha) = display invFtail(3,df,.05) - computes right tail critical value


* part c)
reg lngasqpc lngasp lnpcincome lnpd lnpn lnps t after73
test after73=0

* If only 1 restriction: t = sqrt(F), same P-value
dis sqrt(1.67)
