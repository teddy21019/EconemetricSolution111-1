clear
eststo clear
graph drop _all

global chapter_dir="C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch7"
// global chapter_dir="/Users/abc/Desktop/111-1/東海計量/Solution/CH7"


cd "$chapter_dir/Results"

use http://www.stata.com/data/s4poe5/data/rddsenate


    				//======================//
    				//						//
    				//			(a)			//
    				//						//
    				//======================//

scatter vote margin
graph export "7_15_a.png", replace					
					
    				//======================//
    				//						//
    				//			(b)			//
    				//						//
    				//======================//

eststo est_b : reg vote c.margin##i.d
predict yhat_b
label var yhat_b "Predicted vote share for t+1" 

twoway (line yhat_b margin if margin>0) (line yhat_b margin if margin<0), xline(0) legend(lab(1 "D=0") lab(2 "D=1"))
    				//======================//
    				//						//
    				//			(c)			//
    				//						//
    				//======================//
    
mean vote if bin == -2.5
mean vote if bin == 2.5

    				//======================//
    				//						//
    				//			(d)			//
    				//						//
    				//======================//
    
ztest vote if(abs(bin)==2.5), by(d)

    				//======================//
    				//						//
    				//			(e)			//
    				//						//
    				//======================//
    
eststo est_e, title("Pooled") : reg vote d##(c.margin c.margin2 c.margin3 c.margin4)

    				//======================//
    				//						//
    				//			(f)			//
    				//						//
    				//======================//
predict yhat_e
label var yhat_e "Predicted vote share for t+1, higher dimention" 

twoway (line yhat_e margin if margin>0, sort lc(blue)) (line yhat_e margin if margin<0, sort lc(blue)), xline(0) legend(lab(1 "D=0") lab(2 "D=1"))
	
	
	    			//======================//
    				//						//
    				//			(g)			//
    				//						//
    				//======================//
					
eststo est_g_0, title("D=0") : reg vote margin margin2 margin3 margin4 if d == 0				
eststo est_g_1, title("D=1") : reg vote margin margin2 margin3 margin4 if d == 1				

esttab est_e est_g_*, b(3) se drop(0.*) r2 bic rss