cd /Users/huang/Downloads/計量經濟＿期中考
use /Users/huang/Downloads/計量經濟＿期中考/crime.dta

///4.
//(1)
eststo: reg crmrte prbarr prbpris prbconv polpc

//(3)
gen prbarr2= prbarr^2
eststo: reg crmrte prbarr prbpris prbconv polpc prbarr2 density urban
