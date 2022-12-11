clear
eststo clear
graph drop _all

//global chapter_dir="C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch11"
global chapter_dir="/Users/abc/Desktop/111-1/東海計量/Solution/Ch11"


cd "$chapter_dir/Results"

use http://www.stata.com/data/s4poe5/data/newbroiler

drop if year < 1960

// a 

/*
	內生變數為當期的雞肉產量與價格
	外生變數為其他，飼料的價格、時間、以及上一期的供給
	
	上一期的供給會影響這一期的供給，這是因為雞隻數量會動態調整
	
*/

// b 

gen ln_qprod=ln(qprod)
gen ln_pf = ln(pf)
gen ln_y = ln(y)
gen time = year - 1949

gen ln_p = ln(p)
gen ln_pb = ln(pb)

// 宣告為時間序列
tsset time

// L.ln_qprod 表示用 ln_qprod的落後一期 
// 注意，要先宣告為時間序列，才可以這樣操作
eststo est_b : reg ln_qprod ln_p ln_pf time L.ln_qprod

// c  

eststo est_first_c : reg ln_p ln_y ln_pb popgro L.lexpts ln_pf time L.ln_qprod

test ln_y ln_pb popgro L.lexpts


// d 
eststo est_2SLS : ivregress 2sls ln_qprod (ln_p = ln_y ln_pb popgro L.lexpts) /// 
	ln_pf time L.ln_qprod, first

estat first
	
eststo est_2SLS_HAC : ivregress 2sls ln_qprod (ln_p = ln_y ln_pb popgro L.lexpts) /// 
	ln_pf time L.ln_qprod, first vce(hac nw)
	
esttab est_b est_2SLS*, mti se
	
	
	
	
	
	
