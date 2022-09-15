clear
graph drop _all

cd "C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch3\Results"
use "C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\DATA\capm5"

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
    				//	H0 : Is 1 
eststo est_ford, title("Ford"):		reg prem_ford prem_mkt
eststo est_ge, title("GE"):		reg prem_ge prem_mkt

// 把估計結果抓回來用


// 這邊示範用 test 語法直接幫你做係數的假設檢定
// 不過由於test也適用於多變數回歸，屆時的檢定都是用 F-statistic
// 因此這裡內建也是用 F，而非 t
// 如果要得到 t，統計告訴你他會是根號的 F-statistic
// 不過方向就不得而知

local companies_b = "ford ge xom"
foreach c of local companies_b {
	di "est_`c' 之假設檢定"
	quietly{
	estimates restore est_`c'
	test prem_mkt > 1
	}
	di "T-test	:" sqrt(r(F))
	di "p-Value :" r(p)
	di " "
}

