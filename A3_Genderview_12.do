clear all
set more off

global data_hh "E:\Docs\Research_1\Original_data\Data12\Household" 
global data_ind "E:\Docs\Research_1\Original_data\Data12\Individual" 
global data_cmm "E:\Docs\Research_1\Original_data\Data12\Community" 
global data_cc "E:\Docs\Research_1\Original_data\Data12\Control"
global master "C:\Users\ojx\Desktop\COMP STAT\DATA"
clear
/*
	Apr 11, 2019
	-	impute missing gender views and prepare for the construction of indices
*/

cd 		"$root"


use "$data_ind\id5e.dta", clear
isid hhid pid
count				/*	8,032	*/
do "C:\Users\ojx\Desktop\COMP STAT\Stata data cleaning\program_for_james"
merge	1:1	hhid pid using "$data_hh\hh1a", 
gen dm_male=(h102==1) if h102<.

drop if _merge==1 | _merge==2
drop _merge
rename hhid hhid12
merge m:1 hhid12 using "$data_cc\cc_hh"
rename hhid12 hhid
drop if _m == 2
gen rural=(residence==2) if residence<.
gen rayon=(soato/1000)
keep	hhid pid i537* oblast soato rural obl rayon dm_male

forv i = 1/7 {
	if inlist(`i',4,7) 	g gender_view_`i' = i537_`i'			if abs(i537_`i')<=4
	else				g gender_view_`i' = i537_`i'*(-1) + 5	if abs(i537_`i')<=4	
	ta gender_view_`i'  i537_`i',m
}

/*I reversed the labels for vars except for 4 and 7 */
la var gender_view_1		"(4=>strongly disagree) Important decisions should be made by the husband rather than the wife."
la var gender_view_2		"(4=>strongly disagree) Man’s job= earn money; woman’s job = look after the home and family."
la var gender_view_3		"(4=>strongly disagree) Women are fulfilled only when she becomes a mother."
la var gender_view_4		"(4=>strongly agree) Working woman can establish just as warm and secure relationship with her children as a mother who does not work." 
la var gender_view_5		"(4=>strongly disagree) Husband’s career should be more important to the wife than her own."
la var gender_view_6		"(4=>strongly disagree) Univ education is more important for a boy than for a girl."
la var gender_view_7		"(4=>strongly agree) Both the husband and the wife should contribute to the household income."
*la var gender_view_8		"(4=>strongly disagree) Being a housewife is just as fulfilling as working for pay."
*la var gender_view_9		"(4=>strongly disagree) Woman should not work outside home due to religious considerations"

*mer 1:1 hhid pid 	using "$data_ind/id1", keepus(dm_male)
*drop if _m == 2
*drop	_m

/* replaces missing values with gender-soato mean in each question, with suffix _nm (never missing)*/
unab 	views: gender_view_?
Imputeby `views', by1(dm_male soato) by2(dm_male rayon rural) 

/* check the missing patterns by gender */
egen	miss	=	rowmiss(gender_view_?)
preserve
	forv i = 1/7 {
		gen 	dm_missing_`i' = (gender_view_`i' == .)
		loc 	lab_`i': var lab i537_`i'
		la		var	dm_missing_`i'	"`lab_`i''"
	}
	unab vars: dm_missing_?
	*eststo: estpost ttest 	`vars', by(dm_male)
	*esttab	using "${out_file}/gender_view_missing_by_gender_test.csv", replace noobs label star(* 0.1 ** 0.05 *** 0.01) ///
		cells("mu_1(label(Mean_Female) fmt(3)) N_1(label(N) fmt(0)) mu_2(label(Mean_Male) fmt(3)) N_2(label(N) fmt(0)) b(label(Diff) fmt(3) star) se(label(SE) par fmt(3))") 
	
	keep hhid pid dm_missing_? dm_male
	reshape long dm_missing_, i(hhid pid dm_male) j(q_number) str
	gen	str question = ""
	forv i = 1/7 {
		replace	 question = "`lab_`i''"	if q_number == "`i'"
	}
	collapse (sum) dm_missing_, by(q_number question dm_male)
	reshape wide dm_missing_@, i(q_number question) j(dm_male)
	ren	dm_missing_0 female_missing 
	ren	dm_missing_1 male_missing
	*export excel using "${out_file}/gender_view_missing_by_gender.xls", firstrow(variables) replace
restore

/* make two tables for the number of questions answered */
preserve
	forv i = 1/7 {
		gen	dm_impute_`i' =	(gender_view_`i' == . & gender_view_`i'_nm != .)		
}
	foreach t in "" _nm {
		egen nonmiss`t' =	rownonmiss(gender_view_?`t')
		count if nonmiss`t'== 	7
		count if nonmiss`t'> 0 &  nonmiss`t' < 7
		count if nonmiss`t' == 0
		forv k = 1/7 {
		loc lab_`k': var lab gender_view_`k'
		gen miss_`k'`t' = (gender_view_`k'`t' > 4)
		}
	}
	keep 	hhid pid gender_view_*	miss_* dm_impute*
	egen 	answered = rownonmiss(gender_view_?)
	lab		var		answered		"Number of questions answered"
	*estpost	tab		answered
	*esttab, cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") varlabels(, blist(Total "{hline @width}{break}"))      ///
			nonumber nomtitle noobs
	drop 	answered
	reshape long	gender_view_ miss_ gender_view_@_nm	miss_@_nm dm_impute_, i(hhid pid) j(question_number)
	gen		question	=	""
	forv	k	=	1/7	{
		replace	question	=	"`lab_`k''"	if	question_number	==	`k'
	}
	collapse (sum)	miss_ miss__nm dm_impute_, by (question_number	question)
	lab	var miss_		"Missing in raw data"
	lab	var	miss__nm	"Missing after imputation"
	lab	var	dm_impute_ 	"Number of imputations"
	*export excel using "${out_file}/miss_by_q_gender_views.xlsx", firstrow(varlabels) replace
restore

drop	i537_? miss*

***********************************************************
/* show the outcomes that are constructed: */
unab gender_views: gender_view_? gender_view_?_nm			/* change this line for each do-file		*/
fsum `outcomes_created_here', uselabel
***********************************************************

sa "$master\gender_views_12", replace
exit, clear
