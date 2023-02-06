clear all
set more off

global data_hh "E:\Research_1\Original_data\Data12\Household" 
global data_ind "E:\Research_1\Original_data\Data12\Individual" 
global data_cmm "E:\Research_1\Original_data\Data12\Community" 
global data_cc "E:\Research_1\Original_data\Data12\Control"
global master "E:\Research_1\Data"
clear

/* 	
	Mar 26, 2019
	creating indices for gender views and decision-making and normalize them
	a dummy for missing value for each index/subindex
*/


cd 		"$root"

/******************************************************************************/
/******************************** gender views ********************************/
/******************************************************************************/

use		"$master/2012\gender_views_12", clear
mer 1:1 hhid pid using "$master/2012\sample_for_analysis", nogen
do "E:\Research_1\Do_files\Original\program_for_james"
unab	views: gender_view_?
genindex `views', gen(views)

unab	views_nm: gender_view_?_nm
genindex `views_nm' if dm_in_sample == 1, gen(views_nm)

foreach v of varlist *views* {
	loc	lab: var lab `v'
	if	regexm("`v'", "views_nm") == 1			loc lab	=	subinstr("`lab'", "views_nm", "Gender views: missing imputed", .)
	else										loc lab	=	subinstr("`lab'", "views", "Gender views", .)
	lab var	`v'	"`lab'"
}
pca		gender_view_?	if  dm_in_sample == 1 & dm_married==1,		components(1)			
predict	pca_gender_view	if  dm_in_sample == 1 & dm_married==1,	score
la	var	pca_gender_view		"Gender views: PCA-based index using default correlation matrix"

pca		gender_view_?_nm	if dm_in_sample == 1 & dm_married==1,	components(1)			
predict	pca_gender_view_nm	if dm_in_sample == 1 & dm_married==1, score
la	var	pca_gender_view_nm	"Gender views: PCA-based index using default correlation matrix; imputed with gender-soato mean"

egen	miss			=	rowmiss(gender_view_?)
gen		dm_miss_views	=	(miss > 0)	
lab var	dm_miss_views		"Dummy - gender views missing at least once"

/*	there are many missing values. I make another version that is missing when any of their 9 components is missing	*/
clonevar views_M2		=	views_M
replace	views_M2 		= . if dm_miss_views == 1
lab var views_M2		 	"`: var lab views_M2'; missing NOT ignored"

clonevar views_A2		=	views_A
replace	views_A2 		= . if dm_miss_views == 1
la var 	views_A2		 	"`: var lab views_A2'; missing NOT ignored"

center 	gender_view_?		if dm_in_sample == 1 & dm_married==1, pre(SD_) st
center 	gender_view_?_nm	if dm_in_sample == 1 & dm_married==1, pre(SD_) st

center	views_nm*			if dm_in_sample == 1 & dm_married==1, pre(Z_) st

drop	miss*
format 	pca_*	views_*	SD_* %9.3f
hist 	views_nm_A						/* looks reasonable */
hist	views_A
hist 	views_M

save	"$master/2012\indices_gender_views", replace

/******************************************************************************/
/****************************** decision making *******************************/
/******************************************************************************/
use		"$master/2012\decision_making_12", clear
mer 1:1 hhid pid using "$master\2012\sample_for_analysis", nogen

center	dm_empr_? 		dm_empr_?? 		if  dm_in_sample == 1 & dm_married==1, pre(SD_) st
center	dm_empr_?_nm 	dm_empr_??_nm 	if  dm_in_sample == 1 & dm_married==1, pre(SD_) st
	
/* construct the first principal component */
pca		dm_empr_? dm_empr_?? 	if  dm_in_sample == 1 & dm_married==1, components(1)
predict	pca_decis_all			if  dm_in_sample == 1 & dm_married==1, score
la	var	pca_decis_all		"ALL decisions: PCA-based index using default correlation matrix"

pca		dm_empr_?_nm dm_empr_??_nm	if  dm_in_sample == 1 & dm_married==1, components(1)			
predict	pca_decis_all_nm			if dm_in_sample == 1 & dm_married==1, score
la	var	pca_decis_all_nm	"ALL decisions: PCA-based index using default correlation matrix; imputed with gender-soato mean"


unab all: 		dm_empr_? 		dm_empr_??
unab all_nm: 	dm_empr_?_nm 	dm_empr_??_nm

unab marital:	dm_empr_13		dm_empr_14 		dm_empr_15		
unab econ:		dm_empr_1		dm_empr_2		dm_empr_3		dm_empr_16 		dm_empr_17 		dm_empr_23 					
unab fina:		dm_empr_4 		dm_empr_5  		dm_empr_6  		dm_empr_7		dm_empr_18		dm_empr_19		dm_empr_20		dm_empr_24       									 
unab child:		dm_empr_8		dm_empr_9 		dm_empr_10		dm_empr_11 		dm_empr_12		dm_empr_25		 
unab commun:	dm_empr_21 		dm_empr_22

unab marital_nm:	dm_empr_13_nm		dm_empr_14_nm 		dm_empr_15_nm		
unab econ_nm:		dm_empr_1_nm		dm_empr_2_nm		dm_empr_3_nm		dm_empr_16_nm 		dm_empr_17_nm 		dm_empr_23_nm 					
unab fina_nm:		dm_empr_4_nm 		dm_empr_5_nm  		dm_empr_6_nm  		dm_empr_7_nm		dm_empr_18_nm		dm_empr_19_nm		dm_empr_20_nm		dm_empr_24_nm       									 
unab child_nm:		dm_empr_8_nm		dm_empr_9_nm 		dm_empr_10_nm		dm_empr_11_nm 		dm_empr_12_nm		dm_empr_25_nm		 
unab commun_nm:		dm_empr_21_nm 		dm_empr_22_nm


/* indices and subindices */
foreach c in all marital econ fina child commun{
	loc		num: word count ``c''
	egen 	miss				=	rowmiss(``c'')
	egen	miss_nm				=	rowmiss(``c'_nm')
	gen		dm_miss_decis_`c' 	= 	(miss > 0)	
	lab var	dm_miss_decis_`c'		"Dummy - `c' decision making questions missing at least once"
	
	gen nonmiss = 1	if miss	!= `num'

	genindex	``c''											, 	gen(decis_`c'	)
	genindex	``c'_nm' if  dm_in_sample == 1 & dm_married==1 &	nonmiss == 1, 	gen(decis_`c'_nm)

	foreach var of varlist *decis_`c'_*pca *decis_`c'_*M *decis_`c'_*A {
		loc	lab: 	var lab `var'
		loc	lab	=	subinstr("`lab'", "_nm", " missing imputed", .)
		if	regexm("`c'", "all") == 1			loc lab	=	subinstr("`lab'", "decis_all", "ALL decisions", .)
		if	regexm("`c'", "marital") == 1		loc lab	=	subinstr("`lab'", "decis_mari", "Marital decisions", .)
		if	regexm("`c'", "econ") == 1			loc lab	=	subinstr("`lab'", "decis_econ", "Economic decisions", .)
		if	regexm("`c'", "fina") == 1			loc lab	=	subinstr("`lab'", "decis_fina", "Financial management decisions", .)
		if	regexm("`c'", "child") == 1			loc lab	=	subinstr("`lab'", "decis_child", "Children-related decisions", .)	
		if	regexm("`c'", "commun") == 1		loc lab	=	subinstr("`lab'", "decis_commun", "Community related decisions", .)	
		lab var	`var'	"`lab'"	
}
	drop	miss*	nonmiss
}

/* test */ 	/*
preserve
	macro drop		_all
	unab mari_nm:	dm_empr_9_nm	dm_empr_10_nm 	dm_empr_11_nm
	genindex	`mari_nm', gen(decis_mari_test)
	assert 		pca_decis_mari_test_cov == pca_decis_mari_nm_cov
	assert		decis_mari_nm_M == decis_mari_test_M 
	assert		decis_mari_nm_A == decis_mari_test_A
restore		*/

/*	there are many missing values. I make another version that is missing when any of their 9 components is missing	*/
clonevar decis_all_M2	=	decis_all_M
replace	decis_all_M2 	= . if  dm_in_sample == 1 & dm_married==1
lab var decis_all_M2		 "`: var lab decis_all_M2'; missing NOT ignored"

clonevar decis_all_A2	=	decis_all_A
replace	decis_all_A2 	= . if  dm_in_sample == 1 & dm_married==1
lab var decis_all_A2		 "`: var lab decis_all_A2'; missing NOT ignored"

format 	pca_* decis_* SD_* %9.3f
fsum	pca_* decis_* SD_*

center	decis_*nm*			if  dm_in_sample == 1 & dm_married==1, pre(Z_) st

hist	decis_all_A				//extremely empowered and extremely disempowered	
hist 	decis_all_M
*/
save	"$master/2012\indices_decision_making", replace

exit,	clear
