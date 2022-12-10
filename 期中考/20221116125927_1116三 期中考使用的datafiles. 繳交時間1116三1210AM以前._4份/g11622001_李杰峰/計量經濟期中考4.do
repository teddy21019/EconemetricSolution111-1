clear
eststo clear

use http://www.stata.com/data/s4poe5/data/crime
//(4.1)
eststo est_4_1 : reg crmrte prbarr prbpris prbconv polpc 
esttab est_4_1, cell("b(star fmt(3)) se t p")

//(4.2)
esttab, keep(prbarr) ci

//(4.3)
eststo est_4_3 : reg crmrte prbarr prbpris prbconv polpc c.prbarr#c.prbarr density urban
esttab est_4_3, cell("b(star fmt(3)) se t p")

//(4.4)
margin, dydx(prbarr) 


//(4.5)
test density

//(4.6)
est restore est_4_3
predict yhat_4_3

eststo reset_4_3 : reg crmrte prbarr prbpris prbconv polpc c.prbarr#c.prbarr density urban c.yhat_4_3#c.yhat_4_3 c.yhat_4_3#c.yhat_4_3#c.yhat_4_3

test c.yhat_4_3#c.yhat_4_3 c.yhat_4_3#c.yhat_4_3#c.yhat_4_3




//(7)

eststo clear

global x_1 prbarr prbpris prbconv polpc 
global x_2 $x_1 c.prbarr#c.prbarr
global x_3 $x_1 c.prbarr#c.prbarr c.prbpris#c.prbpris
global x_4 $x_1 c.prbarr#c.prbarr c.prbpris#c.prbpris c.prbconv#c.prbconv
global x_5 $x_1 c.prbarr#c.prbarr c.prbpris#c.prbpris c.prbconv#c.prbconv density

foreach a of numlist 1/5 {
    local x = "${x_`a'}"
	  di "現在的迴歸式: `x'"
	  eststo est_`a': reg crmrte `x'
}

esttab, mti drop(*) r(2) ar2(5) aic(5) bic(5) scalar(rmse) sfmt(5)