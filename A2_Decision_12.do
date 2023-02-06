clear all
set more off

global data_hh "E:\Research_1\Original_data\Data12\Household" 
global data_ind "E:\Research_1\Original_data\Data12\Individual" 
global data_cmm "E:\Research_1\Original_data\Data12\Community" 
global data_cc "E:\Research_1\Original_data\Data12\Control"
global master "E:\Research_1\Data"
clear
/*
	Apr 11, 2019
	-	impute missing decision making questions and prepare for the construction of indices
*/

cd			"$root"

set	matsize	11000
use "$data_ind\id5b.dta", clear
isid hhid pid
count				/*	8,051	*/
do "E:\Research_1\Do_files\Original\program_for_james"

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
*hist age									/* unlike aspirations, no age max for this module */
rename h104 relat_to_hd
keep hhid pid i513* dm_male relat_to_hd oblast soato rural obl rayon

sum * /*also notice that i835_1 has a maximum value of 77, but no other variables have that value. I believe it's a skip code */

ren i513_0* c_*
ren i513_1* c_1*
ren i513_2* c_2*


*br if c_1==77			/* all missing; drop these obs to keep coding simpler */
*drop if c_1 == 77
count
sum *					/* no more missing */
ta relat,m

forv k = 1/25 {
	*loc k = 1
	loc lab: var lab c_`k'
	loc lab = subinstr("`lab'","(","",.)
	loc lab = subinstr("`lab'",")","",.)

	g		dm_empr_M_`k' = (inlist(c_`k',2,3,6	)) if c_`k'<=8 		& dm_male==1
	g		dm_empr_W_`k' = (inlist(c_`k',1,3,6	)) if c_`k'<=8 		& dm_male==0
	la var 	dm_empr_M_`k' "dummy - man decision: `lab'"					/* spouse	, me/spouse, all HH females, all HH memebers	(preferred outcome)	*/
	la var 	dm_empr_W_`k' "dummy - woman decision: `lab'"				/* me		, me/spouse, all HH females, all HH memebers	(preferred outcome)	*/
	
	egen dm_empr_`k' = rowtotal(dm_empr_?_`k'), missing
	la var dm_empr_`k' "dummy - both sexes decision: `lab'"
}

ta  c_1	dm_empr_W_1	,m
ta  c_1	dm_empr_M_1	,m
ta  c_1	dm_empr_1	,m

/* replaces missing values with gender-soato mean in each question, with suffix _nm (non-missing)*/
egen	miss	=	rowmiss(dm_empr_? dm_empr_??)
unab	decis:		dm_empr_? dm_empr_??
Imputeby `decis', by1(dm_male soato) by2(dm_male rayon rural) by3(dm_male rayon) by4(dm_male oblast rural) by5(dm_male oblast)

/* examine the missing pattern by gender */
egen	miss_nm =	rowmiss(dm_empr_?_nm dm_empr_??_nm)
preserve
	forv k = 1/25 {
		gen		dm_miss_`k' = (c_`k' > 8)
		loc		lab: var lab c_`k'
		loc 	lab_`k' =	subinstr("`lab'", ",", "", .)
		la		var	dm_miss_`k'	"`lab_`k''"
	}
	unab vars: dm_miss_? dm_miss_??
	*eststo: estpost ttest 	`vars', by(dm_male)
	*esttab	using "${out_file}/decis_mak_missing_by_gender_test.csv", replace noobs nonumber label star(* 0.1 ** 0.05 *** 0.01) ///
		cells("mu_1(label(Mean_female) fmt(3)) N_1(label(N) fmt(0)) mu_2(label(Mean_male) fmt(3)) N_2(label(N) fmt(0)) b(label(Diff) fmt(3) star) se(label(SE) par fmt(3))") 	

	keep hhid pid dm_miss_? dm_miss_?? dm_male
	reshape long dm_miss_, i(hhid pid dm_male) j(q_number) str
	gen	str question = ""
	forv k = 1/25 {
		replace	 question = "`lab_`k''"	if q_number == "`k'"
	}
	collapse (sum) dm_miss_, by(q_number question dm_male)
	reshape wide dm_miss_@, i(q_number question) j(dm_male)
	ren	dm_miss_0 female_missing
	ren	dm_miss_1 male_missing
	sort	q_number
	*export excel using "${out_file}/decis_mak_missing_by_gender.xls", firstrow(variables) replace		
restore

/* make two tables for the number of questions answered */
preserve
	forv i = 1/25 {
		gen		dm_impute_`i' =	(dm_empr_`i' == . & dm_empr_`i'_nm != .)	
	}
	foreach t in "" _nm {
		count if miss`t'== 	0
		count if miss`t'> 0 &  miss`t' < 25
		count if miss`t' == 25
		forv k = 1/25 {
			loc lab_`k': var lab c_`k'
			la var dm_empr_`k' "`lab_`k''"
			gen miss_`k'`t' = (dm_empr_`k'`t' == .)
		}
	}
	keep 	hhid pid dm_empr_? dm_empr_?? dm_empr_?_nm dm_empr_??_nm miss* dm_impute*
	egen 	answered = rownonmiss(dm_empr_? dm_empr_??)
	lab		var		answered		"Number of questions answered"
	*estpost	tab		answered
	*esttab, cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") varlabels(, blist(Total "{hline @width}{break}"))      ///
			nonumber nomtitle noobs
	drop 	answered
	reshape long	dm_empr_ miss_ dm_empr_@_nm miss_@_nm dm_impute_, i(hhid pid) j(question_number)
	gen		question	=	""
	forv	k	=	1/25	{
		replace	question	=	"`lab_`k''"	if	question_number	==	`k'
	}
	collapse (sum)	miss_ miss__nm dm_impute_, by (question_number	question)
	lab var	miss_ 		"Missing in raw data"
	lab	var	miss__nm 	"Missing after imputation"
	lab	var	dm_impute_ 	"Number of imputations"
	*export excel using "${out_file}/miss_by_q_decision_making.xlsx", firstrow(varlabels) replace
restore

drop	miss* c_* 
fsum *, uselabel





sa "$master\2012\decision_making_12", replace

***********************************************************
/* show the outcomes that are constructed: */
loc outcomes_created_here = "dm_empr_*"			/* change this line for each do-file		*/
fsum `outcomes_created_here', uselabel

loc outcomes_created_here = "dm_empr*"		/* change this line for each do-file		*/
fsum `outcomes_created_here', uselabel

***********************************************************

exit, clear
