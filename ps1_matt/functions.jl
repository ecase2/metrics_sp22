### this is all my functions and structures ###


# create empty parameters 
mutable struct parameters      # mutable means we can go in and change them  
    π_1::Float64               # later
    π_2::Float64
    μ_1::Float64               # Float64 allows for decimals, have to say what
    μ_2::Float64               # type of parameters these are
    σ_1::Float64
    σ_2::Float64
    ρ::Float64
end




function simdata(θ::parameters; N = 1000)
    # this function simulates some data, given an input of parameters
        # N is defaulted to 1000 observations
        

    # create an empty dataframe for simulated data
        data = DataFrame(
            ϵ_1 = Float64[],
            ϵ_2 = Float64[],
            s_1 = Float64[],
            s_2 = Float64[],
            w_1 = Float64[],
            w_2 = Float64[],
            d   = Int[],
            w   = Float64[]
        )

    ## now the components we need for creating the data ##

    # create ϵ-distribution

        # covariance matrix
        σ_11 = θ.σ_1 * θ.σ_1
        σ_22 = θ.σ_2 * θ.σ_2
        σ_12 = θ.ρ * θ.σ_1 * θ.σ_2

        # epsilons are joint normal with this distribution: 
        ϵ_dist = MvNormal([0, 0], [σ_11 σ_12; σ_12 σ_22])

    # now populate data row by row
    for i in 1:N
        # draw person i's random epislons for both job types
        e1, e2 = rand(ϵ_dist)

        # use formula to create person i's skills in both jobs 
        s1 = exp.(θ.μ_1 + e1)
        s2 = exp.(θ.μ_2 + e2)

        # create wages for both jobs 
        w1 = θ.π_1 * s1
        w2 = θ.π_2 * s2

        # dummy for if occ 1 is chosen. they choose 1 when the wage
        # is higher 
        d = w1>=w2

        # then the wages that are observed to the econometrician are:
        w = d*w1 + (1-d)*w2

        # push these numbers to an observation in the dataframe 
        push!(data,[e1,e2,s1,s2,w1,w2,d,w])
    end
    # tell julia to spit out the data! 
    return data
end



function ll(b::Vector{Float64}; θ::parameters = θ_0, df=data) 
    # this function calculates the log likelihood given some parameters
        # b is a vector of μ_1 and ρ which we are optimizing over... have to 
        # separate it from the other parameters... probably a better way to 
        # do this but I personally have no idea, and this is my work around.

        # we will only pull the non-μ_1 and non-ρ parameters from the 
        # parameters struct. the default is θ_0, defined in main.jl!

        # the default dataframe (df) is data defined in main.jl! 

        # only need to plug in ll(b) because of the defaults 
    
    ll = 0              # initialize the log likelihood
    N = nrow(df)
    μ_1 = b[1]          # call the elements of b what they actually are!
    ρ   = b[2]

    # loop over everyone and add up their individual log likelihoods
    for i in 1:N
        w = df[i, :w]       # person i's observed wages
        d = df[i, :d]       # person i's observed job choice

        # separate the MLE function in to chunks to look cleaner
        A = ((θ.σ_1 / θ.σ_2)*(log(w/θ.π_2) - θ.μ_2) - ρ*(log(w/θ.π_1) -μ_1)) / (θ.σ_1 * sqrt(1-ρ^2))
        B = (1/θ.σ_1)*(log(w/θ.π_1) - μ_1)
        C = ((θ.σ_2 / θ.σ_1)*(log(w/θ.π_1) - μ_1) - ρ*(log(w/θ.π_2) - θ.μ_2)) / (θ.σ_2 * sqrt(1-ρ^2))
        D = (1/θ.σ_2)*(log(w/θ.π_2) - θ.μ_2)
       
        # person i's log likelihood is 
        lli = d*(log(cdf(Normal(), A)) + log(pdf(Normal(),B))) + (1-d)* (log(cdf(Normal(),C)) + log(pdf(Normal(),D))) 
        
        # add person i's lll to the total log likelihood 
        ll = ll +lli
    end
    # computer science nerds like to minimize, not maximize, so we negate ll:
    ll = - ll  
    
    # spit out the ll amount 
    return ll 
end