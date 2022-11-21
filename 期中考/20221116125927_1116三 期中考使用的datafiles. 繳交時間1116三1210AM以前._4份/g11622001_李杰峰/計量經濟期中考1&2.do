clear
eststo clear
use http://www.stata.com/data/s4poe5/data/motel

//(1.1)
gen newrelprice = relprice * 100
twoway (scatter motel_pct newrelprice)

//(1.2)
eststo est_1_2 : reg motel_pct newrelprice

//(1.3)
predict res_1_2, res
twoway (scatter res_1_2 newrelprice) (scatter res_1_2 newrelprice if time>16), ///
		legend(label(1 "t<16") label(2 "t>16" ))

//(1.4)
eststo est_1_4 :reg motel_pct repair
margin, at(repair=(0 1))


//(2.1)
twoway(line motel_pct comp_pct time, sort),  //
	legend(label(1 "Motel" 2 "Component"))
eststo est_2_1 : reg motel_pct comp_pct

//(2.2)
margin, at(comp_pct=70) level(90)

//(2.3)
scalar t_value = _b[comp_pct]/_se[comp_pct]
di "t-value		:" t_value
di "critical value:" invttail(e(df_r), 0.01)
di "p-value		:" ttail(e(df_r), t_value)

//(2.4)
test comp_pct=1

//(2.5)

est restore est_2_1
predict res_2_5, res 
twoway (scatter res_2_5 time), xline(16)