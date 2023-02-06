/*
	Program for imputation
*/

cap program drop Imputeby
program Imputeby

	version 14	
	syntax	varlist, BY1(varlist) [BY2(varlist) BY3(varlist) BY4(varlist) BY5(varlist)]

	qui {
		tempvar	miss
		egen	`miss'	=	rowmiss(`varlist')
		loc		n: word count `varlist'

		forv i = 1/5 {
			if	"`by`i''" 	!=	""	loc	k = `i'
		}
		
		foreach v in `varlist' {
			forv i = 1/`k' {
				bys	`by`i'': egen `v'_m = mean(`v') 
				cou if 	`v'_m	== . & `miss' != `n'
				noi di	"Question `v': `r(N)' singletons in `by`i''"
				
				if	`i'	== 1	noi gen	`v'_nm	=	`v'
				noi replace	`v'_nm	= `v'_m if `v'_nm ==. & `miss' != `n'					//only impute for observations with at least one non-missing value
				drop	`v'_m			
			}	
			lab var `v'_nm "`v'; imputed with `by1' `by2' `by3' `by4' `by5' mean"
		}
	}
end


/* Program to generate 3 indices: 
	-	a PCA-based index
	-	an Anderson index
	-	and a straight index 
	
	I should impute missing with gender-soato mean before using the program
*/

cap program drop genindex
program genindex

	version 12
	syntax varlist [if], gen(string)
	
	*qui {
		loc	i: word count `varlist'
		pca	`varlist'		`if', components(1) covariance
		predict	`gen'_pca 	`if', score
		la	var	`gen'_pca	"`gen': PCA-based index; `i' normalized questions"
		
		center `varlist' `if', pre(z_) st

	// #1-a Mean of those zscores: M
		egen `gen'_M = rowmean(z_*)
		qui su `gen'_M , de
		
	// #1-b Anderson ('08) wgt'd by Var-Cov mat: A
		tempname R J T A
		mat accum `R' = `varlist' , nocons dev
		mat `R' = syminv(`R'/r(N))
		mat `J' = J(colsof(`R') , 1 , 1)

		local c = 1
		while `c' <= colsof(`R') {
			mat `T' = `R'[`c' , 1..colsof(`R')]
			mat `A' = `T'*`J'
			global wgt`c' = `A'[1 , 1]
			local ++c
			}
		
		tempvar samp1 outp1
		gen `samp1' = 0
		gen `outp1' = 0
		local c = 1
		foreach z in `varlist' {
			replace `samp1' = `samp1' + $wgt`c'
*			replace z_`z' = 0 if missing(`z') 						//No imputation, imputation is outside the program
			replace `outp1' = z_`z'*($wgt`c') + `outp1'
			local ++c
			}

		replace `outp1' = `outp1'/`samp1'
		rename `outp1' `gen'_A

		su `gen'_A , de
		
		local ab M A
		local ful Mean Anderson
		forval n = 1/2 {
			local a : word `n' of `ab'
			local b : word `n' of `ful'
			lab var `gen'_`a' "`gen': `b' index; `i' normalized questions"
			}
		
		drop z_*
		*}	
end
