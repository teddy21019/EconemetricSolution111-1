// 助教：陳家威
// r10323045@ntu.edu.tw

// 把上一次執行的先通通清除，重新開始
clear 

// 首先，告訴Stata你現在要用的資料是在哪一個資料夾裡面，並且移進去
cd "/Users/abc/Desktop/111-1/東海計量/助教/datafiles"

// 因為已經告訴他資料在哪一個資料夾，你可以直接把 ***.dta 的 ***，用 use 抓出來。
// ！！注意：只有檔案是 .dta 可以直接用 use。如果資料是 excel 或是 csv 會需要其他指令。
use collegetown

// 有 x y 的都要用 twoway
// 不同作圖用 () 分開來
// scatter y x 用來畫散佈圖
twoway (scatter price sqft)




// price 對 sqft 回歸
reg price sqft 
// 模型建立完之後都會有一個預測值。以下命名叫做 yhat1
// 這一個指令會把所有資料右邊都加一欄，用來存預測值
predict yhat1, xb
// 預測出來的 yhat 跟原始資料的差異，就是殘差項。一樣會在原始資料右邊加一欄。
predict res1, residual
// 每一個模型估計完之後，都會把他的結果放在 e(.), r(.), 之類的地方。
// SSE(Sum of Squared Residual) 跟 RSS(Resisual Sum of Squares) 是一樣的
// Stata用的是 rss，我們用 e(rss) 把他的直抓出來，命名為 "sse_1"，並用 scalar指令存起來
scalar sse_1=e(rss)

// 剛剛建立的 yhat1 當 y，sqft一樣當 x，做一條直線
twoway (scatter price sqft) (line yhat1 sqft , sort)


//==========================================
//================= 平方項===================


// 用 # 來代表回歸式中的交乘或是平方，會比建立一個新的變數 sqft2 = sqft^2 來得好
// 原因是在用 margin 求邊際效果的時候，stata會把新建立的變數當獨立變數，會很麻煩
reg price c.sqft#c.sqft
predict yhat2, xb
predict res2, residual
scalar sse_2=e(rss)

// 在 sqft=20的地方，算出所有(*)變數的邊際效果
margin, dydx(*) at(sqft=20)
// 存起來。出來的結果r(b) 是矩陣，所以要用這種噁心的寫法抓出來
scalar slope_at_20 = el(r(b),1,1)

// 如果不說是 dydx，那他出來的會是在 20 這個地方，他的平均預測會是多少（單變數可以這樣解釋）
margin, at(sqft=20)
scalar pred_at_20 = el(r(b), 1,1)

twoway  (scatter price sqft ,msymbol(smx)) ///
		(line yhat2 sqft , sort) ///
		(function y = slope_at_20 * (x-20) + pred_at_20, range(sqft) ) // 熟悉的點斜式
		

// 計算彈性也有直接做法
margin, eyex(*) at(sqft=20)

// 這邊示範調整不同形狀
twoway (scatter res1 sqft, msize(small)) (scatter res2 sqft, msize(small) msymbol(triangle))

// 在Stata中，如果要印出文字或值（像是python裡的 print ），需要用 display
//或是縮寫 di
di "SSE for the first regression: " sse_1
di "SSE for the second regression: " sse_2
