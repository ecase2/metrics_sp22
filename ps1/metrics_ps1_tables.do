/*
	applied metrics spring 2022
	problem set 1 tables
	emily case 
	
	note: need to install texdoc for this to work
*/

quietly{
*************************
*	problem 7: tables   *
*************************

* table for parts a through d
texdoc init "results/q7b.tex", replace

* write the table heading:

/*tex
\begin{table}[h!]
\caption{Problem 7}
	\label{q7b}
\begin{center}
\begin{tabular}{lll}
\multicolumn{3}{c}{Probit model derivatives, 4 ways} \\
\toprule
& method & derivative \\
\hline
\addlinespace
tex*/

local row1 = "(a) & \texttt{dprobit} & "
local row2 = "(b) & using formula \& \texttt{summarize} & "
local row3 = "(c) &  numerical derivatives & "
local row4 = "(d) & \texttt{margins} & "


forval i = 1/4  {	
	local deriv = round(deriv`i', .0000001)
	local row`i' = "`row`i''" + "`deriv'" + "\\ \addlinespace" //perhaps an issue with sig figs
	texdoc write `row`i''
}


* write the table footing:
/*tex
\bottomrule
\end{tabular}
\end{center}
\end{table}
tex*/
texdoc close 


*************************
*	problem 8: tables   *
*************************

texdoc init "results/q8.tex", replace
/*tex
\begin{table}[h!]
\caption{Problem 8: comparing numerical derivatives}
	\label{q8}
\begin{center}
\begin{tabular}{cc}
\toprule
\addlinespace
Probit & LPM (with quartic client age) \\
\hline
\addlinespace
tex*/
local probitderiv = round(deriv3, .0000001)
local lpmderiv = round(lpm_deriv, .0000001)

local row1 = "`probitderiv'" + "&" + "`lpmderiv'" + "\\ \addlinespace"

texdoc write `row1' 

/*tex
\bottomrule
\end{tabular}
\end{center}
\end{table}
tex*/
texdoc close 

*************************
*	problem 10: tables  *
*************************

local cpr1 = cpr1
local cpr2 = round(cpr2 , .0001)
local row1 = "0.5 & " + "`cpr1'" + " \\ \addlinespace"
local row2 = "loan take up fraction & " + "`cpr2'" + " \\ \addlinespace"


texdoc init "results/q10.tex", replace
/*tex
\begin{table}[h!]
\caption{Problem 10}
	\label{q10}
\begin{center}
\begin{tabular}{rc}
\toprule
Cutoff value & Correct prediction rate \\
\toprule
\addlinespace
tex*/

texdoc write `row1'
texdoc write `row2'

/*tex
\bottomrule
\end{tabular}
\end{center}
\end{table}
tex*/
texdoc close 




*************************
*	problem 11: tables  *
*************************

local cpr1_ss = cpr1_ss
local cpr2_ss = round(cpr2_ss , .0001)
local row1 = "0.5 & " + "`cpr1' & " + "`cpr1_ss'" + " \\ \addlinespace"
local row2 = "loan take up fraction & " + "`cpr2' & " + "`cpr2_ss'"+ " \\ \addlinespace"


texdoc init "results/q11.tex", replace
/*tex
\begin{table}[h!]
\caption{Problem 11}
	\label{q11}
\begin{center}
\begin{tabular}{rcc}
\toprule
Cutoff value & Correct prediction rate & Correct prediction rate (subsample) \\
\toprule
\addlinespace
tex*/

texdoc write `row1'
texdoc write `row2'

/*tex
\bottomrule
\end{tabular}
\end{center}
\end{table}
tex*/
texdoc close 


*************************
*	problem 13: tables  *
*************************

local ie = round(inteffects, .0001)
local ie_se = round(inteffects_se, .0001)
local fd = round(finitediff , .0001)
local row1 = "interaction effects & " + "`ie' & " + "`ie_se'" + " \\ \addlinespace"
local row2 = "finite differences & " + "`fd'" + "& \\ \addlinespace"


texdoc init "results/q13.tex", replace
/*tex
\begin{table}[h!]
\caption{Problem 13}
	\label{q13}
\begin{center}
\begin{tabular}{lll}
\toprule
&& standard error \\
\midrule
tex*/

texdoc write `row1'
texdoc write `row2'

/*tex
\bottomrule
\end{tabular}
\end{center}
\end{table}
tex*/
texdoc close 

}
