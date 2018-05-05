*global path "insert location of your folder"
use "$path\3_NewGas.dta", clear

***************
** Problem 1 **
***************
** Beta Coefficients **
***********************
* part a) and b)
***********************

gen gasqpc = gasq / pop

*Run simple (original) regression
reg gasqpc pcincome

*Save residual sum of squares and coefficients
scalar rss = e(rss)
matrix b = e(b) 

*  scalar list rss
* matrix list b

*You can check that
display rss
matrix list b

/*In order to standardize variables and calculate transformed residual sum of
squares or transformed coefficients you have to obtain standard deviation and mean*/
sum gasqpc
* ereturn list
scalar gasqpc_sd = r(sd)
scalar gasqpc_mean = r(mean)
sum pcincome
scalar pcincome_sd = r(sd)
scalar pcincome_mean = r(mean)

*Calculate transformed residual sum of squares
scalar rss_star = rss / gasqpc_sd^2

*Calculate transformed coefficients
matrix b_star = b * pcincome_sd / gasqpc_sd

*Standardize variables
gen gasqpc_star = gasqpc / gasqpc_sd
gen pcincome_star = pcincome / pcincome_sd

/*Run transformed regression: residual sum of squares has to be equal to sse_star
and the coefficient for educyr has to be equal to the one in b_star*/
* We don't bother about the constant
reg gasqpc_star pcincome_star
dis rss_star
matrix list b_star

*Standardize variables also in a "proper" way (by subtracting the mean first)
gen gasqpc_truestd = (gasqpc - gasqpc_mean) / gasqpc_sd
gen  pcincome_truestd = ( pcincome -  pcincome_mean) / pcincome_sd

/*Run regression on "properly" standardized variables: the residual sum of squares
and the coefficient are still the same*/
reg gasqpc_truestd pcincome_truestd


***************
** Problem 2 **
**************************
** Frisch-Waugh Theorem **
**************************

* part a)
*Run regression of Y (gasqpc) on X1(pcincome) and X2(gasp)
reg gasqpc pcincome gasp

* part b)
*Store residuals from the regression of Y on X1
reg gasqpc pcincome
predict gasqpc_res, resid

*Store residuals from the regression of X2 on X1
reg gasp pcincome
predict gasp_res, resid

*Run double-residual regression: the coefficient for X2 is the same
reg gasqpc_res gasp_res

* part c)
*Run regression of Y on residuals from the regression of X2 on X1: the coefficient for X2 is the same
reg gasqpc gasp_res

* part d)
*Run regression of residuals from the regression of Y on X1 on X2: the coefficient for X2 is different
reg gasqpc_res gasp


***************
** Problem 3 **
***********************
** Multicollinearity **
***********************

* Y: gasqpc, Block X1: 1 gasp pcincome, Block X2: pd pn ps
reg gasqpc gasp pcincome pd pn ps

* Residuals (Block Z)
reg pd gasp pcincome
predict res_pd, resid
reg pn gasp pcincome
predict res_pn, resid
reg ps gasp pcincome
predict res_ps, resid

reg gasqpc gasp pcincome res_pd res_pn res_ps

* INCORRECT - omitted variable bias
reg gasqpc gasp pcincome
