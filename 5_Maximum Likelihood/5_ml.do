sysuse auto, replace

program mynormal1_lf
	args lnf mu sigma
	quietly replace `lnf' = ln(normalden($ML_y1, `mu', `sigma'))
end

ml model lf mynormal1_lf (mpg = weight displacement) ()
ml maximize
ml graph

reg mpg weight displacement

*lr test
ml model lf mynormal1_lf (mpg = weight displacement foreign) ()
ml maximize
scalar ll_full =e(ll)
dis ll_full
estimates store full

ml model lf mynormal1_lf (mpg = weight displacement) ()
ml maximize
scalar ll_rest =e(ll)
dis ll_rest
estimates store rest

scalar lr = 2*(ll_full - ll_rest)
scalar lrtest = chi2tail(1,lr)
dis lrtest

lrtest full rest


******

program find_max
	args one two
	local max = max(`one',`two')
	dis "The bigger number among `one' and `two' is `max'." 
end

find_max 3 5
