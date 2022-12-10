clear
eststo clear
graph drop _all

global chapter_dir="C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch9"
// global chapter_dir="/Users/abc/Desktop/111-1/東海計量/Solution/Ch9"


cd "$chapter_dir/Results"

use http://www.stata.com/data/s4poe5/data/mroz

drop if lfp == 0

gen ln_wage = ln(wage)

// a 

// b 
corr mothereduc ln_wage educ, c

di r(C)[2,1]/r(C)[3,1]

// c 

global endo_list mothereduc educ ln_wage 

foreach v of global endo_list{
	qui {
		reg `v' c.exper##c.exper 
		predict r_`v', res
	}
}	

corr r_mothereduc r_educ r_ln_wage, c

di r(C)[3,1] / r(C)[2,1]

// d 

eststo est_d : ivreg r_ln_wage (r_educ = r_mothereduc), noconstant