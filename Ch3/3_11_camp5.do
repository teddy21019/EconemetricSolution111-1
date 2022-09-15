clear
graph drop _all

//cd "C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch3\Results"
//use "C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\DATA\capm5"

cd "/Users/abc/Desktop/111-1/東海計量/Solution/Ch3/Results"
use "/Users/abc/Desktop/111-1/東海計量/Solution/DATA/capm5"

qui sum
scalar num = r(N)-2

gen prem_xom 	= xom - riskfree
gen prem_msft 	= msft - riskfree
gen prem_ge		= ge  - riskfree
gen prem_ibm	= ibm - riskfree
gen prem_ford	= ford - riskfree
gen prem_dis	= dis - riskfree

gen prem_mkt	= mkt - riskfree

    				//======================//
    				//						//
    				//			(a)			//
    				//						//
    				//======================//
    				//	Beta : Exxon-Mobil vs Microsoft 


// 這邊用 estout 套件，把結果存起來
eststo clear
//		名稱	顯示標題				指令
eststo est_xom, title("Exxon-Mobil"):		reg prem_xom prem_mkt
eststo est_ms, title("Microsoft"):		reg prem_msft prem_mkt

//		一欄內	係數		信心水準	r2
esttab, cell( b(fmt(3)) ci(fmt(3) par) ) r2




    				//======================//
    				//						//
    				//			(b)			//
    				//						//
    				//======================//
    				//	H0 : beta = 1 for Ford, GE, Exxon 


eststo est_ford, title("Ford"):		reg prem_ford prem_mkt
eststo est_ge, title("GE"):		reg prem_ge prem_mkt

// 把估計結果抓回來用


// 		這邊示範用 test 語法直接幫你做係數的假設檢定
// 		不過由於test也適用於多變數回歸，屆時的檢定都是用 F-statistic
// 		因此這裡內建也是用 F，而非 t
// 		如果要得到 t，統計告訴你他會是根號的 F-statistic
// 		不過方向就不得而知，因為雙尾檢定不管正負

local companies_b = "ford ge xom"
foreach c of local companies_b {
	di "est_`c' 之假設檢定"
	quietly{
	estimates restore est_`c'
	test prem_mkt = 1
	}
	di "T-stat	:" sqrt(r(F))
	
	
	di "p-Value :" r(p)
	di " "
}

/*
		中規中矩的算法，以Ford為例
*/

estimates restore est_ford

scalar tstat_b = ( _b[prem_mkt] - 1 )/_se[prem_mkt]
di "T-stat	: "  tstat_b
di "p-value for Two-tail test	:" 2 * ttail(num, tstat_b)


    				//======================//
    				//						//
    				//			(c)			//
    				//						//
    				//======================//
    				//	H0 : beta ≥ 1 for Exxon 

/*
		單尾就需要一些計算了，stata 不能直接算出來
		此時對立假設為 Ha : beta < 1，
		屬於左尾檢定
		標準化得到
*/
estimates restore est_xom
scalar tstat_c = (_b[prem_mkt] - 1)/_se[prem_mkt]
di tstat_c

di "p-value for Left-tail test :	 " 1 - ttail(num, tstat_c )

/*
		p-value 幾乎為 0 ，也就是說我們拒絕虛無假設
		解讀為：我們認為如果虛無假設是對的，
		出現現在這個值的機率實在太小，
		所以決定拒絕相信 H0
*/

    				//======================//
    				//						//
    				//			(d)			//
    				//						//
    				//======================//
    				//	H0 : beta ≤ 1 for Microsoft 

/*
		此時對立假設 Ha : beat > 1
		屬於右尾檢定
		與之前作法相同，但不需要 1 - 
*/
					
estimates restore est_ms
scalar tstat_c = (_b[prem_mkt] - 1)/_se[prem_mkt]
di tstat_c

di "p-value for Right-tail test :	 " ttail(num, tstat_c )

/*
		雖然 0.5011很接近0.5，但是我們不可以滑坡
		這個情況下，我們無法（在 95%信心水準下）拒絕虛無假設
		也就是說，我們接受beta有可能是 ≤ 1
		儘管估計出來 1.2
		我們選擇相信是誤差造成（因為不足以拒絕）
		
		解讀 p-value 的邏輯請小心
*/

    				//======================//
    				//						//
    				//			(e)			//
    				//						//
    				//======================//
    				//	H0 : cons = 0 for Ford, GE, Exxon 

local companies_e = "ford ge xom"
foreach c of local companies_e {
	di "est_`c' 之假設檢定"
	quietly{
	estimates restore est_`c'
	test _cons 
	}
	di "T-stat		:" sqrt(r(F))
	
	di "p-Value 	:" r(p)
	di " "
}


