*Exercise 2

describe  // describe data

*a part 

sum

*b&c part

regress weeksm1 morekids //does fertility negatively affect labour supply (weeks worked)?
*negative effect: if a mother has more than 2 kids, weeks worked decreases by 5

*d part

reg morekids samesex //there is a correlation, F statistics is high: not a weak instrument

*e part

regress weeksm1 morekids 
estimates store ols 

ivregress 2sls weeksm1 (morekids=samesex), first //insturmented with samesex,  report first stage estimates
estimates store tsls

estimates table ols tsls  //significant change in coeff, weeks worked drop by 6 weeks here

*f part

ivregress 2sls weeksm1 (morekids=samesex) agem1 black hispan othrace, first
estimates store tsls_exp

estimates table ols tsls tsls_exp

*g part

regress morekids samesex agem1 black hispan othrace //results are the same as in 1st stage of 2sls
predict morekids_hat //choose name, you get rid of corr with error term

regress weeksm1 morekids_hat agem1 black hispan othrace
estimates store tsls_calc

estimates table tsls_exp tsls_calc

estimates table tsls tsls_calc
