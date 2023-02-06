/*
	18 Dec, 2019
	
	code a variable indicating the number of missing controls
	for restricting the universe used for standardization of AI and outcome indices
*/


cd			"$root"

/* controls in the fully controlled specification: ALSO need to drop singletons in a soato since the IV weight is constructed using the soato mean */
loc geo		=	"oblast	rural"
loc indiv 	=	"age 	age2	dm_male	dm_edu_basic dm_edu_second  dm_edu_high"		
loc hh		=	"age_head 		age2_head  dm_edu_head_basic 	dm_edu_head_second dm_edu_head_high		hh_members"
*num_f_adults	num_m_adults
loc keyvar	=	"kalm"
*loc	commu	=	"pop_16_res		prop_* 		dm_transport 	pca_infra 			total_org	times_meeting	pca_shock"	

loc iv_level=	"soato"

u	root_data, clear
*keep if dm_married==1

mer 1:1 hhid pid	using "$master/2012\gender_views_12"
drop if _m==2
drop _m

mer 1:1 hhid pid	using "$master/2012\decision_making_12"
drop if _m==2
drop _m

*keep	if 		period == 2
*encode	soato, gen(soato_)
*drop	soato
*ren		soato_	soato

bys `iv_level': egen c_iv = count(pid)
bys hhid:		egen c_hh = count(pid)

egen miss	=	rowmiss(`geo' `indiv' `hh'	`keyvar'	`commu') if c_iv != c_hh
ta		miss, m


egen nm1 	=	rownonmiss(gender_view_?_nm)
egen nm2 	=	rownonmiss(dm_empr_?_nm	dm_empr_??_nm)
*drop dm_in_sample
gen 	dm_in_sample = (miss == 0) & (nm1 > 0 | nm2 > 0)
ta 		dm_in_sample, m
la var 	dm_in_sample	"In the sample for analysis: nonmissing for AI, IV, controls, and either outcome index"

keep	hhid pid dm_in_sample dm_married

sa		"$master/2012\sample_for_analysis.dta", replace

exit, clear
