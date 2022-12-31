clear
eststo clear
graph drop _all

global chapter_dir="C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch15"
// global chapter_dir="/Users/abc/Desktop/111-1/東海計量/Solution/Ch15"


cd "$chapter_dir/Results"

use http://www.stata.com/data/s4poe5/data/star



    				//======================//
    				//						//
    				//			(a)			//
    				//						//
    				//======================//
					//		OLS
eststo est_a_ols : reg readscore small aide tchexper tchmasters boy white_asian freelunch


    				//======================//
    				//						//
    				//			(b)			//
    				//						//
    				//======================//
					//		OLS ，群聚穩健標準差
eststo est_b_ols_r : ///
		reg readscore small aide tchexper tchmasters boy white_asian freelunch, vce(cluster tchid )


/*
	比較結果
*/
esttab, mti se
		
    				//======================//
    				//						//
    				//			(c)			//
    				//						//
    				//======================//
					//		RE

xtset tchid

eststo est_c_re : xtreg readscore small aide tchexper tchmasters boy white_asian freelunch, re

    				//======================//
    				//						//
    				//		bonus			//
    				//						//
    				//======================//
					//		FE
					

eststo est_c_fe : xtreg readscore small aide tchexper tchmasters boy white_asian freelunch, fe

/*
	思考： 為什麼會有0？
*/

esttab, mti se