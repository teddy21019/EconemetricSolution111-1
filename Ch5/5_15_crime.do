clear

cd "C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\Ch5\Results"
use "C:\Users\tedb0\Documents\111-1\EconometricSolution111-1\DATA\crime"

// 建立變數

// 喔他已經幫我建好了

eststo: reg lcrmrte prbarr prbconv prbpris polpc wcon if year==86

esttab using "5_15.rtf" , se r2 replace

/*

這題很簡單，但是卻很重要


在進行回歸的時候，係數的解讀要很小心。
尤其在考慮因果關係時。

這裡看的出來，警察越多，看似犯罪比率越高，好像會推出
「警察會帶來犯罪」這樣的荒謬結論

然而警察會多，是因為犯罪率高，但是我們的模型並沒有考慮到這個可能性
這樣的問題稱作「內生性」。


多變數回歸很方便，但除非是完全隨機的實驗(Randomized Experiments)
否則只要是觀察到的資料，都要考慮解釋變數是否有內生性問題。

這也就是為什麼課本不會到這裡就結束了，經濟學家為了在不能做實驗的情況下
解釋效果發明了一整套的計量經濟作法，所以計量絕對不是丟給 stata 跑一個
reg y x1 x2 x3
就能拿諾貝爾獎的。
*/