cd /Users/huang/Downloads/計量經濟＿期中考
use /Users/huang/Downloads/計量經濟＿期中考/motel.dta

///1.
//(1)
gen relprice_hundred= 100*relprice
//(2)
eststo: reg motel_pct relprice_hundred
twoway(scatter motel_pct relprice_hundred)(lfit motel_pct relprice_hundred)
//(3)
//(4)
eststo: reg motel_pct repair

///2.
//(1)
twoway(scatter comp_pct time)(scatter motel_pct time)
eststo: reg motel_pct comp_pct
//(2)
//(3)
//(5)
predict motel_comp,xb
twoway(scatter motel_comp time)(lfit motel_comp time)


