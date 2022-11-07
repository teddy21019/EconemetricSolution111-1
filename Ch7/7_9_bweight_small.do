clear
eststo clear
graph drop _all

//global chapter_dir="C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch7"
global chapter_dir="/Users/abc/Desktop/111-1/東海計量/Solution/CH7"


cd "$chapter_dir/Results"

use http://www.stata.com/data/s4poe5/data/bweight_small

//a
ttest bweight, by(mbsmoke)

/*
	5% 顯著水準之下，拒絕虛無假設，因此相信母親有無抽菸的樣本平均的確是有差異的
	注意！這還不能說明抽菸是不是真的「影響」嬰兒體重
*/

//b 
eststo est_b : reg bweight mbsmoke

/* 			是否可視為「平均處理效果 ATE ?」

除非母親吸菸是透過實驗隨機給定的，不然不能詮釋為 ATE

有可能有共同因子影響「吸菸」與「嬰兒健康」，例如住在貧民區等因素

*/

//c 
eststo est_c : reg bweight mmarried mage prenatal1 fbaby

//d 
// 只對有抽菸的跑回歸
eststo est_smoke	: reg bweight mmarried mage prenatal1 fbaby if mbsmoke==1
scalar SSE_smoke=e(rss)	//抓出 SSE

// 只對沒抽煙的跑回歸
eststo est_nosmoke	: reg bweight mmarried mage prenatal1 fbaby if mbsmoke==0
scalar SSE_nosmoke=e(rss)

// 無限制的SSE是把有抽菸的SSE+沒抽煙的SSE加起來
scalar SSE_U=SSE_smoke+SSE_nosmoke

// 全部跑回歸
eststo est_pool 	: reg bweight mmarried mage prenatal1 fbaby 
// 這時的SSE會是有限制時的SSE，因為等於是限制了「有無抽菸的係數一樣」
scalar SSE_R=e(rss)

di ( (SSE_R-SSE_U) / 5) / ( SSE_U /1190 )
/*
	分子：多了限制之後，平均一個限制帶來的誤差之差
			有五個限制（mmarried mage prenatal1 fbaby 還有常數）
	分母：沒限制的情況下，每一個自由度平均誤差
			總自由度為 N-K = 1200 - 5*2 = 1190
*/

// 另外一種做法： 直接做 mbsmoke 與所有回歸向的交乘，並檢定這些交乘項的係數是否為零
reg bweight mbsmoke##(i.mmarried c.mage i.prenatal1 i.fbaby)
test 1.mbsmoke 1.mbsmoke#1.mmarried 1.mbsmoke#c.mage 1.mbsmoke#1.prenatal1 1.mbsmoke#1.fbaby


//e 

			//利用矩陣運算，參考助教課影片
			
est restore est_smoke
matrix smoke_b = e(b)

est restore est_nosmoke
matrix nosmoke_b = e(b)

matrix diff_smoke_b = smoke_b - nosmoke_b

//取得各變數平均
mean mmarried mage prenatal1 fbaby
matrix var_means=e(b), (1)	// 在最後加上截距項平均，也就是 1

//兩個矩陣做內積
matrix ATE= diff_smoke_b * var_means'

di "平均處理效果為：" ATE[1,1]






