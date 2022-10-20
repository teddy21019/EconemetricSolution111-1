clear
eststo clear
use http://www.stata.com/data/s4poe5/data/br5

gen ln_price = ln(price)

/*
	秀操作時間
	第一個 x_2 是 baseline model，後面所有回歸都是以這個為基準往後加
	因為存成 global ，所以之後Stata看到 $x_2 就會自動替換成 age sqft c.age#c.age
	
*/

global x_2 	age sqft c.age#c.age
global x_9 	$x_2 baths		// 另外一個global variable，定義為在 x_2 之後，增加 baths 
global x_10 $x_2 baths bedrooms
global x_11	$x_2 baths c.bedrooms#c.sqft
global x_12	$x_2 baths c.bedrooms#c.sqft c.baths#c.sqft


/*
	numlist 表示是數字清單
	可以打 2 9 10 11 12，但因為後面是 9到12，可以簡化成
	2 9/12
*/
foreach a of numlist 2 9/12{
	// a -> x_`a' -> x_`a' 對應到的global 值
	local x="${x_`a'}"
	di "現在的回歸項： `x'"
	eststo est_`a' : reg ln_price `x'
}


/*
	mti 		: 標題用模型名稱
	drop(*) 	: 不顯示所有係數
	r2 			: R^2
	ar2 		: adjusted R^2
	scalar(rmse): 從 regression 的結果區裡面拿東西，例如 rmse
	sfmt(5)		: scalar 裡面的東西要幾位小數
	xxx(5)		: 其他有括號表示要顯示幾位小數
*/
esttab, mti drop(*) r2(5) ar2(5) aic(5) bic(5) scalar(rmse) sfmt(5)
