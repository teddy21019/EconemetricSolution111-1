clear
eststo clear
graph drop _all

global chapter_dir="C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch7"
// global chapter_dir="/Users/abc/Desktop/111-1/東海計量/Solution/CH7"


cd "$chapter_dir/Results"

use http://www.stata.com/data/s4poe5/data/olympics

drop if !(year==92 & medaltot>0 & missing==0) 
count	// 應該要出現 64 個

//a 

gen ln_pop = ln(pop)
gen ln_gdp = ln(gdp)

eststo est_a : reg medaltot ln_pop ln_gdp if (co_code != "GBR")

//b

predict res_a, res
gen res_a2=res_a^2

eststo het_b : reg res_a2 ln_pop ln_gdp if (co_code != "GBR")

// F-test
est restore het_b
test ln_pop ln_gdp

// R2 test
scalar nr2=e(N)*e(r2)
di "NR2 value	:"nr2
di "p-value		:"chi2tail(2, nr2)

//用內建的指令
est restore est_a
estat hettest ln_pop ln_gdp, fstat		// F-test
estat hettest ln_pop ln_gdp, iid		// nR^2 test

//c 
eststo est_c : reg medaltot ln_pop ln_gdp if (co_code != "GBR"), r

test ln_gdp		// 這是雙尾！

//單尾： H0 : _b[ln_gdp] = 0
//		 Ha : _b[ln_gdp] > 0
scalar t_value = _b[ln_gdp] / _se[ln_gdp]
di "Critical value	5%	:" invttail(e(df_r), 0.05)
di "Critical value	10%	:" invttail(e(df_r), 0.1)
di "t-value				:" t_value
di "p-value				:" ttail(e(df_r), t_value)

//d 
test ln_pop		// 這是雙尾！

//單尾： H0 : _b[ln_pop] = 0
//		 Ha : _b[ln_pop] > 0
scalar t_value = _b[ln_pop] / _se[ln_pop]
di "Critical value	5%	:" invttail(e(df_r), 0.05)
di "Critical value	10%	:" invttail(e(df_r), 0.1)
di "t-value				:" t_value
di "p-value				:" ttail(e(df_r), t_value)

// 5%之下無法拒絕，10%之下可拒絕


// e 
est restore est_c 

local ln_58 = ln(58)
local ln_1010 = ln(1010)
margin, at(ln_pop = `ln_58' ln_gdp=`ln_1010')

// f 
margin, at(ln_pop = `ln_58' ln_gdp=`ln_1010') expression(predict(xb) - 20)

// 或是用 lincom ，就不會出現用 delta method 造成變異數的誤差
