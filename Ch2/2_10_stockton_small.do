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
use stockton5_small

replace sprice = sprice/1000


//=========== Linear Regression============
reg sprice age
estimate store lin_fit
predict yhat_linear, xb

margin, at(age=30)
di _b[_cons] + 30 * _b[age]

// plot
twoway (scatter sprice age, msize(vsmall)) (line yhat_linear age, sort), name(lin_fit)

//============ Before fitting log ==========
/*
從散佈圖中可以看到，價格（y軸）變化很大。
我們可以看看它的分布
*/
histogram sprice
codebook sprice

// 當分佈為右偏的時候，適合取對數看看
gen ln_sprice = log(sprice)
histogram ln_sprice
//看起來正常多了

//============ Log-linear regression ========
reg ln_sprice age
estimate store ln_fit
predict yhat_ln, xb
gen yhat_ln_exp = exp(yhat_ln)

twoway (scatter sprice age, msize(vsmall)) (line yhat_ln_exp age, sort), name(ln_fit)

twoway (scatter sprice age, msize(vsmall)) (line yhat_ln_exp age, sort) (line yhat_linear age, sort), name(combined_fit)

// 預測平均而言屋齡30老房的價格
// 由於前面估計的是 ln_sprice，如果要得到 sprice，需要放指數
// 寫下 expression，裡面指定要 exp( xb() )，表示要把預估結果做指數變換
margin, at(age=30) expression(	exp( xb() )	)
// 你也可以把實際值（還記得前面除上 1000 了嗎）展示出來
margin, at(age=30) expression(	exp( xb() ) * 1000 )


//====== Compare SSE =======
estimate restore lin_fit
di "SSE for Linear Regression: " e(rss)

estimate restore ln_fit
di "SSE for Log-Linear Regression: " e(rss)
