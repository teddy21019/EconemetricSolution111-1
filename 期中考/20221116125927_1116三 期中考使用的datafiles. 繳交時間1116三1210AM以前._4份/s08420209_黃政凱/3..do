cd /Users/huang/Downloads/計量經濟＿期中考
use /Users/huang/Downloads/計量經濟＿期中考/cex5_small.dta

///3.
//(1)
sum food
sum income
//中位數,P50
sum food,d
sum income,d
//(2)
reg food income
//(3)
gen ln_food=ln(food)
gen ln_income=ln(income)
reg ln_food ln_income

//(4)
reg food ln_income

//(5)
predict food_income,xb
hist food_income

predict lnfood_lnincome,xb
hist lnfood_lnincome
  
predict food_lnincome,xb
hist food_lnincome

//(6)
