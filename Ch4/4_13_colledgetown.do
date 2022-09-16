clear
graph drop _all
eststo clear

cd "C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch4\Results"
use "C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\DATA\collegetown"

//
// cd "/Users/abc/Desktop/111-1/東海計量/Solution/Ch3/Results"
// use "/Users/abc/Desktop/111-1/東海計量/Solution/DATA/collegetown"

gen ln_price = log(price)
gen ln_sqft = log(sqft)

eststo log_lin, title("Log-Linear Model") : reg ln_price sqft
eststo log_log, title("Log-Log Model") : reg ln_price ln_sqft
eststo lin_lin, title("Linear Model") : reg price sqft

esttab, mti


// add JB

global ests="log_lin log_log lin_lin"

// self define jb

foreach m of global ests{
	quietly{
	estimates restore `m'
	capture drop res_`m'
	predict res_`m', residual
	}
	jb res_`m'
	di ""
	
}

local i=1
foreach m of global ests{
	di "`m'"
	local plot_name = "Q4_13_hist`i'"
	quietly{
		estimates restore `m'
		
	}
	hist res_`m', saving(`plot_name', replace) name(`plot_name', replace)
	local ++i
}
local i=1
foreach m of global ests{
	di "`m'"
	local plot_name = "Q4_13_res`i'"
	scatter res_`m' sqft , saving(`plot_name', replace) name(`plot_name', replace)
	local ++i
}