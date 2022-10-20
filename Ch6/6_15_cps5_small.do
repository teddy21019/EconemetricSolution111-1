clear
eststo clear

cd "C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch6\Results"
use http://www.stata.com/data/s4poe5/data/cps5_small

gen ln_wage = log(wage)

//============= a
eststo est_a : reg ln_wage educ exper if educ>7

test (exper = 0.008) (educ = 14*exper)

// 無法拒絕虛無假設，所以可以相信這個「據說」是顯著的

//============= b
// RESET
predict yhat

reg ln_wage educ exper c.yhat#c.yhat if educ>7
test c.yhat#c.yhat

reg ln_wage educ exper c.yhat#c.yhat c.yhat#c.yhat#c.yhat if educ>7
test c.yhat#c.yhat c.yhat#c.yhat#c.yhat

/*
	兩個RESET檢定都告訴你， yhat 的二次、三次式係數都顯著不等於零，意味著 educ exper 等等的平方立方項會增加解釋力，所以模型還可以更好
*/

// ============== c 
eststo est_c : reg ln_wage (c.educ c.exper)##(c.educ c.exper) if educ>7

/*
這邊先做個簡單的微分

		educ		exper		educ^2		educ*exper		exper^2
beta		1			2			 3				 4			  5	
	
	educ 的邊際效果： 
	_beta1 + 2 * educ * _beta3 + exper * _beta4
	
	exper 的邊際效果：
	_beta2 + 2 * exper * _beta5 + educ * _beta4
*/

// educ = 10, exper = 5
scalar v_educ = 10
scalar v_exper = 5

test ///
	(educ + 2 * v_educ * c.educ#c.educ + v_exper * c.educ#c.exper = 0.112) ///
	(exper + 2 * v_exper * c.exper#c.exper + v_educ * c.educ#c.exper = 0.008)
	
scalar v_educ = 14
scalar v_exper = 24

test ///
	(educ + 2 * v_educ * c.educ#c.educ + v_exper * c.educ#c.exper = 0.112) ///
	(exper + 2 * v_exper * c.exper#c.exper + v_educ * c.educ#c.exper = 0.008)
	
scalar v_educ = 18
scalar v_exper = 40

test ///
	(educ + 2 * v_educ * c.educ#c.educ + v_exper * c.educ#c.exper = 0.112) ///
	(exper + 2 * v_exper * c.exper#c.exper + v_educ * c.educ#c.exper = 0.008)
	
	
// 也可以練習用 program 做，以下參考

		capture program clear test_margin

		program test_margin
			args v_educ v_exper
			test ///
			(educ + 2 * `v_educ' * c.educ#c.educ + `v_exper' * c.educ#c.exper = 0.112) ///
			(exper + 2 * `v_exper' * c.exper#c.exper + `v_educ' * c.educ#c.exper = 0.008)
		end

		test_margin 10 5
		test_margin 14 24
		test_margin 18 40 



// ========== d 
predict yhat_c

reg ln_wage (c.educ c.exper)##(c.educ c.exper) ///
		c.yhat_c#c.yhat_c if educ>7
test c.yhat_c#c.yhat_c

reg ln_wage (c.educ c.exper)##(c.educ c.exper) ///
		c.yhat_c#c.yhat_c c.yhat_c#c.yhat_c#c.yhat_c if educ>7
test c.yhat_c#c.yhat_c c.yhat_c#c.yhat_c#c.yhat_c

// ============ e 
/*
並不是對所有教育程度/經驗都成立。從 c 來看，只有中間水準的教育程度與經驗，會有這個 0.8% 法則。
我們可以比第一題的回歸較有信心，是因為經過 RESET 之後相信多了交乘項與平方項之後的模型足夠好了
*/