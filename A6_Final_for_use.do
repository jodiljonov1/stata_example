clear all
set more off

global data_hh "E:\Research_1\Original_data\Data12\Household" 
global data_ind "E:\Research_1\Original_data\Data12\Individual" 
global data_cmm "E:\Research_1\Original_data\Data12\Community" 
global data_cc "E:\Research_1\Original_data\Data12\Control"
global master "E:\Research_1\Data"
clear

use root_data

merge 1:1 hhid pid using "$master\2012\indices_decision_making.dta"
drop _merge

merge 1:1 hhid pid using "$master\2012\indices_gender_views.dta"
drop _merge

keep if dm_in_sample==1 
keep if h108==1 | h108==3

replace rayon=rayon/1000
gen in_law=(h104==4 | h104==3) if h104<.
		
order hhid pid newpid Z_views_nm_pca Z_views_nm_M Z_views_nm_A Z_decis_all_nm_pca Z_decis_all_nm_M Z_decis_all_nm_A Z_decis_marital_nm_pca Z_decis_marital_nm_M Z_decis_marital_nm_A Z_decis_econ_nm_pca Z_decis_econ_nm_M Z_decis_econ_nm_A Z_decis_fina_nm_pca Z_decis_fina_nm_M Z_decis_fina_nm_A Z_decis_child_nm_pca Z_decis_child_nm_M Z_decis_child_nm_A Z_decis_commun_nm_pca Z_decis_commun_nm_M Z_decis_commun_nm_A

*drop dm_empr_* SD_dm_* gender_view_* decis_* SD_* dm_miss_* 
*drop pca_decis_all pca_decis_all_nm views_pca views_M views_A views_nm_pca views_nm_M views_nm_A pca_gender_view pca_gender_view_nm views_M2 views_A2

local var1 kalm age age2 dm_male children duration duration2 dm_edu_second dm_edu_high dm_uzbek dm_russian dm_other i.rayon, robust
local var2 kalm age age2 dm_male children duration duration2 dm_edu_second dm_edu_high dm_uzbek dm_russian dm_other rural hh_members age_head age2_head dm_edu_head_second dm_edu_head_high dm_arranged dm_bride_cap electr i.rayon, robust
*local var3 kalm age age2 age_dif dm_male children duration duration2 dm_edu_second dm_edu_high dm_uzbek dm_russian dm_other rural hh_members age_head age2_head dm_edu_head_second dm_edu_head_high dm_arranged dm_bride_cap rooms electr hh_assets hh_food_exp hh_nonfood_exp rent i.rayon, robust

local var3 kalm age age2  dm_male children duration duration2 dm_edu_second dm_edu_high dm_uzbek dm_russian dm_other rural hh_members age_head age2_head dm_edu_head_second dm_edu_head_high dm_arranged dm_bride_cap  electr hh_assets hh_food_exp hh_nonfood_exp in_law  i.rayon, robust

local varmale kalm age age2 children duration duration2 dm_edu_second dm_edu_high dm_uzbek dm_russian dm_other rural hh_members age_head age2_head dm_edu_head_second dm_edu_head_high dm_arranged dm_bride_cap  electr hh_assets hh_food_exp hh_nonfood_exp  in_law i.rayon if dm_male==1, robust

local varfem kalm age age2  children duration duration2 dm_edu_second dm_edu_high dm_uzbek dm_russian dm_other rural hh_members age_head age2_head dm_edu_head_second dm_edu_head_high dm_arranged dm_bride_cap  electr hh_assets hh_food_exp hh_nonfood_exp  in_law i.rayon if dm_male==0, robust

*twoway qfit y x

save "E:\Research_1\Output\final.dta",replace

