****************
* This do file is to Analyze the reason behind each kepdes' decision in choosing the bengkok system
* brahmana.satiman@gmail.com
* 1 Sept 2025
*****************

cd "~/Dropbox/indoRA-F2022/JMPtables/" // change this to your file
use "data/blokdistribusi&pengunaanbengkok_compiledClean.dta", clear 

*** Keep relevant variable
keep why* ADMNCODE
drop *og
reshape long whyUseThisSystem, i(ADMNCODE) j(kepdes)
duplicates drop whyUseThisSystem, force // copy paste the result to excel for manual categorizing

*** Merge back the excel file into the dataset to include the manually categorized variable C17_category

use "data/blokdistribusi&pengunaanbengkok_compiledClean.dta", clear 
keep why* ADMNCODE
drop *og
reshape long whyUseThisSystem, i(ADMNCODE) j(kepdes)
replace whyUseThisSystem = strlower(whyUseThisSystem)

* import excel
preserve
import excel "data/C17_categories.xlsx", sheet("Sheet1") firstrow allstring clear
destring kepdes, replace
rename cat_1 C17_category
replace whyUseThisSystem = strlower(whyUseThisSystem)
duplicates drop whyUseThisSystem, force
tempfile categ
save `categ', replace
restore

merge m:1 whyUseThisSystem using `categ'

* manually fix obs that won't match

replace C17_category = "2" if whyUseThisSystem == ":selain itu memang sudah dari dulu pengelolaan disewakan "
replace C17_category = "4" if whyUseThisSystem == "aturan dari desa dan akhirnya menjadi kebiasaan "
replace C17_category = "3" if whyUseThisSystem == "memang sudah dari dulu ada kegotong-royongan, meskipun ada kepala desa yang kelola sendiri tp sedikit hanya 100 bata "
replace C17_category = "3" if whyUseThisSystem == "memang sudah kebiasaan dimasyarakat, jika digarap sendiri akan jadi omongan "
replace C17_category = "2" if whyUseThisSystem == "sudah kebiasaan dimaskarakat "
replace C17_category = "2" if whyUseThisSystem == "menjadi sebuah tradisi"

* clean
drop _merge
duplicates drop ADMNCODE kepdes, force // Ichecked and it's safe to drop (as a result of the merging)
drop if ADMNCODE == ""
preserve


*** Create the second categorical variable (this one in on village level rather than village x kabupaten level)
keep ADMNCODE kepdes C17_category
duplicates drop ADMNCODE C17_category, force 
drop if C17_category == ""
destring C17_category, gen(C17_cat) // for sorting only
bysort ADMNCODE (C17_cat): gen C17_category_2 = C17_category[1] + C17_category[2] + C17_category[3] + C17_category[4]
keep ADMNCODE C17_category_2
duplicates drop ADMNCODE, force
tempfile categ_2
save `categ_2', replace

*** Merge in with category 1 data set to create the complete data
restore
merge m:1 ADMNCODE using `categ_2'
encode C17_category_2, gen(C17_category_2_encode)
drop _merge


save "data/blokdistribusi&pengunaanbengkok_compiledClean_categorical", replace

