clear
eststo clear
graph drop _all

global chapter_dir="C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch15"
// global chapter_dir="/Users/abc/Desktop/111-1/東海計量/Solution/Ch15"


cd "$chapter_dir/Results"

use http://www.stata.com/data/s4poe5/data/star

// 將資料轉換為 panel data
/*
	注意！Panel Data 不一定要有時間。只要是資料裡面有共同的群組，就可以視為 Panel data 
	
	而將這一個群組的共同性質納入回歸的做法，就叫做 Fixed effect
	如果這個共同性質特別指的是時間，就叫 time fixed effect
*/


/*
	在這個例子中
	並沒有「時間」，只有學校、老師等等群組
	
	可以用 xtset來建立 panel data ，不過不要設定時間的變數
*/


    				//======================//
    				//						//
    				//			(a)			//
    				//						//
    				//======================//
					//		OLS

eststo est_a_ols : reg readscore small aide tchexper boy white_asian freelunch

/*
	請給出詮釋：
	
*/

    				//======================//
    				//						//
    				//			(b)			//
    				//						//
    				//======================//
					//		FE

//現在，指定他為 panel data，透過 xtset 
xtset schid

eststo est_b_FE : xtreg readscore small aide tchexper boy white_asian freelunch, fe

// 比較兩結果
esttab, mti se r2 ar2
/*
	詮釋？
*/


    				//======================//
    				//						//
    				//			(c)			//
    				//						//
    				//======================//
					//		檢定 FE

/*
	如果 FE 沒有差異，那理論上所有分群的係數應該要一樣。
	
	這個聯合檢定的 F值，其實已經出現在 xtreg 的結果最底下了
	
	F test that all u_i=0: F(78, 5681) = 16.70                   Prob > F = 0.0000
	
	可以用 e(F_f) 抓出來（參考 help xtreg）
*/
est restore est_b_FE
di "固定效果聯合檢定：		"  e(F_f)


    				//======================//
    				//						//
    				//			(d)			//
    				//						//
    				//======================//
					//		RE

eststo est_d_RE : xtreg readscore small aide tchexper boy white_asian freelunch, re

/*
	檢測 RE 的做法通常為Breusch and Pagan (1980) 提出的 LM test
	指令非常單純
*/

xttest0
/*
	5%顯著水準之下拒絕虛無假設，表示的確，不同學校之間存在異質性。
*/


    				//======================//
    				//						//
    				//			(e)			//
    				//						//
    				//======================//
					//		Hausman test
					
/*
	Hausman test 幫我們決定要用 fixed effect 還是 random effect
	
	情境一（H0）；兩個的係數不顯著有差異 -- 
	用 RE ，因為這樣的估計更有效 (more efficient)
	
	情境二（H1）：兩者係數顯著有差異 -- 
	用 FE，因為只有考慮不同群組的不同差異，才會是一致的(consistant)
*/

hausman est_b_FE est_d_RE

/*
	Huasman test 的結果為 chi2(6) = 22.62，P-value < 0.05
	
	我們拒絕虛無假設，表示 FE 有使用他的意義，考慮固定效果才會具有一致性。
*/
    
/*
	不過，計量上也是有折衷的模型，叫 Mixed effect model
	他同時考慮 FE 與 RE
	但實證上好像還是都用 FE 比較多。
*/

esttab, mti se r2 ar2