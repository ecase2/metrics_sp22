# emily case
# applied metrics quarter2 
# problem set 1 
# due april 22

# this file runs the whole analysis and writes tex snippets for my writeup

### write paths ###
rootpath = pwd()
outpath = joinpath(pwd(), "output/")



### load packages ###
using Parameters, Distributions, Random, Optim, Statistics, KernelDensity, DataFrames, Printf
using Latexify # to create latex formats from julia objects! 
    # change some default Latexify settings, especially the number format
    set_default(fmt      = "%2.2f",
                latex    = false,
                booktabs = true)
using LaTeXStrings # to create my own latex strings 
using Plots, StatsPlots # graphing 


# set the seed for reproducibility
import Random
Random.seed!(420)


### load functions ###
include("functions.jl")

# after tinkering around, let's choose these parameters to simulate some data
    θ_0 = parameters(1.0, 1.0, 0.95, .9, 0.2, 0.2, 0.3)
    # normalize π_1 = π_2 = 1 without loss of generality 
    # the other parameters are coming from tinkering around to get 60% 
    # of people to choose d = 1

# simulate data
    data = simdata(θ_0)

    # check that 60% choose d = 1:
    job1frac = latexify(100 * sum(data.d)/nrow(data))

    # and some other statistics for the table in part g
    mean_w_1 = mean(data[data.d .==1, :w])
    std_w_1  = std(data[data.d .==1, :w])
    mean_w_2 = mean(data[data.d .==0, :w])
    std_w_2  = std(data[data.d .==0, :w])



# minimize the negative log likelihood function 
b0 = [0.5,0.5]                      # initial guess
res = optimize(b -> ll(b), b0)
    
    # save minimizers 
    mu_hat  = latexify(res.minimizer[1]; fmt = "%2.3f" )
    rho_hat = latexify(res.minimizer[2]; fmt = "%2.3f" )



# simulate new data with estimated parameters
θ_est = parameters(1.0, 1.0, res.minimizer[1], .9, 0.2, 0.2, res.minimizer[2])
data_est = simdata(θ_est)

    # calculate the statistics 
    job1frac_est = 100*mean(data_est.d)
    mean_w_1_est = mean(data_est[data_est.d .==1, :w])
    std_w_1_est  = std(data_est[data_est.d .==1, :w])
    mean_w_2_est = mean(data_est[data_est.d .==0, :w])
    std_w_2_est  = std(data_est[data_est.d .==0, :w])


### counterfactual experiment ### 

mw = 2.45
data_cf = data_est
data_cf[!, :w_1cf] .= 0.0
data_cf[!, :w_cf]  .= 0.0

for i in 1:nrow(data_est)
    data_cf.w_1cf[i] = max(mw, data_cf.w_1[i])
    data_cf.w_cf[i]  = max(data_cf.w_1cf[i], data_cf.w_2[i])
end

data_cf[!, :d_cf]  .= data_cf.w_1cf .>= data_cf.w_2
data_cf[!, :switch].= data_cf.d .!= data_cf.d_cf
data_cf.d_cf = convert(Vector{Int64}, data_cf.d_cf)
data_cf.switch = convert(Vector{Int64}, data_cf.switch)

    # calculate the statistics 
    job1frac_cf = 100* mean(data_cf.d_cf)
    mean_w_1_cf = mean(data_cf[data_cf.d_cf .==1, :w_cf])
    std_w_1_cf  = std(data_cf[data_cf.d_cf .==1, :w_cf])
    mean_w_2_cf = mean(data_cf[data_cf.d_cf .==0, :w_cf])
    std_w_2_cf  = std(data_cf[data_cf.d_cf .==0, :w_cf])


### run the tables and graphs ###
include("texsnippets.jl")
