clear
eststo clear
graph drop _all

global chapter_dir="C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch8"
// global chapter_dir="/Users/abc/Desktop/111-1/東海計量/Solution/Ch8"


cd "$chapter_dir/Results"

use http://www.stata.com/data/s4poe5/data/mexican

// nr2

eststo est_a : reg lnprice bar street school age rich alcohol attractive 

predict res_a, res 
gen res_a2 = res_a^2

eststo het_nr2 : reg res_a2 attractive

scalar nr2 = e(N) * e(r2)

di "NR2 value	:" nr2
di "Critical value:" invchi2tail(1, 0.01)
di "p value		:" chi2tail(1, nr2)

est restore est_a

estat hettest attractive, iid

//f test

est restore het_nr2
