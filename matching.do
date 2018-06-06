ssc install psmatch2, replace


cd "E:\Econometrics\DehejiaWahba"

* Experimental control
u nswre74.dta, replace

table treat, c(mean re78)
reg re78 treat

probit treat age age2 ed black hisp married nodeg re74 re75
predict pscore, pr

set seed 12345
g random = 15000*runiform()	
sort random

psmatch2 treat, pscore(pscore) outcome(re78) common n(1) noreplacement
psmatch2 treat, pscore(pscore) outcome(re78) common n(5) 
psmatch2 treat, pscore(pscore) outcome(re78) common radius caliper(0.01) 

pstest age age2 ed black hisp married nodeg re74 re75, sum both 


* Observational control
u cps1re74.dta, replace
reg re78 treat

probit treat age age2 ed black hisp married nodeg re74 re75
predict pscore, pr

set seed 12345
g random = 15000*runiform()	
sort random



psmatch2 treat, pscore(pscore) outcome(re78) common n(1) noreplacement
psmatch2 treat, pscore(pscore) outcome(re78) common n(5) 
psmatch2 treat, pscore(pscore) outcome(re78) common radius caliper(0.01) 

pstest age age2 ed black hisp married nodeg re74 re75, sum both 


reg re78 treat age age2 ed black hisp married nodeg re74 re75
