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
use cps5_small

// 建立 wage 的對數值
gen lwage = log(wage)
label var lwage "Log of wage"

// 在繪製 lwage的直方圖時，可以加上 norm ，stata會 fit 一個最適合的常態分佈
hist lwage, norm
quietly sum lwage, detail
di "Skewness:	"r(skewness)
di "Kurtosis:	"r(kurtosis)
// 常態分佈： skewness = 0, kurtosis = 3

// 也可以用一些內建檢定來判斷是不是符合常態分佈
sktest lwage

//============ Log linear regression ==========
reg lwage educ
est store ln_fit

// 預測 12, 16 年教育程度的薪資影響。注意要加上 expression，因為我們回歸是對 ln(wage)
margin, at(educ=(12,16)) expression(exp(xb()))

margin, dydx(*) at(educ=(12,16)) expression(exp(xb()))

quietly margin, dydx(*) at(educ=(10(1)20)) expression(exp(xb()))
marginsplot

predict yhat_ln, xb
gen yhat_ln_exp = exp(yhat_ln)
label var yhat_ln_exp "Log-linear Regression"

reg wage educ
est store lin_fit
predict yhat, xb
label var yhat "Linear Regression"
twoway (scatter wage educ) (line yhat_ln_exp educ, sort) (line yhat educ, sort) 
// 使用單純線性迴歸容易出現預測薪資小於 0 的情況



capture gen res_ln_exp = (yhat_ln_exp - wage)^2
total res_ln_exp
scalar sse_ln = _b[res_ln_exp]

di "SSE for log-linear regression:		" sse_ln

est restore lin_fit
di "SSE for linear regression:		" e(rss)


