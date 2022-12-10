clear
eststo clear
graph drop _all

global chapter_dir="C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch7"
// global chapter_dir="/Users/abc/Desktop/111-1/東海計量/Solution/CH7"


cd "$chapter_dir/Results"

use http://www.stata.com/data/s4poe5/data/cps5

    				//======================//
    				//						//
    				//			(a)			//
    				//						//
    				//======================//
    				//	UNION 係數 



gen ln_wage=ln(wage)

eststo est_OLS : ///
	reg ln_wage (c.educ c.exper)##c.exper ///
				female black union metro ///
				south midwest west


// test union < 0，但是test只能做雙尾檢定
// 因此要手動作單尾檢定
scalar union_t_value = (_b[union] - 0) / _se[union]

// 因為對立假設為大於0，所以做右尾檢定
scalar p_value_union = ttail(e(df_r), union_t_value)
di "p-value ：		"p_value_union

// p-value 為 1.149e-07，所以拒絕居無假設，並相信 union 的係數為正


    				//======================//
    				//						//
    				//			(b)			//
    				//						//
    				//======================//
    				//	NR2 檢定 



		/****************************
				做法1 ： 土法煉鋼
		*****************************/

predict res_a, res 			// 將殘差像抓出來
gen res_a2=res_a^2 			// 建立平方

eststo het_nr2 : reg res_a2 union metro 		// 殘差向的平方對在意的變數進行回歸
scalar nr2=e(N)*e(r2)

// nr2 在大樣本中的漸進分布為chi2(S-1)，其中 S 是上面回歸的自由度(兩個變數 + 常數)，所以在這裡是 chi2(2)


// p-value
di "NR2 value:		" nr2
di "Critical value: " invchi2tail(2, 0.01)
di "P value : 		" chi2tail(2, nr2)


		/****************************
				做法2 ： Stata 內建指令
		*****************************/

est restore est_OLS
estat hettest union metro, iid
	/*			說明
		estat hettest 專門進行異質變異數的檢定
		後面放上希望變異數是什麼的關係
		如果指定為 "iid"，則會表示進行 NR2 檢定
	*/



    				//======================//
    				//						//
    				//			(c)			//
    				//						//
    				//======================//
    				//	不同變異數估計 



gen ln_res_a2 = ln(res_a2)

// 比起 b，多了 educ
eststo het_c : 	  reg res_a2 educ union metro

// 對殘差的對數進行回歸
eststo het_c_ln : reg ln_res_a2 educ union metro

// het* 表示「所有前面是 het，後面隨便」的儲存結果
esttab het*, se r2 order(_cons) ///
	varlabel(_cons "Constant" union "Union" metro "Metro" educ "Education") label

	


    				//======================//
    				//						//
    				//			(d)			//
    				//						//
    				//======================//
    				//	FGLS 

		/****************************
				做法 1 ： Stata 內建指令
		*****************************/
		
eststo est_OLS_R : ///
	reg ln_wage (c.educ c.exper)##c.exper ///
				female black union metro ///
				south midwest west, r
			/*
				原則上可以直接用 c 的結果，進行 FGLS。這邊示範直接用指令
			*/
eststo est_FGLS : ///
	hetregress ln_wage (c.educ c.exper)##c.exper ///
					female black union metro ///
					south midwest west, ///
					twostep het(union metro educ)

			/*
				
			*/		
			

		/****************************
				做法2 ： 手刻 FGLS
		*****************************/

// 殘差的對數對變數的回歸			
est restore het_c_ln
// 建構每一筆資料，誤差項的估計值
// 因為估計的是殘差的對數，所以最後要exp
predict ln_e_hat
gen e_hat=exp(ln_e_hat)	

// FGLS 的概念就是，將每一筆資料除上這筆資料第一階段回歸的殘差估計的根號)
// 或是以第一階段預估殘差的倒數作為加權(weight)
// 兩者意思一樣，只是第一種比較難做

eststo est_FGLS_hand : 	///
	reg ln_wage (c.educ c.exper)##c.exper ///
				female black union metro ///
				south midwest west [aweight=1/e_hat]

// 將所有前面命名為 est的都顯示出來
esttab est*, mti se

