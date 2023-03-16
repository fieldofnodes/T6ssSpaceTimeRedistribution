####################
#### Iterations ####
####################
L = 30
N = 4


####################################
#### File System Configurations ####
####################################

# Storage locations: user defined
fig_folder = "/home/pushinglimits/Projects/Dundee_PhD/documentation/ModellingStochasticTimerRandomMotionT6SS/images/FiguresPaper/"
data_root = "/home/pushinglimits/Projects/Dundee_PhD/data/02_telegraph_data/"

# Figure number and sub-numbers
fig_num = 5
fig_sub_num = "d"




###################
#### Variables ####
###################

# Temporal
Δt = 0.0001
duration = 10
t⃗ = range(0,duration,step = Δt)

# Spatial
Δx = 0.1
aspect = range(0.5,10,L)
xwidth = 20
ylength = map(l -> dimensions(xwidth,aspect = l)[:ylength],aspect) 
boundary = "no_flux"
x₀ = 0
y₀ = 0
#walker = get_random_position(xwidth,ylength;step=1)




###################
#### Paramters ####
###################
λ₀ = 0.1
λ₁ = 10
h = 1
λ₀Δt = XΔt(λ₀,Δt)
λ₁Δt = XΔt(λ₁,Δt)
hΔt = XΔt(h,Δt)






