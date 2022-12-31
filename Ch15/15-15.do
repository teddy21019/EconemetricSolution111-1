clear
eststo clear
graph drop _all

global chapter_dir="C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch15"
// global chapter_dir="/Users/abc/Desktop/111-1/東海計量/Solution/Ch15"


cd "$chapter_dir/Results"

use http://www.stata.com/data/s4poe5/data/chemical3


    				//======================//
    				//						//
    				//			(0)			//
    				//						//
    				//======================//
    				//	宣告為面板數據 
xtset firm year

    				//======================//
    				//						//
    				//			(a)			//
    				//						//
    				//======================//
    				//	OLS 與不同標準誤差 

	
// 一般 OLS
eststo est_a_ols : reg lsales lcapital llabor lmaterials
// 穩健標準差的OLS
eststo est_a_r : reg lsales lcapital llabor lmaterials, r
// 群聚穩健標差的OLS
eststo est_a_clus : reg lsales lcapital llabor lmaterials, vce(cluster firm)

esttab, mti se r2 ar2

// 觀察不同情況下的彈性
esttab, mti ci keep(lmaterials)
/*
	因為都是取對數，所以係數即彈性
*/



    				//======================//
    				//						//
    				//			(b)			//
    				//						//
    				//======================//
    				//	檢定固定規模報酬 

/*
	如果假設為 Cobb-Douglas 生產函數
	Y = A K^a * L^b * M^c 
	若為固定生產報酬，表示每一個要素加倍，產出也加倍
	(?Y) = A (nK)^a * (nL)^b * (nM)^c 
	如果 a + b + c = 1 ，則剛好 ? = n 
	此時稱作固定規模報酬。
	
	將 Cobb-Douglas 生產函數取對數，其中的 a b c 就對應到我們 OLS 中估計的係數
	因此要測試固定規模報酬，相當於進行係數加起來 = 1 的檢定
*/


global ols_list est_a_ols est_a_r est_a_clus

// 用 for 迴圈來對每一種標準差之下的回歸進行檢定
foreach m of global ols_list{
	est restore `m'
	test lcapital+llabor+lmaterials = 1		// 得到 F 檢定
	lincom lcapital+llabor+lmaterials-1		// 另一種做法，得到 t 檢定
}

    				//======================//
    				//						//
    				//			(c)			//
    				//						//
    				//======================//
    				//	OLS 中的序列相關 

// 非課程內容


est restore est_a_ols
predict res_ols, res

reg res_ols L.res_ols, noconst
di e(N)*e(r2)

/*
	拒絕了沒有相關性的虛無假設，所以選擇接受有相關性
*/


    				//======================//
    				//						//
    				//			(d)			//
    				//						//
    				//======================//
    				//	隨機效果 RE 



// 隨機效果
eststo est_d_re : xtreg lsales lcapital llabor lmaterials, re

// 檢測CRTS
test lcapital+llabor+lmaterials=1

// LM test 檢定隨機效果
xttest0
/*
	拒絕虛無假設H0: sigma_ui=0，所以認為的確有隨機效果的必要
*/


    				//======================//
    				//						//
    				//			(e)			//
    				//						//
    				//======================//
    				//	固定效果 FE 與 Hausman test


eststo est_e_fe : xtreg lsales lcapital llabor lmaterials, fe

// 比較固定效果與隨機效果的估計
esttab *fe *re, mti se

/*
	Hausman test 幫我們決定要用 fixed effect 還是 random effect
	
	情境一（H0）；兩個的係數不顯著有差異 -- 
	用 RE ，因為這樣的估計更有效 (more efficient)
	
	情境二（H1）：兩者係數顯著有差異 -- 
	用 FE，因為只有考慮不同群組的不同差異，才會是一致的(consistant)
*/
hausman est_e_fe est_d_re
/*
	拒絕虛無假設，所以認為兩者參數有差異。這時應該用 FE 來避免不一致(inconsistant)的估計
*/


    				//======================//
    				//						//
    				//			(f)			//
    				//						//
    				//======================//
    				//	FE 殘差項的自相關 
					
// 非課程內容

 
est restore est_e_fe
predict res_fe, res 

reg res_fe L.res_fe, noconst vce(cluster firm)


    				//======================//
    				//						//
    				//			(g)			//
    				//						//
    				//======================//
    				//	FE + 群聚穩健標準差 
					
/*
	FE 是考慮「不同」群聚之間，可能有不同的截距
	而此時如果考慮到不同群聚之間，誤差項的分布也可能有差異時
	就可以另外指定群聚穩健標準誤差
*/

eststo est_e_fe_cl : xtreg lsales lcapital llabor lmaterials, fe vce(cluster firm)

esttab *fe* , mti se

test lcapital+llabor+lmaterials=1