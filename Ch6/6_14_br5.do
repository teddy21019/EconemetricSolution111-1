clear
eststo clear

cd "C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch6\Results"
use http://www.stata.com/data/s4poe5/data/br5

gen ln_price = ln(price)

//============ a

eststo est_a : reg ln_price sqft age c.age#c.age
esttab, se

// ============ b
twoway ///
(function y=_b[_cons] + _b[sqft] * 22 + _b[age] * x + _b[c.age#c.age] * x^2, range(0 100)), ///
xtitle("Age") ytitle("E[log(price)]")

//============= c

/*
	可以用 test 來直接進行聯合檢定。注意，test 只能檢定線性組合，所以有預設防呆措施，
	使得打 ^ 會出錯，所以不能打 5^2，要直接算出來。可以用 scalar 解決，但這邊就從簡
*/

test ///
(5*age + 25*c.age#c.age = 80*age + 6400*c.age#c.age) ///
(20*sqft + 5*age + 25*c.age#c.age = 28*sqft + 30*age + 900*c.age#c.age)

//============== d 
scalar ln_100=ln(100)

test ///
(age + 2*50*c.age#c.age = 0) ///
(_cons + 22*sqft + 50*age + 2500*c.age#c.age = ln_100)

//=============== e 

eststo est_e : reg ln_price sqft age c.age#c.age baths c.sqft#c.bedrooms
esttab, se

// ============== f 

test baths c.sqft#c.bedrooms

// ================ g

/*
	我們先用 exp(E[ln_price]) 做估計
*/
margins, at(age=0 bedrooms=3 baths=2 sqft=23) expression(  exp(xb())  )
scalar price_before = r(b)[1,1]

margins, at(age=0 bedrooms=4 baths=3 sqft=25.6) expression(  exp(xb()) )
scalar price_after = r(b)[1,1]

di "Price difference = " price_after - price_before

/*
	在這個模型設定之下，ln(price) 符合常態分佈。所以 price 符合對數常態分布，期望值會需要乘上一個修正項 exp(se^2/2)
*/
predict res, residual

sum res
scalar correction = exp(r(sd)^2/2)

margins, at(age=0 bedrooms=3 baths=2 sqft=23) expression(  exp(xb())*correction  )
scalar price_before = r(b)[1,1]

margins, at(age=0 bedrooms=4 baths=3 sqft=25.6) expression(  exp(xb())*correction  )
scalar price_after = r(b)[1,1]

di "Price difference = " price_after - price_before


// ============ h 
margins, at(age=20 bedrooms=3 baths=2 sqft=23) expression(  exp(xb())*correction  )
scalar price_before = r(b)[1,1]

margins, at(age=20 bedrooms=4 baths=3 sqft=25.6) expression(  exp(xb())*correction  )
scalar price_after = r(b)[1,1]

di "Price difference = " price_after - price_before