/* 
	applied metrics
	problem set 2: tables
	emily case
*/


texdoc init "tables/q4a.tex", replace
/*tex
\begin{table}[h!]
\caption{Looking at the common supports}
	\label{q4}
\begin{center}
\begin{tabular}{lrccc}
\toprule
& & Minimum & Mean & Maximum \\
\addlinespace
\hline
tex*/

texdoc write \multicolumn{2}{l}{\textit{coarse scores}} & & & \\

local a0min  = round(a0min, .00001)
local a0mean = round(a0mean, .00001)
local a0max  = round(a0max, .0001)
texdoc write & CPS group & `a0min' & `a0mean' & `a0max' \\

local a1min  = round(a1min, .00001)
local a1mean = round(a1mean, .00001)
local a1max  = round(a1max, .0001)
texdoc write & control group & `a1min' & `a1mean' & `a1max' \\ \addlinespace

texdoc write \multicolumn{2}{l}{\textit{rich scores}} & & & \\

local b0min  = round(b0min, .00001)
local b0mean = round(b0mean, .00001)
local b0max  = round(b0max, 0.0001)
texdoc write & CPS group & `b0min' & `b0mean' & `b0max' \\

local b1min  = round(b1min, .00001)
local b1mean = round(b1mean, .00001)
local b1max  = round(b1max, .0001)
texdoc write & control group & `b1min' & `b1mean' & `b1max' \\

/*tex
\bottomrule
\end{tabular}
\end{center}
\end{table}
tex*/
texdoc close



texdoc init "tables/q6a.tex", replace

/*tex
\begin{table}[h!]
\caption{Using \texttt{psmatch2} (questions 6 and 7)}
	\label{q6}
\begin{center}
\begin{tabular}{lrlllll}
\toprule
&& \multicolumn{2}{c}{\textbf{No replacement}} && \multicolumn{2}{c}{\textbf{Replacement}}\\ 
& & Difference & S.E. && Difference & S.E. \\
\addlinespace
\hline
\addlinespace
\multicolumn{2}{l}{\textit{coarse scores}} && & &&\\
tex*/
sca rounding = 0.1

foreach stat in diff se{
	foreach t in unm att{
		foreach i in a b{
			foreach r in nor r{
				global `r'_`stat'_`t'`i' = round(`r'_`stat'_`t'`i', rounding)
			}
		}
	}
}

local row1 = "& Unmatched & $nor_diff_unma & $nor_se_unma && $r_diff_unma & $r_se_unma\\"
local row2 = "& ATT & $nor_diff_atta & $nor_se_atta && $r_diff_atta & $r_se_atta \\ \addlinespace"
local row3 = "\multicolumn{2}{l}{\textit{rich scores}} && & &&\\"
local row4 = "& Unmatched & $nor_diff_unmb & $nor_se_unmb && $r_diff_unmb & $r_se_unmb\\"
local row5 = "& ATT & $nor_diff_attb & $nor_se_attb && $r_diff_attb & $r_se_attb \\"


forvalues i =1/5{	
	texdoc write `row`i''
}

/*tex
\bottomrule
\end{tabular}
\end{center}
\end{table}
tex*/
texdoc close 


****** standardized differences q8 ******

texdoc init "tables/q8.tex", replace
/*tex
\begin{table}[h!]
\caption{Standardized differences (question 8)}
	\label{q8}
\begin{center}
\begin{tabular}{rccc}
\toprule
& Raw data & Single NN with replacement & Reduced bias by \\
\addlinespace
\hline
\addlinespace
tex*/

local raw74 = round(raw_sdiff_re74, .01)
local raw75 = round(raw_sdiff_re75, 0.01)
local sd75  = round(sdiff_re75, 0.01)
local sd74  = round(sdiff_re74, 0.1)
local bias74 = biasreduc_74
local bias75 = biasreduc_75

texdoc write \texttt{re74} & `raw74' & `sd74' & `bias74'\% \\ \addlinespace
texdoc write \texttt{re75} & `raw75' & `sd75' & `bias75'\% \\

/*tex
\bottomrule
\end{tabular}
\end{center}
\end{table}
tex*/
texdoc close



****** different bandwidths (q9 and q10) ******

texdoc init "tables/q10.tex", replace

/*tex
\begin{table}[h!]
\caption{Using \texttt{psmatch2} (questions 9 and 10)}
	\label{q10}
\begin{center}
\begin{tabular}{rlllll}
\toprule
& \multicolumn{2}{c}{\textbf{Q9: Kernel}} && \multicolumn{2}{c}{\textbf{Q10: LLR}}\\ 
& Difference & S.E. && Difference & S.E. \\
\addlinespace
\hline
\addlinespace
tex*/

global q9unm_diff : di %7.2fc q9_diff_unm1
global q9unm_se   : di %7.2fc q9_se_unm1

foreach stat in diff se{
	foreach ban in 1 2 3 {
		foreach q in 9 10{
			global q`q'_`stat'`ban' : di %7.2fc q`q'_`stat'_att`ban'
		}
	}	
}

local row1 = "Unmatched & $q9unm_diff & $q9unm_se && - & - \\ \addlinespace " 
local row2 = "ATT ban = 0.02 & $q9_diff1 & $q9_se1 && $q10_diff1 & $q10_se1 \\"
local row3 = "ATT ban = 0.2 & $q9_diff2 & $q9_se2 && $q10_diff2 & $q10_se2 \\"
local row4 = "ATT ban = 2.0 & $q9_diff3 & $q9_se3 && $q10_diff3 & $q10_se3 \\"

forvalues i =1/4{	
	texdoc write `row`i''
}

/*tex
\bottomrule
\end{tabular}
\end{center}
\end{table}
tex*/
texdoc close 
