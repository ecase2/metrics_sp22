/* 
	applied metrics
	problem set 2 
	emily case
*/
log using "/Users/emilycase/Desktop/metrics sp22/ps2/merics_ps2_log.log", replace

clear all
cd "/Users/emilycase/Desktop/metrics sp22/ps2"


use "NSW_Data"

// drop observations from the PSID comparison group.
	drop if sample == 3

// gen age^2
	gen age2 = age*age 

// store independent variables
	local indep = "treated age age2 educ black hisp married nodegree re74 re75"

	pause on

*----------------------*
* 		question 1 		  *
*----------------------*	
eststo q1: reg re78 `indep', robust

	quietly{ 
				#delimit ;
				esttab q1 using "tables/q1.tex", replace
				b(2) se(2)  nostar booktabs
				title(Question 1\label{q1})
				nonum mtitles("1978 real earnings");
				#delimit cr
				}
				
				
*----------------------*
* 		question 2 		  *
*----------------------*
// drop the experimental treated group
	drop if treated == 1 & sample == 1


*----------------------*
* 		question 3 		  *
*----------------------*
* create treated2 dummy for if they were in the experiment group or not 
* everyone is untreated in the sample we have remaining
gen treated2 = (sample ==1 )

// create the coarse propensity scores 
eststo q3a: probit treated2 age age2 educ black hisp married nodegree 
predict pscorea

//create the rich propensity scores
eststo q3b: probit treated2 age age2 educ black hisp married nodegree re74 re75 
predict pscoreb

		quietly{ //table
				#delimit ;
				esttab q3a q3b using "tables/q3.tex", replace
				b(4) se(2)  booktabs
				title(Probit models\label{q3})
				mtitles("Coarse" "Rich") nonum nostar;
				#delimit cr
				}

				
*----------------------*
* 		question 4 		  *
*----------------------*

* summarize propensity scores and store the scalars for a table
sum pscorea if treated2 == 0
	sca a0mean = r(mean)
	sca a0min  = r(min)
	sca a0max  = r(max)
sum pscorea if treated2 == 1
	sca a1mean = r(mean)
	sca a1min  = r(min)
	sca a1max  = r(max)
sum pscoreb if treated2 == 1
	sca b1mean = r(mean)
	sca b1min  = r(min)
	sca b1max  = r(max)
sum pscoreb if treated2 == 0
	sca b0mean = r(mean)
	sca b0min  = r(min)
	sca b0max  = r(max)


	
	
*----------------------*
* 		question 5 		  *
*----------------------*

foreach i in a b{
	egen bins`i'=cut(pscore`i'), at(0(0.05)1) icodes 
		* put the pscores into bins, binsa is a variable saying what bin they're in
	graph bar (count) pscore`i' if bins`i'>0, over(treated2) over(bins`i', label(nolab)) asyvars
	graph export q4_pscore`i'.png, replace
}


*----------------------------*
* 		question 6 and 7 		  *
*----------------------------*

* 6: impose the common support condition, without replacement
* 7: same, but with replacement: 


foreach r in nor r{	
	foreach i in a b{
		if "`r'" == "nor" {
			display "Without replacement (q6), using pscore`i':"
			eststo `r'psmatch2`i': psmatch2 treated2, noreplacement outcome(re78) pscore(pscore`i') neighbor(1) common
			} //run the noreplacement psmatch2
		else   		 {
			display "With replacement (q7), using pscore`i':"
			eststo `r'psmatch2`i': psmatch2 treated2, outcome(re78) pscore(pscore`i') neighbor(1) common 
			} //run the replacement psmatch2
			
		// look at the _support variable:
		list pscore`i' if _support == 0
		
			 
			// store the scalar results for the ATT
			sca `r'_diff_att`i' = r(att)
			sca `r'_se_att`i'	 = r(seatt)
	
		qui esttab `r'psmatch2`i', se 
			//store the scalar results for the unmatched 
			sca `r'_diff_unm`i' = r(coefs)[1,1]
			sca `r'_se_unm`i'	 = r(coefs)[1,2]
	}
}


*----------------------*
* 		question 8 		  *
*----------------------*
// create the raw data standardized differences 
	// averaging the differences between re74 and re75 by treated2...
	// based on the notes formula page 26. 
stddiff re74 re75, by(treated2)
	// store scalars for table
		sca raw_sdiff_re74 = 100*r(stddiff)[1,1]
		sca raw_sdiff_re75 = 100*r(stddiff)[2,1]
		
		di "The SDIFF of re74 using raw data is " raw_sdiff_re74
		di "The SDIFF of re75 using raw data is " raw_sdiff_re75

// rematch but using the rich scores single nearest neighbor with replacement
// std diff for re74 
psmatch2 treated2, outcome(re74) pscore(pscoreb) neighbor(1) common
	// numerator of the standardized differences formula:
	// treated ATT - control ATT 
		sca numerator_74 = r(att)
		
	// denominator is the pooled sd of the covariate in the treated and untreated samples
		// variance of re74 for treated and untreated 
			sum re74 if treated2 == 1
				sca treatedvar_74 = r(Var)
			sum re74 if treated2 == 0
				sca untreatvar_74 = r(Var)
		// average variances and sqrt to get the pooled sd 
		sca denominator_74   = sqrt( (treatedvar_74 + untreatvar_74)/2)
		
	// sdiff(re74) using rich scores and single nn with replacement:
		sca sdiff_re74 = 100*(numerator_74 / denominator_74)
		di "The SDIFF of re74 using rich scores and single nn with replacement is "sdiff_re74
		

// std diff for re75
psmatch2 treated2, outcome(re75) pscore(pscoreb) neighbor(1) common 
	// numerator 
		sca numerator_75 = r(att)
		
	// denominator 
		sum re75 if treated2 == 1
			sca treatedvar_75 = r(Var)
		sum re75 if treated2 == 0
			sca untreatvar_75 = r(Var)
		sca denominator_75 = sqrt( (treatedvar_75 + untreatvar_75)/2)
		
	// sdiff(re75) using rich scores and single nn with replacement
		sca sdiff_re75 = 100*(numerator_75/denominator_75)
		di "The SDIFF of re75 using rich scores and single nn with replacement is " sdiff_re75

// calculate the proportionate reduction in the standardized bias (just a percent change?)
	// note: I did this by hand first, and so the negatives are kind of wonky. Pretty sure this is right though. 
		sca biasreduc_74 = round(100*(raw_sdiff_re74 + sdiff_re74)/ raw_sdiff_re74, 0.01)
		di "Using rich propensity scores reduced the standardized bias of earnings in 1974 by " biasreduc_74 "%"

		sca biasreduc_75 = round(100*(raw_sdiff_re75 + sdiff_re75)/ raw_sdiff_re75, 0.01)
		di "Using rich propensity scores reduced the standardized bias of earnings in 1975 by " biasreduc_75 "%"

		
*----------------------------*
* 		question 9 and 10 	  *
*----------------------------*
foreach q in 9 10{ // loop over question number (llr or kernel)
	foreach ban in 0.02 0.2 2.0 { //loop over bandwidths
	
				* need to number the bandwidths 1 2 and 3
				if `ban' == 0.02 {
					local bancount = 1
				}
				else if `ban' == 0.2 {
					local bancount = 2
				}
				else {
					local bancount = 3
				}
	
		* tell it which psmatch to do:
		if `q' == 10{ //q10 is llr
			display "This match is made using linear (q10) matches of bandwidth `ban':"
			eststo q10_`bancount': psmatch2 treated2, outcome(re78) pscore(pscoreb) llr bwidth(`ban') common
			
		}
		else { //q9 is kernel
			display "This match is made using kernel (q9) matches of bandwidth `ban':"
			eststo q9_`bancount': psmatch2 treated2, outcome(re78) pscore(pscoreb) kernel kerneltype(normal) bwidth(`ban') common
			
		}
		
		quietly{
		* some stuff for making tables:
			//store scalars of att for table
			sca q`q'_diff_att`bancount' = r(att)
			sca q`q'_se_att`bancount'	 = r(seatt)	
			
			//store the scalar results for the unmatched for table
			esttab q`q'_`bancount', se
			sca q`q'_diff_unm`bancount' = r(coefs)[1,1]
			sca q`q'_se_unm`bancount'	 = r(coefs)[1,2]
		}
	}
}


*----------------------*
* 		question 11 	  *
*----------------------*
eststo clear //clear the stored regressions

eststo: reg re78 treated2 age age2 educ black hisp married nodegree re74 re75
					

	// predicted y hats for the above reg 
   predict yhat78
	

*----------------------*
* 		question 12 	  *
*----------------------*
eststo: reg re78 age age2 educ black hisp married nodegree re74 re75 if treated2 == 0

* predicted y hats for the above reg, which is just the CPS group
predict yhat78_cps if treated2 == 1
gen diff12 = re78 - yhat78_cps 
sum diff12
quietly{
loc att_12b = r(mean)
di `att_12b'
file open q12cps using "q12cps.tex", write replace
file write q12cps "-\\$`: di %7.2fc abs(`att_12b')'"
file close q12cps
}


	// table for 11 and 12: 
	#delimit ;
	qui esttab using "tables/q12.tex", replace
		 booktabs nostar nonum 
		 b(%7.2fc) se(2)
		 title(Using regressions instead of matching (questions 11 and 12)\label{q12})
		 mtitles("Pooled" "CPS only");
	#delimit cr
	
	
*----------------------*
* 		question 13 	  *
*----------------------*
* inverse probability weighting

// ATT, weights sum to 1: (page 19 in notes)

	// some types of obs counts 
		foreach i in ttl 0 1{
			if "`i'" == "ttl"  {
				count
			}
			else {
				count if treated2 == `i'
			}
			sca n`i' = r(N) 
		}
		
			

	// treated re78 outcomes:
		gen re78_control = re78*treated2
		
		// sum of all the treated re78:
		total(re78_control)
		
		// average re78 for treated:
		sca a = _b[re78_control] / n1
		
	// working towards the second term in the formula
		sca phat = n1 / nttl // %of obvs that are treated
		sca b	= (1 - phat) / phat
		
		gen x = (b*pscoreb*re78*(1-treated2) )/ (1-pscoreb)
		
		total(x)
		sca c = _b[x] / n0
		
	// finally, the ATT:
		local att_ipw = a - c
		di %7.2fc `att_ipw'
		
		quietly{
		file open q13 using "q13.tex", write replace
		file write q13 "-\\$`:di %7.2fc abs(`att_ipw')' for unscaled weights"
		file close q13
		}
		
// ATT, normalize the weights to sum to 1 (second formula on page 19)

	gen y = (pscoreb *(1-treated2))/(1-pscoreb)
	total(y)
	gen z = (_b[y]/n0)^(-1) * ((pscoreb * re78 *(1-treated2))/(1-pscoreb))
	total(z)
		
	// finally, the ATT rescaled/normalized
		local att_ipwnorm = a - _b[z]/n0
		di `att_ipwnorm'


					quietly{
		file open q13b using "q13b.tex", write replace
		file write q13b "-\\$`:di %7.2fc abs(`att_ipwnorm')' using scaled weights"
		file close q13b
		}
		
log close
// write texdoc tables 
qui texdoc do ps2_tables
