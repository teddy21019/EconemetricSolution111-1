clear
eststo clear
graph drop _all

global chapter_dir="C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch10"
// global chapter_dir="/Users/abc/Desktop/111-1/東海計量/Solution/C10"


cd "$chapter_dir/Results"

use http://www.stata.com/data/s4poe5/data/mroz

drop if lfp == 0
gen ln_wage = ln(wage)


eststo est_baseline : ivregress 2sls ln_wage c.exper##c.exper (educ = mothereduc fathereduc)

// a 

eststo est_a : reg educ c.exper##c.exper mothereduc fathereduc
test mothereduc=fathereduc

/*
	F-value 0.27
	無法拒絕虛無假設，兩者可能相同
*/

// b 
// 作法一
gen parentsum = mothereduc + fathereduc
eststo est_b : reg educ c.exper##c.exper parentsum

// 作法二
constraint 1 mothereduc=fathereduc
cnsreg educ c.exper##c.exper mothereduc fathereduc, constraint(1)

// c 
eststo est_c : ivregress 2sls ln_wage c.exper##c.exper (educ = parentsum)
estat first

// d 
eststo est_d : reg educ c.exper##c.exper c.mothereduc##c.mothereduc c.fathereduc##c.fathereduc
testparm c.mothereduc#* c.fathereduc#*

/*
	F-value 足夠大，所以可以作為 IV
*/

/*
	不過可以發現，四個IV並非每一個都顯著，儘管原本 mothereduc fathereduc都顯著
	
	父母教育跟他們的平方，一定會有很大的相關性。
	OLS中，解釋變數之間的相關性太高的兩個變數，會造成其中一個不顯著。
	以下表格可以明顯看到他們之間的高度相關性
*/

qui{
	capture drop momed2 daded2
	gen momed2 = mothereduc^2
	gen daded2= fathereduc^2
}
corr fathereduc daded2 mothereduc momed2


