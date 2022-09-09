// 助教：陳家威
// r10323045@ntu.edu.tw

// 把上一次執行的先通通清除，重新開始
clear 
graph drop _all

// 首先，告訴Stata你現在要用的資料是在哪一個資料夾裡面，並且移進去
// 請改成自己的
cd "/Users/abc/Desktop/111-1/東海計量/助教/datafiles"

// 因為已經告訴他資料在哪一個資料夾，你可以直接把 ***.dta 的 ***，用 use 抓出來。
// ！！注意：只有檔案是 .dta 可以直接用 use。如果資料是 excel 或是 csv 會需要其他指令。
use cex5_small

histogram foodaway
sum foodaway , detail

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

// 建立對數化的數值
gen ln_foodaway = log(foodaway)
label var ln_foodaway "Log of foodaway"
histogram ln_foodaway

quietly sum foodaway
di "N:					"r(N)

quietly sum ln_foodaway
di "N after log:		"r(N)
quietly count if foodaway == 0
di "Foodaway is zero	"r(N)
//========== Log linear regression ==============
reg ln_foodaway income
predict yhat_ln, xb

twoway (scatter ln_foodaway income, msize(vsmall)) (line yhat_ln income, sort)

predict res_ln, residual

twoway (scatter res_ln income)



