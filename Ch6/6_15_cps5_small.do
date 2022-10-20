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

