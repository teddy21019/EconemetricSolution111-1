clear
eststo clear
graph drop _all

global chapter_dir="C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch10"
// global chapter_dir="/Users/abc/Desktop/111-1/東海計量/Solution/C10"


cd "$chapter_dir/Results"

use http://www.stata.com/data/s4poe5/data/mroz

drop if lfp == 0

// a 

eststo est_a : reg educ c.exper##c.exper mothereduc 
predict reduchat, res

di "Sum of squared residual	of a	:" e(rss)

// b
eststo est_b : reg educ c.exper##c.exper
predict reduc, res

di "Sum of squared residual	of b	:" e(rss)

// c 
reg mothereduc c.exper##c.exper
predict rmom, res
di "Sum of squared residual	of c	:" e(rss)

// d 
reg reduc rmom, noconst