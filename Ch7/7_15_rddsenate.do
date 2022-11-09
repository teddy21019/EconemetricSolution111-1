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
graph export "7_15_a.png"					
					
    				//======================//
    				//						//
    				//			(b)			//
    				//						//
    				//======================//

eststo est_b : reg vote c.margin##i.d
twoway (function y=_b[c.margin]*margin + _b[i.d]*sign(margin) +)

    				//======================//
    				//						//
    				//			(c)			//
    				//						//
    				//======================//
    


    				//======================//
    				//						//
    				//			(d)			//
    				//						//
    				//======================//
    


    				//======================//
    				//						//
    				//			(e)			//
    				//						//
    				//======================//
    


    				//======================//
    				//						//
    				//			(f)			//
    				//						//
    				//======================//
    
	
	
	    			//======================//
    				//						//
    				//			(g)			//
    				//						//
    				//======================//