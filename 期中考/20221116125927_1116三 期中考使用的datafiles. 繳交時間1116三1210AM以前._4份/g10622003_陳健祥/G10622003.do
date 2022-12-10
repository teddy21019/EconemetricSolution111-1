//前處理
clear all
cd "C:\Users\edgeman\OneDrive\桌面\新增資料夾"
use "C:\Users\edgeman\OneDrive\桌面\新增資料夾\motel.dta"

//第一題

gen p_relprice = 100*relprice

twoway (scatter motel_pct p_relprice)(lfit motel_pct p_relprice)
eststo m_1 :reg motel_pct p_relprice
esttab using 122.rtf ,r2


//第一題(4)
eststo m_2 : reg motel_pct repair
twoway (scatter motel_pct repair)(lfit motel_pct repair)
predict no_repair_time if repair == 1//預測維修時
predict do_repair_time if repair == 0//預測沒有維修時
sum no_repair_time//取平均
sum do_repair_time//取平均

//第二題
eststo m_3 :reg motel_pct comp_pct
esttab m_3 using 132.rtf ,r2 ci
test comp_pct, coef a 
test comp_pct, coef a
//第二題(2)
twoway (line motel_pct time)(line comp_pct time)
predict yhat,xb
//第三題
//前處理
clear all
cd "C:\Users\edgeman\OneDrive\桌面\新增資料夾"
use "C:\Users\edgeman\OneDrive\桌面\新增資料夾\cex5_small.dta"

//描述統計
sum food income,d
sum food income

//234小題

gen lfood=ln(food)
gen lincome=ln(income)
eststo m_1 :reg food income
eststo m_2 :reg lfood lincome
eststo m_3 :reg food lincome
esttab using 162.rtf ,r2 ar2

//第四題

//前處理
clear all
cd "C:\Users\edgeman\OneDrive\桌面\新增資料夾"
use "C:\Users\edgeman\OneDrive\桌面\新增資料夾\crime.dta"

//(1)

reg crmrte prbarr prbpris prbconv polpc
gen prbconv2 = prbcon*prbcon
gen prbpris2 = prbpris*prbpris
gen prbarr2 = prbarr*prbarr
reg crmrte prbarr prbpris prbconv polpc prbarr2 density urban
eststo m_1 :reg crmrte prbarr prbpris prbconv polpc 
eststo m_2 :reg crmrte prbarr prbpris prbconv polpc prbarr2
eststo m_3 :reg crmrte prbarr prbpris prbconv polpc prbarr2 prbpris2
eststo m_4 :reg crmrte prbarr prbpris prbconv polpc prbarr2 prbpris2 prbconv2
eststo m_5 :reg crmrte prbarr prbpris prbconv polpc prbarr2 prbpris2 prbconv2 density
esttab using 2223.rtf ,r2 ar2 aic bic 
