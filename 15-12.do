use http://www.stata.com/data/s4poe5/data/star
reg readscore  small aide tchexper  boy white_asian freelunch
reg readscore  small aide tchexper  boy white_asian freelunch i.schid
help reg
sort id schid
sort schid id
sort id schid
sort schid  tchid
sort tchid  schid
xtset schid id
xtreg readscore small aide tchexper boy white_asian freelunch, fe
xtreg readscore small aide tchexper boy white_asian freelunch, re
help OVR
help reghdfe
ssc install reghdfe
clear
use http://www.stata.com/data/s4poe5/data/star
xtset schid
xtreg readscore small aide tchexper boy white_asian freelunch, fe
xtreg readscore small aide tchexper boy white_asian freelunch, re
reg readscore  small aide tchexper  boy white_asian freelunch
esttab
eststo : xtreg readscore small aide tchexper boy white_asian freelunch, fe
eststo:xtreg readscore small aide tchexper boy white_asian freelunch, re
eststo: reg readscore  small aide tchexper  boy white_asian freelunch
esttab
help xtreg
est restore est1
estimates replay est1
ereturn list
help xtreg
di e(F_f)
est restore est_2
est restore est2
estimates replay est2
xttest0
help  xttest0
hausman . random_effects
hausman
hausman est2 est3
esttab
hausman est2 est1
hausman est1 est2
