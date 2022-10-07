clear 

cd "C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch5\Results"
use "C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\DATA\london5"




    				//======================//
    				//						//
    				//			(a)			//
    				//						//
    				//======================//
    				//	證明題 



    				//======================//
    				//						//
    				//			(b)			//
    				//						//
    				//======================//
    				//	回歸 




// 建立 log(totexp)
gen ln_totexp = ln(totexp)

// 回歸並儲存結果
eststo est_b : reg wfood ln_totexp



    				//======================//
    				//						//
    				//			(c)			//
    				//						//
    				//======================//
    				//	於50 90 170 時平均的區間估計 



foreach i of num 50 90 170{
	// 先算出 log 的值，併存起來
	scalar lg = log(`i')
	
	//用 lincom 做線性轉換的估計
	lincom _b[_cons] + _b[ln_totexp] * lg
}


    				//======================//
    				//						//
    				//			(d)			//
    				//						//
    				//======================//
    				//	於50 90 170 時彈性的區間估計 


foreach i of num 50 90 170{
	scalar lg = log(`i')
	
	//這時要用 nlcom 來處理非線性的組合，並用 delta function 估計變異數
	nlcom 1 + _b[ln_totexp] / (_b[_cons] + _b[ln_totexp] * lg)
}

