clear
eststo clear
graph drop _all

global chapter_dir="C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch10"
// global chapter_dir="/Users/abc/Desktop/111-1/東海計量/Solution/C10"


cd "$chapter_dir/Results"

use http://www.stata.com/data/s4poe5/data/mroz

drop if lfp == 0
gen ln_wage = ln(wage)

// a 
gen mothercoll = 0
replace mothercoll = 1 if mothereduc > 12

gen fathercoll = 0
replace fathercoll = 1 if fathereduc > 12

gen collsum = mothercoll + fathercoll
gen collboth = mothercoll*fathercoll

/*
	課本到底翻譯在翻三小
	原文是 What values do COLLSUM and COLLBOTH take?
	意思是：這兩個新變數會有哪些值？

	collsum = 2 : 爸媽都上大學				此時 collboth = 1
	collsum = 1 : 爸媽其中一個上大學		此時 collboth = 0
	collsum = 0 : 爸媽沒人上大學			此時 collboth = 0
*/

sum collboth
di "女性的父母都上過大學的比例：" r(mean)

// b 
corr educ collsum collboth

/*
	好的 IV 的條件：要不直接影響 Y，但是要跟可能有內生性的變數X有相關
	這裡 Y 是薪資，教育年資對於薪資之間，可能有其他共同因素
	例如聰明的人更有可能去高等教育，而聰明也可能讓你薪資增加
	
	因此才要找一個"IV"
	
	父母親有無上大學理應不直接影響未來薪資（除非內定）
	但是父母上大學會影響小孩對於上大學的決策，可能出自嚮往或期望
	
	原本只用父母的教育，作為工具變數，可能無法捕捉到「有上大學」
	這一個特定事情的重要性，所以改用這樣一個指標變數，也許會增加他的力度
	
	但我個人覺得用父母教育年資就夠了
*/

// c 

eststo est_c : ivregress 2sls ln_wage c.exper##c.exper (educ = collsum)

esttab est_c, keep(educ) ci

// d 
reg educ collsum
test collsum

// e 
eststo est_e : reg educ c.exper##c.exper mothercoll fathercoll
test mothercoll=fathercoll
