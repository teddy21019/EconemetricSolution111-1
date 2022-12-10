clear 
graph drop _all

cd "C:\Users\usr\Desktop\midterm"

use "C:\Users\usr\Desktop\motel.dta"

//1-1
gen x = 100* relprice
twoway (scatter motel_pct x ) ( line motel_pct x ,sort)

//1-2
eststo : reg motel_pct x
esttab using "1_2.rft"

//1-3
estimates restore est1
predict res_2 , residual
label var res_2 "Residual from 2"
twoway (scatter res_2 time)

//1-4
eststo : sum motel_pct if repair == 1, detail
di r(mean)

eststo : sum motel_pct if repair == 0, detail
di r(mean)


//2-1
twoway (scatter motel_pct time,sort ) ( scatter comp_rate time ,sort)
eststo :  reg motel_pct comp_pct
esttab, cell( b (fmt(3)) ci(fmt(3)par) )

//2-2
eststo : reg motel_pct comp_pct   ///est9
margin, at(comp_pct = 70)

//2-3
scalar t_b3

//2-4
estimates restore est9
test comp_pct = 1

//2-5
estimates restore est9
predict res_9 , residual
label var res_9 "Residual from 9"
twoway (scatter res_9 time)



clear 
graph drop _all

cd "C:\Users\usr\Desktop\midterm"

use "C:\Users\usr\Desktop\cex5_small.dta"


//3-1
sum food, detail

sum income, detail

//3-2 3-3 3-4
gen ln_food = ln(food)
gen ln_income = ln(income)

eststo lin_lin, title("Linear Model") : reg food income 
eststo log_log, title("Log-Log Model") : reg ln_food ln_income
eststo lin_log, title("Linear-Log Model") : reg food ln_income

esttab, mti stats(r2 rmse)
esttab using "table_3.rtf"
















