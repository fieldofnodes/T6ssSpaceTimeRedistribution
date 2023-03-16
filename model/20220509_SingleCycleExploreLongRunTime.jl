# Get a run time of time series of 




# Extract individual variable names from struct
@unpack Δt, Δx, T, X, aspect,boundary,simulation_iterations,parameter_iterations,λ₀,λ₁,h,dif_min,dif_max,λmax,hmax,amax,data_root = 
            input_values
vars = Variables(Δt, Δx, T, X, aspect,boundary) # set variables to Variable struct
par =  Parameters(λ₀,λ₁,h) # Set parameter values to Parameter struct
Δp = Δ(par,vars) # Convert parameters to be scaled by Δt
dom = dimensions(vars) # get dimensions of domain stored to Domain struct
#iter = Iterations(simulation_iterations,parameter_iterations) # Set iteration variables to Iterations struct
iter = Iterations(0,4) # Set iteration variables to Iterations struct
parameter_colours = [colorant"#d471d1", colorant"#60dce5"] 



Literature_scale = 2.7 # Ratio 1:2.7 of TssB:TssL
aspect = 1.6 # Rough ratio wit S. marcesces
Δx = 0.1 # Descretise space
vars = @set vars.aspect = aspect # go back to var once in function
dom = dimensions(vars)           # go back to var once in function


λ₀_min = 0.00791557  # Set minimum λ₀ from wolfram alpha
λ₀_max = 0.0158311 # Set maximum λ₀
λ₁_min = Literature_scale * λ₀_min # Set minimum λ₁
λ₁_max = Literature_scale * λ₀_max # Set maximum λ₁
λ⃗₀ = range(λ₀_min,λ₀_max,iter.parameter_iterations) # Set range for λ₀
λ⃗₁ = range(λ₁_min,λ₁_max,iter.parameter_iterations) # Set range for λ₁
λ⃗ = map((x,y) -> (x,y),λ⃗₀,λ⃗₁) # Set tuple of λ₀ and λ₁



D⃗ = range(dif_min,dif_max,iter.parameter_iterations) # Set range of the diffusion
h⃗ = round.(LitRate.(D⃗,Δx),digits=4) # Set range for h based on diffusion (D⃗) from literature
params_tuple = [(i[1],i[2],j) for i in λ⃗ for j in h⃗] # create tuple for each parameter λ₀,λ₁ and h
par_bio = map(io -> Parameters(io[1],io[2],io[3]),params_tuple) # input params_tuple into the Parameters struct
Δp = map(io -> Δ(io,vars),par_bio) # make parameters adjusted to Δt

iter = @set iter.parameter_iterations = length(par_bio) # Re-set iterations to match heatmap

### Measuring time series of single cycle model

single_shot = get_all_walker_position(T6ssBiologicalInspired(),vars,Δp[1],dom)

time_shot = size(single_shot[1],1) * Δt
t⃗_states = range(0,time_shot,length=size(single_shot[1],1))


f = Figure()
lines(f[1,1],t⃗_states,Int.(single_shot[:states]))
lines(f[1,2],single_shot[:walk])
f





time_taken = [@elapsed get_experimental_sample_dist_vecs(T6ssBiologicalInspired(),vars, Δp[5], dom, iter) for i in 1:100]
cumsumn_time_taken = cumsum(time_taken)

mean_time = sum(time_taken)/length(time_taken)

time_seconds = 10^4*16*mean_time #iterations per pixel times number of pixels times mean_time in second

time_seconds*(1/60)*(1/60) # 1 minute per 60 seconds * 1 hour per 60 seconds


f = Figure()
lines(f[2,1],1:100,time_taken)
hist(f[1,1],time_taken,normalization=:pdf)
lines(f[3,1],1:100,cumsumn_time_taken)
f



@time results = map(io -> get_experimental_sample_dist_vecs(T6ssBiologicalInspired(),vars, io, dom, iter), Δp) .* Δx # get results




