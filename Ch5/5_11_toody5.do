clear

cd "C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch5\Results"
use "C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\DATA\toody5"

eststo est_a : ///
	reg y trend rain c.rain#c.rain c.rain#c.trend

	


    				//======================//
    				//						//
    				//			(a)			//
    				//						//
    				//======================//
    				//	估計 beta SE T P 


estout, cells("b(star fmt(3)) se t p") ///
		varlabels( c.rain#c.rain rain^2 c.rain#c.trend rain*trend _cons constant ) /// 重新命名 var
		starlevels(+ 0.1 * 0.05 ** 0.01 *** 0.001)
// estout 用法: http://fmwww.bc.edu/repec/bocode/e/estout.old/advanced.html


    				//======================//
    				//						//
    				//			(b)			//
    				//						//
    				//======================//
    				//	信心水準 


					/*
						上面的指令重新定義了顯著的符號。我將 10% 顯著水準定義為標記 +
						可看到 rain * trend 在 10% 水準下顯著，但不及 5%
						但其他在5%水準下，都顯著不等於 0
					*/
	

    				//======================//
    				//						//
    				//			(c)			//
    				//						//
    				//======================//
    				//	解釋符號 


					/*
						這邊focus 在兩個交乘項的直覺：
						 -- rain ^ 2 ：雨太多反而會淹死，所以直覺上他的邊際產出會遞減，也就是預期
										rain^2 係數會 <0
						 -- rain * trend ：隨著技術進步，多下雨帶來的效益就會越小（因為這是抗旱的科技）
										反而在科技卓越時，下雨反而會帶來不便。因此預期此交乘項係數 <0
					*/


    				//======================//
    				//						//
    				//			(d)			//
    				//						//
    				//======================//
    				//	1959 1995 時的降雨的邊際效果 


					/*
						先看這兩年對應到的技術指標(trend)
					*/
	
list trend if (t == 1959-1950+1 | t == 1995-1950+1)

					/*
						一個是 0.9, 一個是 4.5
					*/

// 1959 年
// dydx(rain) 表示我是對 rain 微分，所以是看 rain 的邊際效果，在 rain=2.98 且 trend=0.9 時
margin, dydx(rain) at(rain=(2.98) trend=(0.9) )

//  1995 年
margin, dydx(rain) at(rain=(4.797) trend=(4.5) )



    				//======================//
    				//						//
    				//			(e)			//
    				//						//
    				//======================//
    				//	最好的降雨量估計 

					/*
						將回歸式對 rain 微分，移項之後求解
					*/


nlcom (-_b[rain] - _b[c.rain#c.trend] * 0.9)/(2 * _b[c.rain#c.rain ])

nlcom (-_b[rain] - _b[c.rain#c.trend] * 4.5)/(2 * _b[c.rain#c.rain ])
	