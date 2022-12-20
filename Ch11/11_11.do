clear
eststo clear
graph drop _all

global chapter_dir="C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch11"
// global chapter_dir="/Users/abc/Desktop/111-1/東海計量/Solution/Ch11"


cd "$chapter_dir/Results"

use http://www.stata.com/data/s4poe5/data/newbroiler

drop if year < 1960

// a 

/*
	內生變數為「均衡所決定的變數」
	在價格模型中，為數量與價格，P, Q
	
	其他變數皆為外生變數
*/


// b 


foreach v of var q p y pb{
	gen ln_`v'=ln(`v')
}

eststo est_b : reg ln_q ln_p ln_y ln_pb popgro

// c 
* 略

// d 
gen ln_pf=ln(pf)
gen time = year - 1949 
gen qprod_l = ln(qprod[_n - 1])
gen lexpts_l = lexpts[_n - 1]

eststo est_d : ivregress 2sls ln_q (ln_p = ln_pf time qprod_l lexpts_l) ln_y ln_pb popgro
predict res_d, res

// e 
/* 作法一、
		在 ivregress 之後，直接檢定第一階段回歸
*/

estat firststage


/* 作法二、
		手動估計，並用 test 指令
*/
eststo first_est_e : reg ln_p ln_pf time qprod_l lexpts_l ln_y ln_pb popgro
test ln_pf time qprod_l lexpts_l

/*
	一組好的 IV 需要聯合檢定至少 F > 10
	這裏 F 只有4.06
*/

// f 
// 略

// g 

/*
	這是 Ch 9 的東西
	
	作法一、用 newey 手動在第一階段計算 HAC ，異質自相關穩健標準誤差
*/

// 要先宣告時間是哪一個欄位
tsset time

newey ln_p ln_pf time qprod_l lexpts_l ln_y ln_pb popgro, lag(2)
test ln_pf time qprod_l lexpts_l

/*
	作法二、ivregress 後面可以直接指定標準誤差的算法
	因此直接指定為 hac nw (Heteroskedasticity- and autocorrelation-consistent (HAC)) using Newey-West estimator
*/

eststo est_HAC_2 : ivregress 2sls ln_q (ln_p = ln_pf time qprod_l lexpts_l) ln_y ln_pb popgro, vce(hac nw 2) first

/*
	兩者做出來，F 都是 3.57
	表示在異質自相關穩健標準誤差之下，也都無法拒絕這是一組不好的 IV
	
*/

// h 


esttab est_d est_HAC_2, mti se

/*
	也可以試試，如果 lag 不是 2 而是 N-2 
	則都會顯著
	
	想想意義？因為我也不清楚
*/
eststo est_HAC_N : ivregress 2sls ln_q (ln_p = ln_pf time qprod_l lexpts_l) ln_y ln_pb popgro, vce(hac nw) first
esttab est_d est_HAC_2 est_HAC_N, mti se

