// 助教：陳家威
// r10323045@ntu.edu.tw

// 把上一次執行的先通通清除，重新開始
clear 
graph drop _all


// 首先，告訴Stata你現在要在哪一個資料夾裡面操作，並且移(change directory, cd)進去
// 請改成自己的路徑！！
cd "/Users/abc/Desktop/111-1/東海計量/Solution/Ch2/Results"

// 指定資料的位置
use "/Users/abc/Desktop/111-1/東海計量/助教/datafiles/cex5_small"

    				//======================//
    				//						//
    				//			(a)			//
    				//						//
    				//======================//
    
    				//	觀察數據

histogram foodaway, saving("Q2_13_fig1", replace)
sum foodaway , detail

    				//======================//
    				//						//
    				//			(b)			//
    				//						//
    				//======================//
    
    				//	分組觀察統計量
					
// quietly 可以不把結果印出來，只放記憶體中
// 一定要 detail 才會把分位數做出來
quietly sum foodaway if advanced == 1, detail
di "Mean of foodaway for adanced education: 	" r(mean)
di "Median of foodaway for adanced education: 	" r(p50)

quietly sum foodaway if college == 1, detail
di "Mean of foodaway for college education: 	" r(mean)
di "Median of foodaway for college education: 	" r(p50)

quietly sum foodaway if college == 0 & advanced ==0, detail
di "Mean of foodaway for lower education: 		" r(mean)
di "Median of foodaway for lower education: 	" r(p50)

    				//======================//
    				//						//
    				//			(c)			//
    				//						//
    				//======================//
    
    				//	變數對數化
// 建立對數化的數值
gen ln_foodaway = log(foodaway)
label var ln_foodaway "Log of foodaway"
histogram ln_foodaway, saving("Q2_13_fig2", replace)

quietly sum foodaway
di "N:					"r(N)

quietly sum ln_foodaway
di "N after log:		"r(N)
quietly count if foodaway == 0
di "Foodaway is zero	"r(N)

    				//======================//
    				//						//
    				//			(d)			//
    				//						//
    				//======================//
    
    				//	對數後 OLS
//========== Log linear regression ==============
reg ln_foodaway income
predict yhat_ln, xb

    				//======================//
    				//						//
    				//			(e)			//
    				//						//
    				//======================//
    
    				//	OLS 作圖
twoway (scatter ln_foodaway income, msize(vsmall)) (line yhat_ln income, sort) ///
		, saving("Q2_13_fig3", replace)

    				//======================//
    				//						//
    				//			(f)			//
    				//						//
    				//======================//
    
    				//	觀察殘差
predict res_ln, residual

twoway (scatter res_ln income), saving("Q2_13_fig4", replace)



