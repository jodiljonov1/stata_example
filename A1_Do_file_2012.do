clear all
set more off

global data_hh "E:\Docs\Research_1\Original_data\Data12\Household" 
global data_ind "E:\Docs\Research_1\Original_data\Data12\Individual" 
global data_cmm "E:\Docs\Research_1\Original_data\Data12\Community" 
global data_cc "E:\Docs\Research_1\Original_data\Data12\Control"
global master "E:\Docs\Research_1\Original_data\Data12\Data"
clear

*********************************************** DATA FOR 2012, ALL SECTIONS ARE HERE *********************************************************
******************************* *************** DATA FOR 2012, ALL SECTIONS ARE HERE *********************************************************

*************************************************** INDIVIDUAL *******************************************************************************


******** Merging All Individuals Except for SOME *****************
use "$data_ind\id5c"
	
	foreach  var of varlist t*{
		replace `var'=0 if `var'==.
	}
	
	gen chores=(t0400 + t0430 + t0500 + t0530 + t0600 + t0630 + t0700 + t0730 + t0800 + t0830 + t0900 + t0930 + t1000 + t1030 + t1100 + t1130 + t1200 + t1230 + t1300 + t1330 + t1400 + t1430 + t1500 + t1530 + t1600 + t1630 + t1700 + t1730 + t1800  +t1830 + t1900 + t1930 + t2000 + t2030 + t2100 + t2130 + t2200 + t2230 + t2300 + t2330 + t0000 + t0030 + t0100 + t0130 + t0200 + t0230 + t0300+t0330)/2 if activity>4 & activity<13
	gen labor=(t0400 + t0430 + t0500 + t0530 + t0600 + t0630 + t0700 + t0730 + t0800 + t0830 + t0900 + t0930 + t1000 + t1030 + t1100 + t1130 + t1200 + t1230 + t1300 + t1330 + t1400 + t1430 + t1500 + t1530 + t1600 + t1630 + t1700 + t1730 + t1800  +t1830 + t1900 + t1930 + t2000 + t2030 + t2100 + t2130 + t2200 + t2230 + t2300 + t2330 + t0000 + t0030 + t0100 + t0130 + t0200 + t0230 + t0300+t0330)/2 if activity>29 & activity<33
	gen entertainment=(t0400 + t0430 + t0500 + t0530 + t0600 + t0630 + t0700 + t0730 + t0800 + t0830 + t0900 + t0930 + t1000 + t1030 + t1100 + t1130 + t1200 + t1230 + t1300 + t1330 + t1400 + t1430 + t1500 + t1530 + t1600 + t1630 + t1700 + t1730 + t1800  +t1830 + t1900 + t1930 + t2000 + t2030 + t2100 + t2130 + t2200 + t2230 + t2300 + t2330 + t0000 + t0030 + t0100 + t0130 + t0200 + t0230 + t0300+t0330)/2 if activity>17 & activity<25
	
	drop t*
	collapse (sum) chores labor entertainment , by(hhid pid)
	sort hhid pid
	save f1,replace 
*******************************************************************************************************************************************	
use "$data_ind\id1",replace
		merge 1:1 hhid pid using "$data_ind\id2"
			drop _merge
		merge 1:1 hhid pid using "$data_ind\id3"
			drop _merge
		merge 1:1 hhid pid using "$data_ind\id4"
			drop _merge
		merge 1:1 hhid pid using "$data_ind\id5a"
			drop _merge
		merge 1:1 hhid pid using "$data_ind\id5b"
			drop _merge
		merge 1:1 hhid pid using "$data_ind\id5e"
			drop _merge
		merge 1:1 hhid pid using "$data_ind\id6"
			drop _merge
		merge 1:1 hhid pid using "$data_ind\id7"
			drop _merge
		merge 1:1 hhid pid using "$data_ind\id8"
			drop _merge
		merge 1:1 hhid pid using "$data_ind\id8c"
			drop _merge
		merge 1:1 hhid pid using "$data_ind\id8d"
			drop _merge
		merge 1:1 hhid pid using "$data_ind\id5d"
			drop _merge

*save "$master\data_2012",replace

*** Education ***
		gen dm_edu_basic = (i207==1 | i207==2 | i207==3) if i207 < .
			la var dm_edu_basic 	"Dummy=1 if education is illetarate basic or primary"
		gen dm_edu_second = (i207==4 | i207==5 | i207==6) if i207 < .
			la var dm_edu_second 	"Dummy=1 if education is secondary, primary or secondary technical"
		gen dm_edu_high = (i207==7 | i207==8) if i207 < .
			la var dm_edu_high 		"Dummy=1 if education is bachelor, masters or PhD"
save f2,replace
clear
*******************************************************************************************************************************************
*************************************************** Household and Community and Control *******************************************************************************

******** Merging All Household Except for SOME *****************

***household assets***
use "$data_hh\hh2b",replace
		replace h215_s=h215_s/70 if h215_v==1
		replace  h215_s=h215_s*h214		
		collapse (sum) h215_s, by (hhid)
		rename h215_s hh_assets
		la var hh_assets "most liquid assets of household that can be sold"
		
		save f3, replace
clear
*******************************************************************************************************************************************
***household assets***
use "$data_hh\hh2b",replace
		gen stove=(n2b==9 | n2b==10) if n2b<.
		gen washing=(n2b==14 | n2b==15) if n2b<.
		gen cleaner=(n2b==16) if n2b<.
		gen cattle=(n2b==33 | n2b==34) if n2b<.
		gen poultry=(n2b==39) if n2b<.	
		collapse (sum)  stove washing cleaner cattle poultry, by (hhid )
		foreach var of varlist stove-poultry{
		replace `var'=1 if `var'==2
		}
		keep hhid stove washing cleaner cattle poultry
		save f3a, replace
clear
*******************************************************************************************************************************************

***housing***
use "$data_hh\hh2a",replace
		sort hhid
		rename h203 rooms
		replace rooms=. if rooms==99
		rename h205a electr
		replace electr=0 if electr==1
		replace electr=1 if electr==2
		replace electr=2 if electr==3
		replace electr=3 if electr==4
		replace electr=4 if electr==5
		replace electr=5 if electr==6
		replace electr=6 if electr==7
		rename h202_6 rent
		replace rent=0 if rent==2
		keep hhid rooms electr rent
		save f3b, replace
clear
*******************************************************************************************************************************************


***Household food expenditure monthly ***
use "$data_hh\hh4a",replace
		replace h401c=h401c/70
		replace h401c=h401c*4 if h401d==1
		replace h401c=h401c/3 if h401d==3
		replace h401c=h401c/12 if h401d==4
		collapse (sum) h401c, by (hhid)
		rename h401c hh_food_exp
		la var hh_food_exp "monthly household food expenditure"
	save f4,replace
clear
*******************************************************************************************************************************************

***Household nonfood expenditure monthly***
use "$data_hh\hh4b",replace
		replace h403=h403/70 if h404==1
		replace h403=h403/12 if h405==2
		collapse (sum) h403, by (hhid)
		rename h403 hh_nonfood_exp
		la var hh_nonfood_exp "monthly household nonfood expenditure"
		
	save f5,replace
clear
*********************************************************************************************************************************************Household migrants abroad ***

use "$data_hh\hh6", replace
		rename h601 migrants 
	save f6,replace
clear
*******************************************************************************************************************************************

*** Number of people in the Household***
use "$data_hh\hh1a.dta",replace
		gen hh_members=1
		gen hh_male=0
		replace hh_male=1 if h102==1
		gen hh_female=0
		replace hh_female=1 if h102==2
		
		
		collapse (sum) hh_members hh_male hh_female, by (hhid)

		save f7,replace
	clear
*******************************************************************************************************************************************

*******MERGING HOUSEHOLDs Community ******
use f3,replace
		merge 1:1 hhid using f3a	
			drop _merge
		merge 1:1 hhid using f3b	
			drop _merge
		merge 1:1 hhid using f4
			drop _merge 
		merge 1:1 hhid using f7	
			drop _merge
		merge 1:1 hhid using f5	
			drop _merge 
		merge 1:1 hhid using f6	
			drop _merge
		
		merge 1:m hhid using "$data_hh\hh1a"
			drop _merge
		
		rename hhid hhid12
		merge m:1 hhid12 using "$data_cc\cc_hh"
		rename hhid12 hhid
			drop _merge
		merge 1:1 hhid pid using f2
			drop if _merge==1
			drop _merge			
save f8, replace
*******************************************************************************************************************************************

	
****************************************** FOR MAIN USAGE PURPOSES **************************************************
****************************************** FOR MAIN USAGE PURPOSES **************************************************
		replace hh_assets=hh_assets/hh_members
		replace hh_food_exp=hh_food_exp/hh_members
		replace hh_nonfood_exp=hh_nonfood_exp/hh_members
		gen age2=age^2
		gen dm_married = (h108==1) if h108 < .		
		gen age_hd=age if h104==1
		gen age2_hd=age_hd^2
		bysort hhid: egen age_head=max(age_hd) 
		bysort hhid: egen age2_head=max(age2_hd)
		gen edu_hd_basic = (i207==1 | i207==2 | i207==3) if i207 < . & h104==1 
		bysort hhid: egen dm_edu_head_basic=max(edu_hd_basic)

		gen edu_hd_second= (i207==4 | i207==5 | i207==6) if i207 < . & h104==1 
		bysort hhid: egen dm_edu_head_second=max(edu_hd_second)

		gen edu_hd_high= (i207==7 | i207==8) if i207 < . & h104==1 
		bysort hhid: egen dm_edu_head_high=max(edu_hd_high)
		
		replace migrants=0 if migrants==. | migrants==0
		gen dm_migrant=(migrants>0)
		
		drop h600 age_hd age2_hd edu_hd_basic edu_hd_second edu_hd_high
	save f9,replace
		clear
*******************************************************************************************************************************************		
	
***** MERGING KALM and RELATED VARIABLES HERE *****
***** MERGING KALM and RELATED VARIABLES HERE *****
		use "E:\Docs\Research_1\Original_data\Data11\Individual\id5a.dta"
		
		merge 1:1 hhid pid using "E:\Docs\Research_1\Original_data\Data11\Individual\id5d.dta"
			drop _merge
		merge 1:1 hhid pid using "f9"
			drop _merge
		
		replace i500=. if i500==90
		gen newpid=pid
		replace newpid=i500 if h102==1
**** KALM *****
		replace i523_2=i523_1 if i523_2==.
		replace i523_2=0 if i523_2==2
		bysort hhid newpid: egen kalm=max(i523_2)
		
		replace i524_2=i524_1 if i524_2==.
		replace i524_2=. if i524_2==90
		replace i524_2=. if i524_2==99
		bysort hhid newpid: egen kalm_amount=max(i524_2)
		replace kalm=. if kalm==90
*** ARRANGED MARRIAGE ****	
		replace i522_2=i522_1 if i522_2==.
		gen arranged=0
		replace arranged=1 if i522_2==2
		bysort hhid newpid: egen dm_arranged=max(arranged)
		
		gen love=0
		replace love=1 if i522_2==1
		bysort hhid newpid: egen dm_love=max(love)
		
		gen bride_cap=0
		replace bride_cap=1 if i522_2==3
		bysort hhid newpid: egen dm_bride_cap=max(bride_cap)
		
*** AGE DIFFERENCE ****
		replace i520_2=i520_1 if i520_2==.
		replace i521_2=i521_1 if i521_2==.
		replace i520_2=. if i520_2==90
		replace i520_2=. if i520_2==99
		replace i521_2=. if i521_2==90
		replace i521_2=. if i521_2==99
		
		gen agemen=age if h102==1
		bysort hhid newpid: egen agedif=max(agemen)
		gen age_dif=age-agedif
		
		gen agewomen=age if h102==2
		bysort hhid newpid: egen agedif2=max(agewomen)
		gen age_dif2=age-agedif2
		replace age_dif=age_dif2 if age_dif==0
		replace age_dif=. if age_dif<-33
		
*** The length of marriage
		gen mar_length=i520_2
		gen marriagelength=age-mar_length
		bysort hhid newpid: egen duration=max(marriagelength)
		replace duration=. if duration<0
		gen duration2=duration^2
	********************************************************* JUST FOR LABELLING AND CREATING ADDITIONAL CONTROLS ************************************************
********************************************************* JUST FOR LABELLING AND CREATING ADDITIONAL CONTROLS ************************************************

gen dm_kyrgyz=(h105==1) if h105<.
gen dm_uzbek=(h105==2) if h105<.
gen dm_russian=(h105==3) if h105<.
*gen dm_dungan=(h105==4) if h105<.
*gen dm_uigur=(h105==5) if h105<.
*gen dm_tajik=(h105==6) if h105<.
*gen dm_kazak=(h105==7) if h105<.
gen dm_other=(h105>3) if h105<.

gen dm_male=(h102==1) if h102<.
gen rayon=soato/1000
gen rural=(residence==2) if residence<.

gen smoke=(i219==1) if i219<.
gen drink=(i220==1) if i220<.
gen sport=(i224==1) if i224<. 

rename i502 children
replace children=. if children==99
rename i501 siblings
	replace siblings=. if siblings==99
		
la var kalm_amount		"amount of kalm in terms of sheep"
la var age_dif			"age difference between husband and wife"	
la var dm_kyrgyz		"dm=1 if kyrgyz ethnic"
la var dm_uzbek 		"dm=1 if uzbek ethnic"
la var dm_russian		"dm=1 if russian ethnic"
la var dm_other			"dm=1 if other ethnic"
*la var dm_dungan		"dm=1 if dungan ethnic"
*la var dm_uigur 		"dm=1 if uigur ethnic"
*la var dm_tajik			"dm=1 if tajik ethnic"
*la var dm_kazak			"dm=1 if kazak ethnic"
la var hh_members        "number of household members"
la var hh_assets 			"most liquid asset hh has that can be sold easily (average per person)"
la var hh_food_exp			"yearly food expenditure of household per each member (average per person)"
la var hh_nonfood_exp		"yearly nonfood expenditure of household per each member (avarage per person)"
la var kalm 			"dm=1 for practice of kalm (if practiced==1)"
la var dm_arranged			"dm=1 if it is arranged marriage"	
la var dm_love				"dm=1 if it is love marriage"
la var dm_bride_cap		"dm=1 if it is bride captured marriage"
la var age_dif			"difference of age between husband and wife h-w"
la var age2				"age squared"
la var dm_married		"dm=1 if married"
la var age_head			"age of the head of hh"
la var age2_head		"age squared of the head of hh"
la var dm_edu_head_basic "dm=1 if head of hh has basic edu: illetarate, primary school, basic "
la var dm_edu_head_second "dm=1 if head of hh has secondary edu:secondary diploma, primary technical, secondary technical "
la var dm_edu_head_high "dm=1 if head of hh has high edu:bachelors degree, masters or phd"
la var dm_edu_basic "dm=1 if individual has basic edu: illetarate, primary school, basic "
la var dm_edu_secon "dm=1 if individual has secondary edu:secondary diploma, primary technical, secondary technical "
la var dm_edu_high "dm=1 if individual has high edu:bachelors degree, masters or phd"
la var dm_male 		"dm=1 if male"
la var rayon		"rayons of kyrgyzstan (40-43)"
la var cluster		"community codes (120)"
la var rural		"dummy=1 if the place of living is in rural area"
la var oblast 		"names of oblasts (7+2)"
la var duration 	"duration of the marriage"
la var duration2  	"duration of the marriage squared"
la var newpid	  	"id of the your spouses; from wive's side"
la var dm_migrant  	"dm=1 if there is a migrant abroad"
la var smoke	 	"dm=1 if ind smokes"
la var drink  		"dm=1 if ind drinks alcohol"
la var sport	  	"dm=1 if ind does sport"

	
gen Issyk_city=0
replace Issyk_city=1 if oblast==2 & rural==0
gen Issyk_rural=0
replace Issyk_rural=1 if oblast==2 & rural==1

gen Djalal_rural=0
replace Djalal_rural=1 if oblast==3 & rural==1
gen Djalal_city=0
replace Djalal_city=1 if oblast==3 & rural==0

gen Naryn_rural=0
replace Naryn_rural=1 if oblast==4 & rural==1
gen Naryn_city=0
replace Naryn_city=1 if oblast==4 & rural==0

gen Batken_city=0
replace Batken_city=1 if oblast==5 & rural==0
gen Batken_rural=0
replace Batken_rural=1 if oblast==5 & rural==1

gen Talas_city=0
replace Talas_city=1 if oblast==7 & rural==0
gen Talas_rural=0
replace Talas_rural=1 if oblast==7 & rural==1

gen Chui_rural=0
replace Chui_rural=1 if oblast==8 & rural==1
gen Chui_city=0
replace Chui_city=1 if oblast==8 & rural==0

gen Osh_rural=0 
replace Osh_rural=1 if oblast==6
gen Bishkek=0
replace Bishkek=1 if oblast==11
gen Osh_city=0
replace Osh_city=1 if oblast==21		

merge 1:1 hhid pid using time
	drop _merge
	gen dm_divorced=(h108==2 |h108==4) if h108<.
	
		
	
#delimit;
	order hhid pid newpid dm_divorced kalm chores labor entertainment dm_male age age2 age_dif
	children  duration duration2 rural dm_edu_basic dm_edu_second dm_edu_high  
	hh_members age_head age2_head dm_edu_head_basic dm_edu_head_second dm_edu_head_high 
	dm_migrant migrants kalm_amount dm_arranged dm_love dm_bride_cap  
	rooms rent electr
	dm_kyrgyz dm_uzbek dm_russian dm_other rayon hh_assets hh_food_exp hh_nonfood_exp smoke drink sport ;
	#delimit cr
	drop i* agemen agewomen agedif2 age_dif2 h109 h110 particip reason n_attr n_add n_flw d_flw residence lang arranged love bride_cap agedif mar_length marriagelength 
		



*just for curiosity	
	gen time_non=chores
	replace time_non=. if time_non==0
	
	
save root_data,replace
************************************************************************************************************
exit,	
		
		
