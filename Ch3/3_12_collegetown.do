clear
graph drop _all

//cd "C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch3\Results"
//use "C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\DATA\capm5"

cd "/Users/abc/Desktop/111-1/東海計量/Solution/Ch3/Results"
use "/Users/abc/Desktop/111-1/東海計量/Solution/DATA/collegetown"



    				//======================//
    				//						//
    				//			(a)			//
    				//						//
    				//======================//
    				//	H0 : 在 2000 sqft 時邊際效果≤13,000 

/*
		Ha : 在 2000 sqft 時邊際效果>13,000 
		為右尾檢定
*/

reg price c.sqft#c.sqft

/*
		Price = a + b*sqft^2 + e
		這樣的非線性迴歸，如果要計算他的邊際效果
		需要先做個簡單的微分
		
		dP/ds = 2*b*sqft
*/

// 可以用 lincom 這個指令來進行線性組合 (linear combination)
// lincom 中可以使用估計的參數，同時保有他們的點估計與區間估計
// 因此他也會回報線性組合的區間估計

lincom 2*_b[c.sqft#c.sqft]*20

/*
		有兩種做法，第一是拿這個點估計與標準誤差，進行假設檢定
===============
*/
		scalar tstat_a = ( r(estimate)-13 )/( r(se) )
		di "T-statistic	:	" tstat_a
		di "p-value for right tail test	:	" ttail(500, tstat_a)

		/*
				無法拒絕虛無假設，所以選擇接受 H0 : 邊際效果 ≤ 13,000 
		*/

/*
		第二種做法，是直接在線性組合中扣除 13 ，因為
		H0 : 2*b*sqft ≤ 13 	相當於  2*b*sqft - 13 ≤ 0
*/

		lincom 2*_b[c.sqft#c.sqft]*20 - 13
		/*
				可以直接看報表中的 T-statistic來做判斷
		*/

		
		
    				//======================//
    				//						//
    				//			(b)			//
    				//						//
    				//======================//
    				//	H0 : 在 4000 sqft 時邊際效果≤13,000 
					
lincom 2*_b[c.sqft#c.sqft]*40

scalar tstat_a = ( r(estimate)-13 )/( r(se) )
di "T-statistic	:	" tstat_a
di "p-value for right tail test	:	" ttail(500, tstat_a)
/*
		p-value ≤ 0.05，因此拒絕虛無假設
		得以相信邊際效果 >13,000 
*/



    				//======================//
    				//						//
    				//			(c)			//
    				//						//
    				//======================//
    				//	在 2000 sqft 時，房價的區間估計 
					
/*
		Price = a + b*sqft^2 + e
		E(price) =  a + b*sqft^2
		(注意，這裡把模型的 a,b 與估計的 a,b 用同樣的符號代替，
		但實際上兩者會不同，模型的 a,b 是有區間的，但取期望值
		之後會與原模型一樣，這是 BLUE 裡面的 U--unbiased)
*/

// 注意！在使用 lincom 時不可用次方 ^
// 我猜是因為他需要全部都是線性的，所以這樣判斷一勞永逸

lincom _b[_cons] + _b[c.sqft#c.sqft]*(20*20)

/*
		向一般大眾說明區間估計：
		
		我們透過模型去推估在坪數2000時，他預期的房價會是多少。
		
		但是我們手邊只有有限的500筆資料，並不能很確定真實世界中，看到2000平方英尺的房子
		，他的預期房價。我們只能說這個預期房價，會在這兩個數字之間，而且我們是有十足的把握
		(95%)真的會落在這裡面。
		
		要注意，並不是路上找一棟房子，他的房價一定會在這區間。房價會受很多干擾因素影響，
		這邊指的是「平均而言」的預期，有信心在這個範圍。
*/


    				//======================//
    				//						//
    				//			(d)			//
    				//						//
    				//======================//
    				//	觀察樣本 
					
list if sqft==20

sum if sqft==20
