clear
eststo clear

use http://www.stata.com/data/s4poe5/data/cex5_small

//(3.1)
sum food, detail
sum income, detail

//(3.2)
eststo lin_lin : reg food income 

//(3.3)
gen ln_food = log(food)
gen ln_income = log(income)

eststo log_log : reg ln_food ln_income

//(3.4)
eststo lin_log : reg food ln_income

//(3.5)
global ests="lin_lin log_log lin_log "

foreach m of global ests{
	quietly{
		estimates restore `m'	
		capture drop res_`m'			
		predict res_`m', residual
	}
	di e(estimates_title)
	jb res_`m'
	hist res_`m', name(res_`m')
	di ""
}

//(3.6)
esttab, r2






