clear

cd "C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch5\Results"
use "C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\DATA\cocaine"


    				//======================//
    				//						//
    				//			(a)			//
    				//						//
    				//======================//
    				//	預期係數 




    				//======================//
    				//						//
    				//			(b)			//
    				//						//
    				//======================//
    				//	回歸結果 


eststo est_b : reg price quant qual trend


    				//======================//
    				//						//
    				//			(c)			//
    				//						//
    				//======================//
    				//	變異數解釋 


/*
	其實就是問 R平方
*/

di e(r2)


    				//======================//
    				//						//
    				//			(d)			//
    				//						//
    				//======================//
    				//	檢定數量係數 



/*
	想要檢定：數量越大，價格越低。換句話說想檢定 quant 這一項係數 < 0
	我們定義虛無假設為 H0 : beta_quant >= 0
					   H1 : beta_quant < 0
*/

scalar tstat = _b[quant]/_se[quant]

scalar critical_value = invt(e(N), 0.05)

if (tstat < critical_value){
	di "Reject"
}
else{
	di "No reject"
}


    				//======================//
    				//						//
    				//			(e)			//
    				//						//
    				//======================//
    				//	檢定品質係數 



/*
	H0 : beta_quant >= 0
	H1 : beta_quant < 0
*/

scalar tstat = _b[qual]/_se[qual]

scalar critical_value = invt(e(N), 0.05)

if (tstat < critical_value){
	di "Reject"
}
else{
	di "No reject"
}


    				//======================//
    				//						//
    				//			(f)			//
    				//						//
    				//======================//
    				//	解釋趨勢 

/*
	每年變動看的是 trend 的係數
	係數為負表示價格越來越低
	可能因為技術進步，或是供需失衡...
*/

di _b[trend]