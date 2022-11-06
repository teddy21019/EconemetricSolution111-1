clear
eststo clear
graph drop _all

global chapter_dir="C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch7"

cd "$chapter_dir\Results"

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
bysort mbsmoke : eststo : reg bweight mmarried mage prenatal1 fbaby


reg bweight mbsmoke##(i.mmarried c.mage i.prenatal1 i.fbaby)
test 1.mbsmoke 1.mbsmoke#1.mmarried 1.mbsmoke#c.mage 1.mbsmoke#1.prenatal1 1.mbsmoke#1.fbaby

// v.s.
est restore est3
scalar SSE_0=e(rss)

est restore est4
scalar SSE_1=e(rss)

scalar SSE_U=SSE_0+SSE_1

est restore est_c
scalar SSE_R=e(rss)

di (SSE_R-SSE_U)/(SSE_U) * (1190)/(5)