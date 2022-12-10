clear
eststo clear
graph drop _all

global chapter_dir="C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch11"
// global chapter_dir="/Users/abc/Desktop/111-1/東海計量/Solution/C11"


cd "$chapter_dir/Results"

use http://www.stata.com/data/s4poe5/data/mroz

gen ln_wage = ln(wage)

// a 

gen nwifeinc=faminc - wage * hours 

bysort lfp : sum age kidsl6 nwifeinc

// b 
/*
	既然為勞動供給，思考哪些東西會增加想工作的時間
	0. ln_wage -- 薪資越高，越想工作賺錢（勞動供給彈性 >0），供給斜率應>0
	1. EDUC -- 高學歷 ??
	2. AGE -- 年紀 ??
	3. KIDSL6 -- 未滿6歲小孩人數：直覺上越高母親會越想花時間撫養，所以負相關
	4. KIDS618 -- 6~18歲小孩人數：對於一部分人來說，學童的撫養費與學費很貴，所以應該會更想工作，我會認為是正相關
	5. NWIFEINC -- 婦女工作以外的收入：收入越多，應該會越不需要工作，因此為負向
*/


// 讓我們很天真地做回歸
// c 
eststo est_c : reg hours ln_wage educ age kidsl6 kids618 nwifeinc if lfp == 1

/*
	勞動供給彈性竟然<0 ?負斜率的供給曲線？？ 
*/

// d 

eststo reduce_d : reg ln_wage educ age kidsl6 kids618 nwifeinc exper
/*
	教育的係數為 0.10115，表示多一年教育，薪資成長為 10.115% 
	經驗的係數為 0.0175，表示多一年經驗，薪資成長為 1.75%
*/

// e 
/*
	經驗的確會增加薪資，但常理上可以推測經驗並不會增加勞動供給
	（應該不會因為很有經驗就讓你很想工作，不過的確可以argue做久想退休，可能負相關）
	
	然而從數據上來看，exper要作為IV的條件為，他在縮減式，也就是第一階段的顯著性要很高
	
	因為表示他會改變勞動需求，影響薪資，這樣才可以認定(identify)出供給曲線
*/
test exper

/*
	F = 12.96 夠高了 
*/

// f 
eststo est_supply : ivregress 2sls hours (ln_wage = exper) educ age kidsl6 kids618 nwifeinc, first

/*
	終於看到 hours 與 ln_wage 正斜率，一個供給曲線該有的樣貌
*/
