* Question 1
sum
tabulate choice
table choice, c(N case mean netincome mean children)

* Question 2
table choice, c(mean price1 mean price2 mean price3)

* Question 3
mlogit choice netincome children, baseoutcome(1)

* Question 4
test netincome
test childrenupto14years

* Question 5
margins, dydx(*) predict(outcome(1)) atmean
margins, dydx(*) predict(outcome(2)) atmean
margins, dydx(*) predict(outcome(3)) atmean

* Question 6
reshape long price, i(case) j(alternative)
label drop choice
replace choice=0 if choice!=alternative
replace choice=1 if choice==alternative

asclogit choice price, ///
	casevars(childrenupto14years netincome ) ///
	case(caseidentifier) alternatives(alternative) base(1)

* Question 7
estat mfx
	
	*Alternative for Q3
	asclogit choice , ///
		casevars(childrenupto14years netincome ) ///
		case(caseidentifier) alternatives(alternative) 


* Question 8

g pepsi = 1 if choice==1 & alternative==2
bysort caseidentifier: replace pepsi = 0 if choice==0 & alternative==2 &choice[_n-1]==1

g pricediff=price - price[_n-1] if pepsi!=.

 
logit pepsi  pricediff childrenupto14years netincome 
asclogit choice price if alternative!=3, ///
	casevars(childrenupto14years netincome ) ///
	case(caseidentifier) alternatives(alternative) base(1)



