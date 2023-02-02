clear
global projectdir "/Volumes/ExternalSSD/Dropbox/NV Malaya (Gedeon & Chun)/Analysis"
global rawdir "$projectdir/01_raw"
global masterdir "$projectdir/04_master"
global tempdir "$projectdir/03_temp"


global projectdir "C:\Users\cckok3\Dropbox\NV Malaya (Gedeon & Chun)\Analysis"
global rawdir "$projectdir/01_raw"
global masterdir "$projectdir/04_master"
global tempdir "$projectdir/03_temp"

cd "$masterdir"
use "DM_GE13_matched_clean.dta", clear

catplot real_dist_cat_3 comshft_dist_10000_cat_3 if NEGERI == "SELANGOR" | NEGERI == "NEGERI SEMBILAN"
ta real_dist_cat_3
ta comshft_dist_10000_cat_3

// *================================================================================
// * 02: GET BETAS FROM PLACEBO REGS 
// *================================================================================
global topovars "elevation slope X Y"
global climvars "amtmpmy aprecmy "
global soilvars "tesp tocmy texture1 texture2 drainage1 drainage4 st_rn_fd_h1 st_rn_fd_h3"
global distvars "rivers_distance coastlines_distance towns_distance"
global popvars "malays_share47 chinese_share47 indians_share47 europeans_share47 eurasians_share47 log_total_pop47"
global controls "$topovars $climvars $soilvars $distvars $popvars"


forval k = 5000(100)20000{
loc controls "$topovars $climvars $soilvars $distvars $popvars"

drop if PAR_BARU == "LANGKAWI" | PAR_BARU == "BUKIT BENDERA" | PAR_BARU == "BAYAN BARU" | PAR_BARU == "BALIK PULAU" | PAR_BARU == "TANJONG" | PAR_BARU == "JELUTONG" | PAR_BARU == "BUKIT GELUGOR" 
keep if NEGERI == "SELANGOR" | NEGERI == "NEGERI SEMBILAN"
	
foreach i of numlist 0(3)21{
reg percent_bn ib21.comshft_dist_`k'_cat_3   `controls' i.comshft_nn_`k' i.ParlCode if dm_nv==. , vce(cluster ParlCode)	
	qui su percent_bn if e(sample)==1
	scalar meandep = r(mean)
	local meandep: di %6.2f scalar(meandep)
	scalar coef`i' = _b[`i'.comshft_dist_`k'_cat_3]
	scalar se`i' = _se[`i'.comshft_dist_`k'_cat_3]
	scalar t`i' = _b[`i'.comshft_dist_`k'_cat_3]/_se[`i'.comshft_dist_`k'_cat_3]
	scalar pval`i' = 2*ttail(e(df_r),abs(t`i'))
	scalar lb`i' =  _b[`i'.comshft_dist_`k'_cat_3] - invttail(e(df_r),0.025)*_se[`i'.comshft_dist_`k'_cat_3]
	scalar ub`i' = _b[`i'.comshft_dist_`k'_cat_3] + invttail(e(df_r),0.025)*_se[`i'.comshft_dist_`k'_cat_3]
}

g difcoef = .
g difse = .
g difpval = .
g diflb = .
g difub = .
g dist_bin = .
g comshft_dist = `k'

forvalues i = 0(3)21{
	local j = `i' + 2
	replace dist_bin = scalar(`i') in `j'
	replace difcoef = scalar(coef`i') in `j'
	replace difse = scalar(se`i') in `j'
	replace difpval = scalar(pval`i') in `j'
	replace diflb = scalar(lb`i') in `j'
	replace difub = scalar(ub`i') in `j'
}

g sig5 = difpval <=0.05
g sig10 = difpval <=0.1 & difpval>0.05 
keep dist_bin dif* sig* comshft_dist
drop if difcoef == .

save "../05_results/com/percentbn_comshft_`k'.dta", replace
use "DM_GE13_matched_clean.dta", clear
}


/*-----------------------------------------------*/
/* GET BETAS FROM REAL REG                       */
/*-----------------------------------------------*/
use "DM_GE13_matched_clean.dta", clear

loc controls "$topovars $climvars $soilvars $distvars $popvars"
drop if PAR_BARU == "LANGKAWI" | PAR_BARU == "BUKIT BENDERA" | PAR_BARU == "BAYAN BARU" | PAR_BARU == "BALIK PULAU" | PAR_BARU == "TANJONG" | PAR_BARU == "JELUTONG" | PAR_BARU == "BUKIT GELUGOR" 
keep if NEGERI == "SELANGOR" | NEGERI == "NEGERI SEMBILAN"
	

foreach i of numlist 0(3)21{
reg percent_bn ib21.real_dist_cat_3   `controls' i.real_nn_10000 i.ParlCode  if dm_nv==., vce(cluster ParlCode)	
	qui su percent_bn if e(sample)==1
	scalar meandep = r(mean)
	global meandep: di %6.2f scalar(meandep)
	scalar coef`i' = _b[`i'.real_dist_cat_3]
	scalar se`i' = _se[`i'.real_dist_cat_3]
	scalar t`i' = _b[`i'.real_dist_cat_3]/_se[`i'.real_dist_cat_3]
	scalar pval`i' = 2*ttail(e(df_r),abs(t`i'))
	scalar lb`i' =  _b[`i'.real_dist_cat_3] - invttail(e(df_r),0.025)*_se[`i'.real_dist_cat_3]
	scalar ub`i' = _b[`i'.real_dist_cat_3] + invttail(e(df_r),0.025)*_se[`i'.real_dist_cat_3]
}
g difcoef = .
g difse = .
g difpval = .
g diflb = .
g difub = .
g dist_bin = .
g comshft_dist = 0

forvalues i = 0(3)21{
	local j = `i' + 1
	replace dist_bin = scalar(`i') in `j'
	replace difcoef = scalar(coef`i') in `j'
	replace difse = scalar(se`i') in `j'
	replace difpval = scalar(pval`i') in `j'
	replace diflb = scalar(lb`i') in `j'
	replace difub = scalar(ub`i') in `j'
}

g sig5 = difpval <=0.05
g sig10 = difpval <=0.1 & difpval>0.05 
keep dist_bin dif* sig* comshft_dist
drop if difcoef == .
save "../05_results/com/percentbn_real.dta", replace


/*-----------------------------------------------*/
/* PLOT LINES OF */
/*-----------------------------------------------*/

* Append estimates from placebo regs and real regs 
use "../05_results/com/percentbn_comshft_500.dta", clear
forval i = 5000(100)20000{
	append using "../05_results/com/percentbn_comshft_`i'.dta"
}
append using "../05_results/com/percentbn_real.dta"
save "../04_master/percentbn_comshft.dta", replace


xtset comshft_dist dist_bin
xtline difcoef, overlay legend(off) ///
 scheme(s2color) addplot(line difcoef dist_bin if comshft_dist==0, lp(solid)lw(thick)lcolor(black))

/*-----------------------------------------------*/
/* PLOT LINES OF ABSOLUTE COEFS. COEF FROM REAL NV IN VECTICAL LINE  */
/*-----------------------------------------------*/
 
use "../05_results/com/percentbn_comshft_5000.dta", clear
keep difcoef comshft_dist dist_bin
reshape wide difcoef, i(comshft_dist) j(dist_bin)
save "tmp1", replace

forval i = 5100(100)20000{
	use "../05_results/com/percentbn_comshft_`i'.dta", clear
	keep difcoef comshft_dist dist_bin 
	reshape wide difcoef, i(comshft_dist) j(dist_bin)
	save "tmp2", replace
	use "tmp1", clear
	append using "tmp2"
	save "tmp1", replace
}
 
use "../05_results/com/percentbn_real.dta"  
keep difcoef comshft_dist dist_bin 
reshape wide difcoef, i(comshft_dist) j(dist_bin)
save "tmp2", replace

use "tmp1", clear
append using "tmp2"

gsort +comshft_dist

forval i=0(3)21 {

        * create absolute values of effects
        gen abscoef`i' = abs(difcoef`i')

        * summarize absolute values of effects (stores p95 and p90 in r())
        summ difcoef`i' if _n != 1, d

        * indicate 5% and 10% significance
        gen sig5`i' = difcoef`i'[1] > `=r(p95)'
        gen sig10`i' = difcoef`i'[1] > `=r(p90)' & difcoef`i'[1] <= `=r(p95)'
		drop abscoef* 

        * subtract placebo mean from the real effects
            summ difcoef`i' if _n != 1
            replace difcoef`i' = difcoef`i' - `=r(mean)' in 1
        }

keep in 1
keep difcoef* sig10* sig5*
gen id = 1
reshape long difcoef sig10 sig5, i(id) j(dist_bin)
 

twoway /// 
	(line difcoef dist_bin, sort msymbol(none) clcolor(black) clpat(solid) clwidth(medium)) ///
	(scatter difcoef dist_bin if sig5, sort msymbol(+) msize(large) mcolor(red)) ///
	(scatter difcoef dist_bin if sig10, sort msymbol(O) msize(large) mcolor(red)) ///
	(scatter difcoef dist_bin if (!sig5 & !sig10), sort msymbol(Oh) msize(large) mcolor(black)), ///
	graphregion(color(white)) xtitle("Distance to New Village (km)") ytitle("Vote Share of Ethno-nationalistic Party In 2013" "(Federal Level)") xlabel(0(1)21) title("") ///
	legend(order(2 "p < 0.05" 3 "p < 0.10" 4 "Not Statistically Significant") ///
	row(1) note("Mean of Dependent Variable: `meandep' ", size(big)) position(6) tstyle(body)) ///
	yline(0, lcolor(black) lpattern(dash) lwidth(thin))

graph export "../../../Apps/Overleaf/ethnic-politics-my-KL/output/percentbn_commonshft.pdf" , as(pdf) replace

















/*

forval k = 10000(100)20000{
loc controls "$topovars $climvars $soilvars $distvars $popvars"

drop if PAR_BARU == "LANGKAWI" | PAR_BARU == "BUKIT BENDERA" | PAR_BARU == "BAYAN BARU" | PAR_BARU == "BALIK PULAU" | PAR_BARU == "TANJONG" | PAR_BARU == "JELUTONG" | PAR_BARU == "BUKIT GELUGOR" 
keep if NEGERI == "SELANGOR" | NEGERI == "NEGERI SEMBILAN"
	
foreach i of numlist 0(3)21{
reg percent_bn ib21.comshft_dist_`i'_bufkillcat3   `controls' i.comshft_nn_`k' if dm_nv==. , vce(cluster ParlCode)	
	qui su percent_bn if e(sample)==1
	scalar meandep = r(mean)
	local meandep: di %6.2f scalar(meandep)
	scalar coef`i' = _b[`i'.comshft_dist_`k'_cat_3]
	scalar se`i' = _se[`i'.comshft_dist_`k'_cat_3]
	scalar t`i' = _b[`i'.comshft_dist_`k'_cat_3]/_se[`i'.comshft_dist_`k'_cat_3]
	scalar pval`i' = 2*ttail(e(df_r),abs(t`i'))
	scalar lb`i' =  _b[`i'.comshft_dist_`k'_cat_3] - invttail(e(df_r),0.025)*_se[`i'.comshft_dist_`k'_cat_3]
	scalar ub`i' = _b[`i'.comshft_dist_`k'_cat_3] + invttail(e(df_r),0.025)*_se[`i'.comshft_dist_`k'_cat_3]
}

g difcoef = .
g difse = .
g difpval = .
g diflb = .
g difub = .
g dist_bin = .
g comshft_dist = `k'

forvalues i = 0(3)21{
	local j = `i' + 2
	replace dist_bin = scalar(`i') in `j'
	replace difcoef = scalar(coef`i') in `j'
	replace difse = scalar(se`i') in `j'
	replace difpval = scalar(pval`i') in `j'
	replace diflb = scalar(lb`i') in `j'
	replace difub = scalar(ub`i') in `j'
}

g sig5 = difpval <=0.05
g sig10 = difpval <=0.1 & difpval>0.05 
keep dist_bin dif* sig* comshft_dist
drop if difcoef == .

save "../05_results/com/percentbn_comshft_`k'.dta", replace
use "DM_GE13_matched_clean.dta", clear
}


/*-----------------------------------------------*/
/* GET BETAS FROM REAL REG                       */
/*-----------------------------------------------*/
use "DM_GE13_matched_clean.dta", clear

loc controls "$topovars $climvars $soilvars $distvars $popvars"
drop if PAR_BARU == "LANGKAWI" | PAR_BARU == "BUKIT BENDERA" | PAR_BARU == "BAYAN BARU" | PAR_BARU == "BALIK PULAU" | PAR_BARU == "TANJONG" | PAR_BARU == "JELUTONG" | PAR_BARU == "BUKIT GELUGOR" 
keep if NEGERI == "SELANGOR" | NEGERI == "NEGERI SEMBILAN"
	

foreach i of numlist 0(3)21{
reg percent_bn ib21.real_dist_cat_3   `controls' i.nearest_NV452 if dm_nv==., vce(cluster ParlCode)	
	qui su percent_bn if e(sample)==1
	scalar meandep = r(mean)
	global meandep: di %6.2f scalar(meandep)
	scalar coef`i' = _b[`i'.real_dist_cat_3]
	scalar se`i' = _se[`i'.real_dist_cat_3]
	scalar t`i' = _b[`i'.real_dist_cat_3]/_se[`i'.real_dist_cat_3]
	scalar pval`i' = 2*ttail(e(df_r),abs(t`i'))
	scalar lb`i' =  _b[`i'.real_dist_cat_3] - invttail(e(df_r),0.025)*_se[`i'.real_dist_cat_3]
	scalar ub`i' = _b[`i'.real_dist_cat_3] + invttail(e(df_r),0.025)*_se[`i'.real_dist_cat_3]
}
g difcoef = .
g difse = .
g difpval = .
g diflb = .
g difub = .
g dist_bin = .
g comshft_dist = 0

forvalues i = 0(3)21{
	local j = `i' + 1
	replace dist_bin = scalar(`i') in `j'
	replace difcoef = scalar(coef`i') in `j'
	replace difse = scalar(se`i') in `j'
	replace difpval = scalar(pval`i') in `j'
	replace diflb = scalar(lb`i') in `j'
	replace difub = scalar(ub`i') in `j'
}

g sig5 = difpval <=0.05
g sig10 = difpval <=0.1 & difpval>0.05 
keep dist_bin dif* sig* comshft_dist
drop if difcoef == .
save "../05_results/com/percentbn_real.dta", replace


/*-----------------------------------------------*/
/* PLOT LINES OF */
/*-----------------------------------------------*/

* Append estimates from placebo regs and real regs 
use "../05_results/com/percentbn_comshft_500.dta", clear
forval i = 5000(100)20000{
	append using "../05_results/com/percentbn_comshft_`i'.dta"
}
append using "../05_results/com/percentbn_real.dta"
save "../04_master/percentbn_comshft.dta", replace


xtset comshft_dist dist_bin
xtline difcoef, overlay legend(off) ///
 scheme(s2color) addplot(line difcoef dist_bin if comshft_dist==0, lp(solid)lw(thick)lcolor(black))

/*-----------------------------------------------*/
/* PLOT LINES OF ABSOLUTE COEFS. COEF FROM REAL NV IN VECTICAL LINE  */
/*-----------------------------------------------*/
 
use "../05_results/com/percentbn_comshft_5000.dta", clear
keep difcoef comshft_dist dist_bin
reshape wide difcoef, i(comshft_dist) j(dist_bin)
save "tmp1", replace

forval i = 5100(100)20000{
	use "../05_results/com/percentbn_comshft_`i'.dta", clear
	keep difcoef comshft_dist dist_bin 
	reshape wide difcoef, i(comshft_dist) j(dist_bin)
	save "tmp2", replace
	use "tmp1", clear
	append using "tmp2"
	save "tmp1", replace
}
 
use "../05_results/com/percentbn_real.dta"  
keep difcoef comshft_dist dist_bin 
reshape wide difcoef, i(comshft_dist) j(dist_bin)
save "tmp2", replace

use "tmp1", clear
append using "tmp2"

gsort +comshft_dist

forval i=0(3)21 {

        * create absolute values of effects
        gen abscoef`i' = abs(difcoef`i')

        * summarize absolute values of effects (stores p95 and p90 in r())
        summ difcoef`i' if _n != 1, d

        * indicate 5% and 10% significance
        gen sig5`i' = difcoef`i'[1] > `=r(p95)'
        gen sig10`i' = difcoef`i'[1] > `=r(p90)' & difcoef`i'[1] <= `=r(p95)'
		drop abscoef* 

        * subtract placebo mean from the real effects
            summ difcoef`i' if _n != 1
            replace difcoef`i' = difcoef`i' - `=r(mean)' in 1
        }

keep in 1
keep difcoef* sig10* sig5*
gen id = 1
reshape long difcoef sig10 sig5, i(id) j(dist_bin)
 

twoway /// 
	(line difcoef dist_bin, sort msymbol(none) clcolor(black) clpat(solid) clwidth(medium)) ///
	(scatter difcoef dist_bin if sig5, sort msymbol(+) msize(large) mcolor(red)) ///
	(scatter difcoef dist_bin if sig10, sort msymbol(O) msize(large) mcolor(red)) ///
	(scatter difcoef dist_bin if (!sig5 & !sig10), sort msymbol(Oh) msize(large) mcolor(black)), ///
	graphregion(color(white)) xtitle("Distance to New Village (km)") ytitle("Vote Share of Ethno-nationalistic Party In 2013" "(Federal Level)") xlabel(0(1)21) title("") ///
	legend(order(2 "p < 0.05" 3 "p < 0.10" 4 "Not Statistically Significant") ///
	row(1) note("Mean of Dependent Variable: `meandep' ", size(big)) position(6) tstyle(body)) ///
	yline(0, lcolor(black) lpattern(dash) lwidth(thin))

graph export "../../../Apps/Overleaf/ethnic-politics-my-KL/output/percentbn_commonshft.pdf" , as(pdf) replace

/* Unimportant below... 

/*-----------------------------------------------*/
/* PLOT HISTOGRAMS  */
/*-----------------------------------------------*/
 
use "../05_results/com/percentbn_comshft_500.dta", clear
keep difcoef comshft_dist dist_bin
reshape wide difcoef, i(comshft_dist) j(dist_bin)
save "tmp1", replace

forval i = 600(100)20000{
	use "../05_results/com/percentbn_comshft_`i'.dta", clear
	keep difcoef comshft_dist dist_bin 
	reshape wide difcoef, i(comshft_dist) j(dist_bin)
	save "tmp2", replace
	use "tmp1", clear
	append using "tmp2"
	save "tmp1", replace
}
 
use "../05_results/com/percentbn_real.dta"  
keep difcoef comshft_dist dist_bin 
reshape wide difcoef, i(comshft_dist) j(dist_bin)
save "tmp2", replace

use "tmp1", clear
append using "tmp2"

gsort +comshft_dist

forval i = 0(1)20{
	su difcoef`i' if _n == 1
	local real_mean `r(mean)' 
	twoway (hist difcoef`i' if _n !=1) || (scatteri 0 `real_mean' 0.1 `real_mean', c(1) m(i))
	graph export "../../../Apps/Overleaf/ethnic-politics-my-KL/output/percentbn_histo_dist`i'.pdf" , as(pdf) replace
}

