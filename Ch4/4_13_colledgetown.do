clear
graph drop _all
eststo clear

//cd "C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch4\Results"
//use "C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\DATA\collegetown"

//
cd "/Users/abc/Desktop/111-1/東海計量/Solution/Ch3/Results"
use "/Users/abc/Desktop/111-1/東海計量/Solution/DATA/collegetown"

/*
			這次作業我用比較不一樣的架構
			我會先把所有的回歸都先做出來，並為他們命名儲存

*/

    				//======================//
    				//						//
    				//		(a, b, c)		//
    				//						//
    				//======================//
    				//		彙整三小題之報告
					//		省略斜率與彈性的計算


gen ln_price = log(price)
gen ln_sqft = log(sqft)

// 先做完全部的回歸，一樣用 eststo 模型名稱, title(模型標題) : 模型指令
eststo log_lin, title("Log-Linear Model") : reg ln_price sqft
eststo log_log, title("Log-Log Model") : reg ln_price ln_sqft
eststo lin_lin, title("Linear Model") : reg price sqft

// 另外加入 root mean square error
estadd scalar RMSE=e(rmse):*

// 回報結果
esttab, mti stats(r2 rmse)

    				//======================//
    				//						//
    				//			(d)			//
    				//						//
    				//======================//
    				//		Jarque-Bera 檢定

					
// 因為每個模型要做的事情一樣，所以這邊示範用 foreach 來跑回圈
// 先用 global 儲存各個模型的名稱
global ests="log_lin log_log lin_lin"

// 對於每一個 ests 這個清單內的模型，叫他 m 
foreach m of global ests{
	quietly{
		estimates restore `m'			// 把模型叫回來
		capture drop res_`m'			// 清空殘差欄
		predict res_`m', residual		// 指定殘差
	}
	di e(estimates_title)
	jb res_`m'			// 跑殘差的 JB test
	di ""
	
}

    				//======================//
    				//						//
    				//			(d, e)		//
    				//						//
    				//======================//
    				//		繪製殘差項

// 我將繪製的步驟也放一起跑			
foreach m of global ests{
	quietly{
		estimates restore `m'	// 把模型叫回來
		local model_name = e(estimates_title)	// 儲存現在這個模型的名稱
	}
	
	// 建立直方圖
	hist res_`m', /// 
		title("Residual Histogram : `model_name'") name("Q4_13_hist_`m'", replace) saving("Q4_13_hist_`m'", replace)
	
	// 建立散佈圖
	scatter res_`m' sqft, ///
		title("Residual Scatter : `model_name'") name("Q4_13_scatter_`m'", replace) saving("Q4_13_scatter_`m'", replace)
}
				/*	|-- STATA 中使用變數的方法 --|
					|
					|	無論是前面用 m 記錄模型，還是用 local 儲存模型名稱
					|	都可以在stata任何地方用 ` ' 這兩個引號包起來
					|	STATA會自動替換成變數代表的文字值
				*/

    				//======================//
    				//						//
    				//			(f, g)		//
    				//						//
    				//======================//
    				//		預測估計與預測區間估計
					
					
/*
		有別於之前估計了「期望值」的點估計，以及「期望值」的區間估計
		如果要考慮「預測值」，則不能不考慮到誤差項造成的變異
		因此不能用 CH2 的 lincom, nlcom, margins 等等作法直接得到
*/

			/*========================
			//		Log-Linear 回歸的預測點估計
			//
			//		我們的被解釋變數 log(price) 在目前假設之下，
			//		會呈現常態分佈(因為誤差假設為常態分佈)
			//		所以實際上 price 是服從「對數常態」分佈 Log-normal distribution
			//		此時給定 SQFT 的期望值會需要一個修正項，與誤差向的變異數有關
			*/
			
			//----------點估計
			

estimates restore log_lin
di e(estimates_title)

// 修正項
scalar correction=exp(e(rmse)^2/2)
// 「天真」的預測
scalar natural_prediction = exp(_b[_cons] + 27*_b[sqft]) * 1000
// 考慮真實分佈後的預測，要乘上修正項
scalar correct_prediction = exp(_b[_cons] + 27*_b[sqft]) * correction * 1000

di "模型：" e(estimates_title) " 在stdf = 27 時，預測的點估計"
di "直觀預測(Natural Prediction)		: "natural_prediction
di "正確預測(Correct Prediction)		: "correct_prediction


			//---------區間估計
			// 詳見課本


// 
quietly{
margins, at(sqft=27)                            // 模型估計的 log(price)，給定 sqft=27
scalar hat = el(r(b), 1, 1)						// 取出來存在 hat

margins, at(sqft=27) predict(stdf) nose force	// 此模型下的 stdf，用來計算區間估計
scalar stdf = el(r(b), 1, 1)					// 存起來
}
di "模型：" e(estimates_title) " 在stdf = 27 時，預測的區間估計"
di "(" exp(hat - tc*stdf)*1000 ", " exp(hat + tc*stdf)*1000 ")"

			/*========================
			//		Log-Log 回歸的預測點估計
			//
			//		看似跟 Log-Linear 的狀況不一樣，但是既然做 OLS，
			//		就已經假設了誤差像成常態分佈，所以此時的被解釋變數 log(price)
			//		依然是常態分佈，因此 price 還是一樣是對數常態分佈
			//		計算預測點估計與預測的區間估計的作法與上面一樣
			//		不同在於，估計時要用 log(sqft)，而非 sqft
			*/
			
			//----------點估計
			

estimates restore log_log
di e(estimates_title)
scalar correction=exp(e(rmse)^2/2)


scalar natural_prediction = exp(_b[_cons] + log(27)*_b[ln_sqft]) * 1000
// 考慮真實分佈後的預測，要乘上修正項
scalar correct_prediction = exp(_b[_cons] + log(27)*_b[ln_sqft]) * correction * 1000
di "模型：" e(estimates_title) " 在stdf = 27 時，預測的點估計"
di "直觀預測(Natural Prediction)		: "natural_prediction
di "正確預測(Correct Prediction)		: "correct_prediction


			//---------區間估計
			// 詳見課本


// 不知道為什麼在 margins 裡面，不能計算 log(27)，所以我先在外面計算
local log27 = log(27)

quietly{
margins, at(ln_sqft = `log27')                  // 模型估計的 log(price)，給定 ln_sqft=log(27)
scalar hat = el(r(b), 1, 1)						// 取出來存在 hat

margins, at(ln_sqft = `log27') predict(stdf) nose force			// 此模型下的 stdf，用來計算區間估計
scalar stdf = el(r(b), 1, 1)					// 存起來
}
di "模型：" e(estimates_title) " 在stdf = 27 時，預測的區間估計"
di "(" exp(hat - tc*stdf)*1000 ", " exp(hat + tc*stdf)*1000 ")"


			/*========================
			//		Lin-Lin 回歸的預測點估計
			//
			//		回到最初的 OLS 模型
			//		此時因為被解釋變數的分佈就是常態分佈
			//		所以不用進行修正
			//		
			//		然而區間估計的部分還是需要 stdf 來修正
			//		因為還是要考慮誤差項帶來的變異
			*/
			
			//----------點估計


estimate restore lin_lin

quietly{
margins, at(sqft=27)                             // fitted lwage
matrix marg = r(b)                               // stored value
scalar hat = marg[1,1]                           // name it

margins, at(sqft=27) predict(stdf) nose force    // se of forecast
matrix marg = r(b)
scalar stdf = marg[1,1]
}
di "模型：" e(estimates_title) " 在stdf = 27 時，預測的點估計：" hat


di "模型：" e(estimates_title) " 在stdf = 27 時，預測的區間估計"
display "(" (hat - tc*stdf)*1000 ", " (hat + tc*stdf)*1000 ")"

    				//======================//
    				//						//
    				//			(h)			//
    				//						//
    				//======================//
    				//		模型的選擇

/*
		主要還是看誤差向有沒有符合常態分佈，也就要做 OLS 時，對資料的假設
		從此目的來看，log-log 殘差項比較符合常態
		但是 log-linear 的 R^2 比較大
		
		單純就 R^2，其實會是 lin-lin 模型的估計比較好，但是嚴重違反常態分佈的假設

*/
