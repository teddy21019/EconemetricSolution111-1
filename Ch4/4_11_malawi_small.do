clear
graph drop _all
eststo clear

//cd "C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch4\Results"
//use "C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\DATA\malawi_small"

//
 cd "/Users/abc/Desktop/111-1/東海計量/Solution/Ch4/Results"
 use "/Users/abc/Desktop/111-1/東海計量/Solution/DATA/malawi_small"


    				//======================//
    				//						//
    				//			(a)			//
    				//						//
    				//======================//
    				//	國小地理報告 

					
di "自己查"


    				//======================//
    				//						//
    				//			(b)			//
    				//						//
    				//======================//
    				//	觀察食物比例 vs 總花費 
					
scatter pfood totexp, name(simple_scatter, replace)
graph export "Q4_11_simple_scatter.eps", name(simple_scatter) replace

hist totexp, name(hist_of_totexp, replace)
graph export "Q4_11_hist_of_totexp.eps", name(hist_of_totexp) replace
gen ln_totexp = log(totexp)

hist ln_totexp, name(hist_of_ln_totexp, replace)

graph combine hist_of_totexp hist_of_ln_totexp, col(1)
graph export "Q4_11_compare_totexp.eps", replace

		//===================
		//		(1)		報告回歸結果

eststo est_b: reg pfood ln_totexp

		/*===================
		//		(2)		解釋係數
		//	
		//		beta < 0，表示隨著總支出增加，花費在食物的比例下降
		//		注意，並不一定花費在食物上的金額比較小！
		*/
		
		/*===================
		//		(3)		區間估計	
		*/	

// 用 ci 來指定要看信心水準下的區間估計
esttab, ci
		

    				//======================//
    				//						//
    				//			(c)			//
    				//						//
    				//======================//
    				//	食品支出相對總支出的彈性 

// 計算彈性的公式很長，因此寫成一個函數(stata裡叫做program) 可以讓程式碼更精簡

// 試著清除已經有這個名稱的program，因為stata不能重複pragram的名稱
capture program drop elas

// program 函數名稱
program elas
	// 傳入參數，設計第一個是總消費額度，第二個是根據哪一次回歸的結果。前面的回歸記得存記憶體
	args total_ex est_name
	
	// 把回歸結果叫回來
	qui estimates restore `est_name'	
	
	//相較於 lincom， nlcom 可以處理非線性組合的參數估計
	nlcom Elasticity: (_b[_cons] + _b[ln_totexp]*(log(`total_ex') +1) ) ///
		 /(_b[_cons] + _b[ln_totexp]*log(`total_ex') )	///
		 , noheader
		 
	// nlcom 回傳的結果為透過 Delta method 建立的區間估計
	// 這時會假設樣本數很大，趨近無窮多
end


// 取得7, 75 百分位數的值，並且存起來
quietly sum totexp, detail
scalar total_ex_p5 = r(p5)
scalar total_ex_p50 = r(p50)
scalar total_ex_p75 = r(p75)

// 呼叫我們剛剛寫的函數 program
elas total_ex_p5 est_b
elas total_ex_p75 est_b


    				//======================//
    				//						//
    				//			(d)			//
    				//						//
    				//======================//
    				//	殘差觀察 
					
		//===================
		//		(1)		繪製殘差

estimates restore est_b
predict res_b, residual

// name(。) 表示幫做圖命名
histogram res_b, name("Q4_11_hist_1", replace)
twoway (scatter res_b ln_totexp ), name("Q4_11_scatter_1", replace)

// 會出成新檔案 Q4_11_hist_1.eps，使用的做圖為之前存的 Q4_11_hist_1，如果已經存在就替代
graph export "Q4_11_hist_1.eps", name("Q4_11_hist_1") replace
graph export "Q4_11_scatter_1.eps", name("Q4_11_scatter_1") replace

		/*===================
		//		(2)		模型預估殘差的峰度與偏度
		//	
		//		可以用 sum, detail 來取得
		*/

quietly sum res_b, detail
di "Kurtosis	: " r(kurtosis)
di "Skewness	: " r(skewness)
/*
		也可以直接用 sktest 來檢定
*/
sktest res_b

		/*===================
		//		(3)		J-B test
		//	
		//		JB 檢定的虛無假設是 偏度 = 0
		//							峰度 = 3
		//		他是將兩者某程度上標準化之後，進行平方和，
		//		因此為 Chi2(2) 分布
		*/

// 先來看看 1% 的 Chi2(2) 臨界值在哪裡
di "Chi2(2) critical value for 1% level :" invchi2tail(2, 0.01)
// 接著進行 Jarque-Bera 檢定

										//  !!!!!  注意！ 	==============
										//	jb 並非內建指令
										// 	要打 ssc install jb 安裝
jb res_b

/*
		出來結果為  25.19，遠大於1%時的臨界值 9.21
		因此我們拒絕虛無假設，認定此殘差向不符合常態分佈
*/


    				//======================//
    				//						//
    				//			(e)			//
    				//						//
    				//======================//
    				//	估計log-log 回歸 

gen food=totexp*pfood
gen ln_food = log(food)

eststo est_e: reg ln_food ln_totexp

/*
		根據彈性的定義 d ln(food)/d ln(totexp) ，
		此回歸估計出來的斜率就是彈性，而且會固定
*/


    				//======================//
    				//						//
    				//			(f)			//
    				//						//
    				//======================//
    				//	繪製殘差 part2 
					
					
estimates restore est_e
predict res_e, residual

histogram res_e, name("Q4_11_hist_2", replace)
twoway (scatter res_e ln_totexp ), name("Q4_11_scatter_2", replace)

graph export "Q4_11_hist_2.eps", name("Q4_11_hist_2") replace
graph export "Q4_11_scatter_2.eps", name("Q4_11_scatter_2") replace


quietly sum res_b, detail
di "Kurtosis	: " r(kurtosis)
di "Skewness	: " r(skewness)

sktest res_e

jb res_e

/*
		出來結果為  298.2 ，比上一個離譜
		因此我們拒絕虛無假設，認定此殘差向不符合常態分佈
*/



    				//======================//
    				//						//
    				//			(g)			//
    				//						//
    				//======================//
    				//	FOOD~log_TOTEXP 回歸 

eststo est_g: reg food ln_totexp		

capture program drop elas_g
program elas_g
	args total_ex est_name
	qui estimates restore `est_name'	
	nlcom Elasticity: _b[ln_totexp] ///
		 / (_b[_cons] + _b[ln_totexp]*log(`total_ex') )	///
		 , noheader
end

elas_g total_ex_p50 est_g
elas_g total_ex_p75 est_g



    				//======================//
    				//						//
    				//			(h)			//
    				//						//
    				//======================//
    				//	繪製殘差 part3 
					
					
estimates restore est_g
predict res_h, residual

histogram res_h, name("Q4_11_hist_3", replace)
graph export "Q4_11_hist_3.eps", name(Q4_11_hist_3) replace

twoway (scatter res_h ln_totexp ), name("Q4_11_scatter_3", replace)
graph export "Q4_11_scatter_3.eps", name("Q4_11_scatter_3") replace

quietly sum res_h, detail
di "Kurtosis	: " r(kurtosis)
di "Skewness	: " r(skewness)

sktest res_h

jb res_h



    				//======================//
    				//						//
    				//			(i)			//
    				//						//
    				//======================//
    				//	模型選擇 


/*
		首先我們為每一個模型建立預測值
*/
quietly{
estimates restore est_b
predictnl pred_b = totexp * xb()

estimates restore est_e
predictnl pred_e = exp(xb())

estimates restore est_g
predict pred_g, xb
}		

qui cor food pred_b pred_e pred_g
matlist r(C)
					
/*
	單純看相關性的話，第一個模型 (食物支出比例 ~ ln 總支出)的相關性最高
	因此為比較適合的選擇
*/
esttab, mti r2 ar2 aic bic noobs
