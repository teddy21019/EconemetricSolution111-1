clear
eststo clear
graph drop _all

global chapter_dir="C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch7"
// global chapter_dir="/Users/abc/Desktop/111-1/東海計量/Solution/CH7"


cd "$chapter_dir/Results"

use http://www.stata.com/data/s4poe5/data/bweight_small


// 資料已經幫你建立好了，這邊提供一個簡易建立的方式
// gen msmoke=0
// replace msmoke=1 if mbsmoke>=1 and mbsmoke<=5
// replace msmoke=2 if mbsmoke>=6 and mbsmoke<=10
// replace msmoke=3 if mbsmoke>=11



    				//======================//
    				//						//
    				//			(a)			//
    				//						//
    				//======================//
    
eststo est_a : reg bweight mmarried mage prenatal1 fbaby msmoke

/*	#################### 注意！#####################

		msmoke 的係數大小本身沒有意義，因為他是一個 level
		就好像填問卷時，喜好指數 4 跟 5 這兩個數字本身沒有太大意義，
		只是代表一個相對程度而已
		
		但是方向卻還是有意義，表示控制住其他變因，有抽菸的母親，小孩會比較輕
	################################################
*/


    				//======================//
    				//						//
    				//			(b)			//
    				//						//
    				//======================//
					
/*
		如果加上 i.xxxx ，Stata就會認定他的數字只是類別(nominal variable)，而非大小
*/
    
eststo est_b : reg bweight mmarried mage prenatal1 fbaby i.msmoke

/*	#################### 注意！#####################
		
		Stata 會將 msmoke=1,2,3 分別變成三個變數，但是不會出現 0
		事實上，是「不能出現」！否則會出現完全線性重合問題。
		
		直觀來說，smoke1, smoke2, smoke3 分別代表了相對於 msmoke=0 的那些嬰兒來說
		多出了多少體重。
		
		smoke1 的係數為  -181.6* ，表示在 5% 顯著水準之下，抽 1~5根菸是會降低出生體重的。
	################################################
*/

    				//======================//
    				//						//
    				//			(c)			//
    				//						//
    				//======================//
/*
		如果每天抽 11 以上的嬰兒體重減少量 (smoke3的係數) 不超過
		每天抽 6~10 的嬰兒體重減少量 (smoke2的係數) ，表示
		
		H0 : beta_smoke2 =  beta_smoke3 (語法上是 2.msmoke = 3.msmoke)
		HA : beta_smoke2 >  beta_smoke3   (2.msmoke - 3.msmoke)
		
		先來做一個雙尾檢定看看
*/

// 雙尾檢定
est restore est_b 
test 2.msmoke=3.msmoke

// 從雙尾反推單尾
scalar t_value_from_two_tail = sqrt(r(F)) * sign(_b[2.msmoke] - _b[3.msmoke])
di "T 檢定量為 ：" t_value_from_two_tail
di "Critical value : " invttail(dof, 0.05)

// 自行計算單尾檢定
scalar dof = e(df_r)	// 自由度 = 1200 - 8 
mat cov_matrix = e(V)	// 係數之間的共變異數矩陣
mat cov_23_matrix = e(V)["2.msmoke", "3.msmoke"]	// 取出這兩係數間的cov
scalar cov_23 = el(cov_23_matrix,1,1)				// 矩陣 -> 常數

scalar T_value_c = (_b[2.msmoke] - _b[3.msmoke]) / ///
		sqrt(_se[3.msmoke]^2 + _se[2.msmoke]^2 -2*  cov_23 )

di "T 檢定量為 ：" T_value_c

/*
		無法拒絕虛無假設，所以兩係數並不統計顯著地有差異
*/

    				//======================//
    				//						//
    				//			(d)			//
    				//						//
    				//======================//
est restore est_b 
test 1.msmoke=3.msmoke

// 從雙尾反推單尾
scalar t_value_from_two_tail = sqrt(r(F)) * sign(_b[1.msmoke] - _b[3.msmoke])
di "T 檢定量為 ：" t_value_from_two_tail
di "Critical value : " invttail(dof, 0.05)  

/*
		無法拒絕虛無假設，所以兩係數並不統計顯著地有差異
*/

    				//======================//
    				//						//
    				//			(e)			//
    				//						//
    				//======================//
					
eststo clear
// 利用 bysort，可以將樣本分群，並執行後面的指令
// 所以等於將 msmoke=0123的子樣本，分別做一次回歸
bysort msmoke : eststo : reg bweight mmarried mage prenatal1 fbaby
esttab, mti se

// 將上面回歸叫回（注意，預設eststo命名為 est1, est2, ...）
// 透過 foreach + numlist 對 1~4 的回歸計算 margins
foreach n of numlist 1/4{
	est restore est`n'
	
	// 沒有 dydx 的 margins 為進行預測值
	margins, at(mmarried=1 mage=25 prenatal1=1 fbaby=0)

}

    				//======================//
    				//						//
    				//			(f)			//
    				//						//
    				//======================//
reg lbweight mmarried mage prenatal1 fbaby msmoke

// msmoke=(.) 中間放範圍，範圍語法為 初始(間隔)結束
// 所以 (0(1)3)=(0 1 2 3)
margins, at(msmoke=(0(1)3) mmarried=1 mage=25 prenatal1=1 fbaby=0)

/*
		我們觀察吸菸頻率越多，出生嬰兒為低體重的機率較大
*/
    