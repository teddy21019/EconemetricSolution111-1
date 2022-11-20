clear
eststo clear
graph drop _all

global chapter_dir="C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch7"
// global chapter_dir="/Users/abc/Desktop/111-1/東海計量/Solution/CH7"


cd "$chapter_dir/Results"

use http://www.stata.com/data/s4poe5/data/mexican

// a 


eststo est_a : reg lnprice bar street school age rich alcohol attractive 


// b nr2 test


		/****************************
				做法1 ： 土法煉鋼
		*****************************/

predict res_a, res 			// 將殘差像抓出來
gen res_a2=res_a^2 			// 建立平方

eststo het_nr2 : reg res_a2 attractive 		// 殘差向的平方對在意的變數進行回歸
scalar nr2=e(N)*e(r2)

// nr2 在大樣本中的漸進分布為chi2(S-1)，其中 S 是上面回歸的自由度(一個變數 + 常數)，所以在這裡是 chi2(1)


// p-value
di "NR2 value:		" nr2
di "Critical value: " invchi2tail(1, 0.01)
di "P value : 		" chi2tail(1, nr2)


		/****************************
				做法2 ： Stata 內建指令
		*****************************/

est restore est_a
estat hettest attractive, iid
	/*			說明
		estat hettest 專門進行異質變異數的檢定
		後面放上希望變異數是什麼的關係
		如果指定為 "iid"，則會表示進行 NR2 檢定
	*/

	
// c

eststo est_c_att0 : reg lnprice bar street school age rich alcohol if attractive == 0

scalar sigma2_0=e(rss)/e(df_r)
scalar df_0 = e(df_r)



eststo est_c_att1 : reg lnprice bar street school age rich alcohol if attractive == 1

scalar sigma2_1=e(rss)/e(df_r)
scalar df_1 = e(df_r)

scalar gq = sigma2_1/sigma2_0
di "GQ					:" gq

di "L Critical value	:" invF(df_1, df_0, 0.025)
di "R Critical value	:" invFtail(df_1, df_0, 0.025)

di "P value				:" Ftail(df_1, df_0, max(gq, 1/gq) ) * 2

// d 

// chow test
eststo est_d : reg lnprice ( i.bar i.street i.school c.age i.rich i.alcohol )##attractive

// 秀一個操作
// 用 testparm 可以不把所有變數打出來，即可做聯合檢定
// * 表示「所有符合的」
// 係數中， 1.* 表示指標變數，c.*表示連續變數

testparm 1.attractive#1.* 1.attractive#c.*

// 因為 p-value <0.001，我們拒絕虛無假設，並認定兩種族群有不同的係數
/*
	Valid?
*/

// e 
est restore est_d 
estat hettest attractive, iid

// f 
eststo est_f : reg lnprice ( i.bar i.street i.school c.age i.rich i.alcohol )##attractive, r

testparm 1.attractive#1.* 1.attractive#c.*

