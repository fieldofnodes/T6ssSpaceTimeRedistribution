abstract type FunctionInput end

struct Variables <: FunctionInput
    Δx::Union{Vector,Dict,Tuple,NamedTuple,Float64,Int64,StepRangeLen}
    Δt::Union{Vector,Dict,Tuple,NamedTuple,Float64,Int64,StepRangeLen}
    x::Union{Vector,Dict,Tuple,NamedTuple,Float64,Int64,StepRangeLen}
    t::Union{Vector,Dict,Tuple,NamedTuple,Float64,Int64,StepRangeLen}
end

struct Parameters <: FunctionInput


end


"""
    Iterations struct
        Fields include: L::Int64 
                        N::Int64
        L is the number of points along a StepRangeLen
          to evaulate a parameter's range
        N is the number such that there are 10ᴺ iterations of the 
          function.
        Type is an input to solving the T6SS models.
"""
struct Iterations <: FunctionInput
    N::Int64
    L::Int64
end

# Storage locations: user defined
fig_folder = "/home/pushinglimits/Projects/Dundee_PhD/documentation/ModellingStochasticTimerRandomMotionT6SS/images/FiguresPaper/"
data_root = "/home/pushinglimits/Projects/Dundee_PhD/data/02_telegraph_data/"

# Figure number and sub-numbers
fig_num = 3
fig_sub_num = "b"




###################
#### Variables ####
###################

# Temporal
Δt = 0.001
duration = 60
t⃗ = range(0,duration,step = Δt)

t⃗ |> typeof

# Spatial
Δx = 0.1
aspect = 1
xwidth = 20
ylength = dimensions(xwidth,aspect = aspect)[:ylength] 
boundary = "no_flux"
x₀ = 0
y₀ = 0
walker = get_random_position(xwidth,ylength;step=1)




###################
#### Paramters ####
###################
λ₀ = .01
λ₁ = 10
h = 1
λ₀Δt = XΔt(λ₀,Δt)
λ₁Δt = XΔt(λ₁,Δt)
hΔt = XΔt(h,Δt)







