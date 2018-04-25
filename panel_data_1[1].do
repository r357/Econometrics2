
u "C:\...\ajpes.dta",replace 

* EXERCISE 1
	sum 
	xtset id year
	xtsum


* EXERCISE 2
	bysort id (year): egen size_bar_i = mean(Size)
	egen size_bar = mean(Size)

	*within
	g w_s = Size - size_bar_i  
	sum w_s
	xtsum Size
	
		
	*between
	preserve
		bysort id (year): g n =_n
		list in 1/10
		keep if n==1
		list in 1/10
		sum size_bar_i
	restore
	xtsum Size
	

	*overall
	sum Size

* EXERCISE 3

	foreach var in va_emp capital_labor gov_purc {
		g l`var' = ln(`var')
	}
	replace lgov_purc = ln(0.0001) if gov_purc==0

	xi: reg lva_emp lgov_purc lcapital_labor Size region ///
		i.nace2008_2  i.year

	xi: reg lva_emp lgov_purc  lcapital_labor Size region ///
		i.nace2008_2  i.year, vce(cluster id)	
	estimates store OLS


* EXERCISE 6

	*lsdv
	tabulate id, g(firm)
	set matsize 800
	xi: reg lva_emp lgov_purc  lcapital_labor Size region ///
		i.nace2008_2  i.year firm*, nocons vce(cluster id)
	estimates store LSDV
	
	* fd
	xi: reg d.(lva_emp lgov_purc  lcapital_labor Size region ///
			i.nace2008_2  i.year), nocons vce(cluster id)
	estimates store FD
	
	* fe
	xi: xtreg lva_emp lgov_purc  lcapital_labor Size region ///
		 	i.nace2008_2 i.year, fe vce(cluster id)
	est store FE
	
	est table OLS LSDV FD FE,  ///
		keep(lgov_purc 	d.lgov_purc ) ///
		b(%7.3f) 	se(%7.3f) p(%7.3f) 
	
	
	
* EXERCISE 7

	*within transformation of vars
	foreach var in lva_emp lgov_purc  lcapital_labor Size region ///
	_Inace2008__41 _Inace2008__46 _Inace2008__56 _Inace2008__62 _Inace2008__65 ///
	_Inace2008__64 _Inace2008__66 _Inace2008__68 _Inace2008__69 _Inace2008__70 ///
	_Inace2008__74 _Inace2008__77 _Inace2008__81 _Inace2008__94 ///
	_Iyear_2010 _Iyear_2011 _Iyear_2012 ///
		_Iyear_2013 {
			bysort id (year): egen avg_`var' = mean(`var')
			gen w_`var'= `var' - avg_`var'
		}

	*estimate fe regression
	reg  w_lva_emp w_lgov_purc w_lcapital_labor w_Size ///
		w_region  w__I*, nocons vce(cluster id)
	est store fe_byhand
	
	est table OLS LSDV FD FE fe_byhand,  ///
		keep(lgov_purc 	d.lgov_purc w_lgov_purc) ///
		b(%7.3f) 	se(%7.3f) p(%7.3f) 

		

