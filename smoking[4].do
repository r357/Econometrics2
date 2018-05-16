* QUESTION 1

	sum smoker
	table smkban, c(mean smoker)
	
	* or
	
	reg smoker
	reg smoker if smkban==1
	reg smoker if smkban==0

* QUESTION 2

	reg smoker smkban

* QUESTION 3

	gen age2= age^2
	reg smoker smkban female age age2 hsdrop hsgrad colsome ///
		colgrad black hispanic 


* QUESTION 4

	testparm hsdrop-colgrad


* QUESTION 5

	reg smoker smkban female age age2 hsdrop hsgrad colsome ///
		colgrad black hispanic

	predict prob_smoke_ols, xb
	line prob_smoke_ols age if black==0&hispanic==0&female==0&colgrad==1&smkban==0, sort

* QUESTION 6
	sum prob_smoke_ols
	hist prob_smoke_ols

* QUESTION 7
	probit smoker smkban female age age2 hsdrop hsgrad colsome colgrad black hispanic  

	
* QUESTION 8

	est store a
	probit smoker smkban female age age2 black hispanic  
	est store b
	lrtest a b
	
	probit smoker smkban female age age2 hsdrop hsgrad colsome colgrad black hispanic  
	testparm hsdrop-colgrad


* QUESTION 9
	probit smoker smkban female age age2 hsdrop hsgrad colsome colgrad black hispanic  
	predict mra if female==0&black==0&hispanic==0&age==20&hsdrop==1&smkban==0
	sum mra

	predict mrb if female==0&black==0&hispanic==0&age==20&hsdrop==1&smkban==1
	sum mrb
	scalar effect = .401783-.4641021 
	scalar list effect


* QUESTION 10
	
	logit smoker smkban female age age2 hsdrop hsgrad colsome colgrad black hispanic  

* QUESTION 11
	
	qui probit smoker i.smkban i.female age age2 i.hsdrop i.hsgrad i.colsome i.colgrad i.black i.hispanic  
	margins, dydx(smkban) post
	est store probit_ame
	qui probit smoker i.smkban i.female age age2 i.hsdrop i.hsgrad i.colsome i.colgrad i.black i.hispanic  
	margins, dydx(smkban) atmean post
	est store probit_mem
	
	qui logit smoker i.smkban i.female age age2 i.hsdrop i.hsgrad i.colsome i.colgrad i.black i.hispanic  
	margins, dydx(smkban) post
	est store logit_ame
	qui logit smoker i.smkban i.female age age2 i.hsdrop i.hsgrad i.colsome i.colgrad i.black i.hispanic  
	margins, dydx(smkban) atmean post
	est store logit_mem
	
	est table  probit_ame probit_mem logit_ame logit_mem

