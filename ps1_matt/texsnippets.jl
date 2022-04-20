### this file writes all my tables and graphics for the write up file ###



### part c ### 

## chosen parameters and % choosing job 1
open(outpath*"c.tex", "a+") do file
    write(outpath*"c.tex", 
        "After tinkering around, I find parameters "*
        L"$ \theta = ($"*latexify(θ_0.π_1)*L"$,\;$"
                        *latexify(θ_0.π_1)*L"$,\;$"
                        *latexify(θ_0.μ_1)*L"$,\;$"
                        *latexify(θ_0.μ_2)*L"$,\;$"
                        *latexify(θ_0.σ_1)*L"$,\;$"
                        *latexify(θ_0.σ_2)*L"$,\;$"
                        *latexify(θ_0.ρ)*L"$)$"
        *" which results in "*job1frac*"\\% of the population choosing occupation 1."
        )
end 



### part e ### 

## μ_1 and ρ estimates
open(outpath*"e.p_estimates.tex", "a+") do file
    write(outpath*"e.p_estimates.tex", L"Estimating the parameters with MLE, I find $\hat\mu_1 =$"* mu_hat*L" and $\hat\rho =$"*rho_hat*".")
end



### part f ###  

## plotting the identification graphs
    # set plotting defaults
    plotfont = "Computer Modern"
    default(fontfamily = plotfont, 
            linewidth = 2,
            framestyle = :box, 
            label = nothing, 
            grid = false,
            # thickness_scaling =1.3,
            size = (600,500))
    scalefontsizes(1.2)

# loop twice because i want to make one graph for μ_1, and one for ρ
for p = 1:1:2
    # set some loop specific variables 
    if p == 1
        gname = L"$\mu_1$"              # graph name for mu
        fname = "mu"                    # file name for mu
        b  = [0, res.minimizer[2]]      # create a vector that leaves one of the
        w  = θ_0.μ_1                    #   parameters fixed
        st = 0.4                        # start for the loop
        en = 1.5                        # end for the loop
        ysize = [1900, 3000]            # y coordinates size
        xsize = [0.5, en]               # x coordinates size
    else
        gname = L"$\rho$"
        fname = "rho"
        b  = [res.minimizer[1], 0.0]
        w  = θ_0.ρ
        st = -1.0
        en = 1.0
        ysize = [1850,2000]
        xsize = [-0.5,1.0]
    end 


x  = [] # stores parameter value
y  = [] # stores likelihood value 

for i = st:0.025:en     # loop through a bunch of potential mu or rho options
                        # and calculate the likelihood, then add that likelihood
                        # and the value calculated to x and y, which is what 
                        # i will use to plot 
    # change the value of one spot in b:
    b[p] = i 

    l = ll(b)

    # add to vectors
    append!(x, i) 
    append!(y, l)
end

# initialize the plot 
plot(title = "identification of "*gname, 
     xlabel = gname, 
     ylabel = "-likelihood",
     ylims = ysize,
     xlims = xsize)

# add a scatter plot of the likelihoods to the existing plot 
scatter!(x,y, label = "likelihoods")

# z is the estimated value of the parameter
z = res.minimizer[p]
# add a vertical line to represent the estimated parameter i originally found
vline!([z], label = "estimated "*gname)

# add a vertical line to represent the true parameter 
vline!([w], label = "true "*gname)

# save the figure 
savefig(outpath*fname*"_id.png")
end


### part g ### 

##table comparing data with model estimates

# define the rows ...
#   now i know there is a better way to do this, but i am lazy 
r1 = [L"\mu_1", θ_0.μ_1, θ_est.μ_1]
r2 = [L"\rho", θ_0.ρ, θ_est.ρ]
r3 = [L"\textrm{\% in job 1}", job1frac, job1frac_est]
r4 = [L"mean $w_1$", mean_w_1, mean_w_1_est]
r5 = [L"\sigma_1", std_w_1, std_w_1_est]
r6 = [L"mean $w_2$", mean_w_1, mean_w_1_est]
r7 = [L"\sigma_2", std_w_1, std_w_1_est]

ghead  = ["", "\\textbf{data}", "\\textbf{model}"]
gtable = latexify(r1, r2, r3, r4, r5, r6, r7, 
                    env        = :table, 
                    transpose  = true, 
                    head       = ghead,
                    adjustment = :r)

open(outpath*"g.table.tex", "a+") do file
    write(outpath*"g.table.tex", 
            "\\begin{table}[!h]\n\\centering\n \\caption{} \\;"*gtable*"\\end{table}")
end


## part h : counterfactuals 

    # minimum wage amount:
    open(outpath*"h.mw.tex", "a+") do file
        write(outpath*"h.mw.tex", 
                L"\underline{w_1} ="*latexify(mw)*".")
    end

    # table... modify the g table rows 
    r3 = [r3[3], job1frac_cf]
    r4 = [r4[3], mean_w_1_cf]
    r5 = [r5[3], std_w_1_cf]
    r6 = [r6[3], mean_w_2_cf]
    r7 = [r7[3], std_w_2_cf]
    hhead = [ "\\textbf{model}", "\\textbf{counterfactual}"]
    hside = [ "\\% in job 1", L"mean $w_1$", L"\sigma_1", L"mean $w_2$", L"\sigma_2"]

    htable =     latexify(r3,r4,r5,r6,r7, 
                 side       = hside, 
                 head       = hhead,
                 env        = :table,
                 transpose  = true,
                 adjustment = :r)

    open(outpath*"h.table.tex", "a+") do file
        write(outpath*"h.table.tex", 
                "\\begin{table}[!h]\n\\centering\n \\caption{} \n"*htable*"\\end{table}")
    end

## nice scatters for h 
# plot modeled wages and counterfactuals for people who chose job 1 
scatter(data_cf[data_cf.d .== 1, :w_1], data_cf[data_cf.d .== 1, :w_2])
# for job 2:
scatter!(data_cf[data_cf.d .== 0, :w_1], data_cf[data_cf.d .== 0, :w_2])

# plot modeled wages and counterfactuals for people who chose job 1 (now with MW)
scatter(data_cf[data_cf.d_cf .== 1, :w_1cf], data_cf[data_cf.d_cf .== 1, :w_2])
# for job 2:
scatter!(data_cf[data_cf.d_cf .== 0, :w_1cf], data_cf[data_cf.d_cf .== 0, :w_2])
