# Establish the relationship between λ₀ and D₀ (h for code)
# From literature a populatinon scan will show 1:2.7 ratio of TssB to TssL
# Assume that TssB can only be counted when it is co-localised with TssL
# Hence 
# TssB represents State 1
# TssL represents State 0
# Take the time total to be T, 
# Time in State 0 is TS₀ 
# Time in State 1 is TS₁
# T = TS₀ + TS₁
# TS₁ = T - TS₀
# From Philip 
# T = log₂/λ₀ + log₂/λ₁
# State 0 occurs 2.7 times more then State 1
# TS₀ = 2.7TS₁
# λ₀/(λ₀ + λ₁) = 2.7λ₀/(λ₀ + λ₁)
# Implies λ₀ = 2.7λ₁


# Extract individual variable names from struct
@unpack Δt, Δx, T, X, aspect,boundary,simulation_iterations,parameter_iterations,λ₀,λ₁,h,dif_min,dif_max,λmax,hmax,amax,data_root = 
            input_values
vars = Variables(Δt, Δx, T, X, aspect,boundary) # set variables to Variable struct
par =  Parameters(λ₀,λ₁,h) # Set parameter values to Parameter struct
Δp = Δ(par,vars) # Convert parameters to be scaled by Δt
dom = dimensions(vars) # get dimensions of domain stored to Domain struct
#iter = Iterations(simulation_iterations,parameter_iterations) # Set iteration variables to Iterations struct
iter = Iterations(4,4) # Set iteration variables to Iterations struct
parameter_colours = [colorant"#d471d1", colorant"#60dce5"] 



Literature_scale = 2.7 # Ratio 1:2.7 of TssB:TssL
aspect = 1.6 # Rough ratio wit S. marcesces
Δx = 0.1 # Descretise space
vars = @set vars.aspect = aspect # go back to var once in function
dom = dimensions(vars)           # go back to var once in function


λ₀_min = 0.01  # Set minimum λ₀
λ₀_max = 0.03 # Set maximum λ₀
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

@time results = map(io -> get_experimental_sample_dist_vecs(T6ssBiologicalInspired(),vars, io, dom, iter), Δp) .* Δx # get results





vars = @set vars.Δx = Δx # Re-set Δx
vars = @set vars.X = Int(X*Δx) # Re-set X
λ₀_bio = [i.λ₀ for i in par_bio]
λ₁_bio = [i.λ₁ for i in par_bio]
new_diff = [i.h*vars.Δx^2 for i in par_bio]
new_par_bio = [Parameters(λ₀_bio[i],λ₁_bio[i],new_diff[i]) for i in 1:size(par_bio,1)]
dom = dimensions(vars) # Upate dimensions
sols = [SolutionVarParDom(vars,new_par_bio[i],dom,iter,results[i].experimental,results[i].sample) for i in 1:iter.parameter_iterations] # Convert to struct


# Set path to write results to file
path_figure_6d = data_root .* ["Figure6SpanParamIter$(i).json" for i in 1:length(sols)]

# Write results to file
write_solution_to_file.(sols,path_figure_6d)

# Filter to λ₀ = 1/60
sol_lambda_1on60th = filter(x-> x.parameters.λ₀ == λ⃗₀[Int(floor(size(λ⃗₀,1)/2))], sols)



# Figure small D 
small_D = sol_lambda_1on60th[1]
@chain small_D begin
    view_distance_and_mean(_,iters_get_values[end],parameter_colours[1])
    save_figure(_,replace(figb[end], "Figure6b" => "Figure6a"))
end 



# Figure large D
large_D = sol_lambda_1on60th[end]
@chain large_D begin
    view_distance_and_mean(_,iters_get_values[end],parameter_colours[2])
    save_figure(_,replace(figb[end], "Figure6c" => "Figure6b"))
end 





theoretical = map(x->get_t6ss_walk_theoretical_dist(T6ssBiologicalInspired(),x),sol_lambda_1on60th)

@chain sol_lambda_1on60th begin
    map(x -> (
        get_value(
            x,
            iters_get_values[4][:data_type], 
            iters_get_values[4][:data_value]),
            mean(x.experimental),
            mean(x.sample)),
            _)
            get_solutions_vector(_,theoretical)
           view_scatter_mean(_,iters_get_values[4])
           save(figc[end],_)
end



# Biological figure heatmap (d)
# Compute mean and reshape into an array
mean_distance = @chain sols begin # Get mean distance and reshape into a matrix
    map(io -> mean(io.experimental),_)
    reshape(_,Int(sqrt(size(sols,1))),Int(sqrt(size(sols,1))))
end

max_dis = maximum(mean_distance)

# Plot results
fig = Figure(resolution=(800,800))
    fontsize_theme = Theme(fontsize = 22)
    set_theme!(fontsize_theme)
    ax = Axis(fig[2,1],
        width = 512, height = 512,aspect=1,
        ylabel = L"\lambda_0",xlabel = L"D_b",xlabelsize=30,ylabelsize=30)
    heatmap!(D⃗,λ⃗₀,mean_distance,colormap = [colorant"#d471d1", colorant"#60dce5"])
    Colorbar(fig[1, 1], limits = (0, max_dis), colormap = [colorant"#d471d1", colorant"#60dce5"],
    vertical = false, label = L"E(d)")
fig

# Save figure to file
save(figd[end],fig)




#=

###########################################################################
###########################################################################
###########################################################################
###########################################################################
### Measuring time series of single cycle model
single_cycle_time_series_walk_small_D = get_all_walker_position(T6ssBiologicalInspired(),vars,Δp[5],dom)
single_cycle_time_series_walk_large_D = get_all_walker_position(T6ssBiologicalInspired(),vars,Δp[8],dom)

### Plot the time series and the random walk 
x₁ = (1:size(single_cycle_time_series_walk_small_D[:states],1)) .* Δt
y₁ = convert.(Int64, single_cycle_time_series_walk_small_D[:states])
w₁ = single_cycle_time_series_walk_small_D[:walk]
x₂ = (1:size(single_cycle_time_series_walk_large_D[:states],1)) .* Δt
y₂ = convert.(Int64, single_cycle_time_series_walk_large_D[:states])
w₂ = single_cycle_time_series_walk_large_D[:walk]
fig = Figure(resolution = (800,800))
    #fontsize_theme = Theme(fontsize = 22)
    #set_theme!(fontsize_theme)
    ax1 = Axis(fig[1,1],
        width = 125, height = 125,aspect=1,
        xlabel = L"t",ylabel = L"s(t)",title = "D = 0.0049")
    ax2 = Axis(fig[1,2],
        width = 125, height = 125,aspect=1,
        xlabel = L"x",ylabel = L"y",title = "D = 0.0049")
    ax3 = Axis(fig[2,1],
        width = 125, height = 125,aspect=1,
        xlabel = L"t",ylabel = L"s(t)",title = "D = 2.5")
    ax4 = Axis(fig[2,2],
        width = 125, height = 125,aspect=1,
        xlabel = L"x",ylabel = L"y",title = "D = 2.5")
    lines!(ax1,x₁,y₁)
    lines!(ax2,w₁)
    lines!(ax3,x₂,y₂)
    lines!(ax4,w₂)
fig





# Run multiple times
dis_small_D = ThreadsX.map(x -> get_walker_distance(
    T6ssBiologicalInspired(),
    vars,
    Δp[5],
    dom).distance,1:10^iter.simulation_iterations).* Δx
        
dis_large_D = ThreadsX.map(x -> get_walker_distance(
    T6ssBiologicalInspired(),
    vars,
    Δp[8],
    dom).distance,1:10^iter.simulation_iterations) .* Δx
sample = get_sample_distribution(vars,dom,iter).* Δx

normal(y) = y ./ sum(y)
rng = set_range_iter(dom,vars).* Δx
dis_small_D_c = normal(get_count(dis_small_D,rng))
dis_large_D_c = normal(get_count(dis_large_D,rng))
control =  normal(get_count(sample,rng))
fig = Figure(resolution=(800,800))
    ax1 = Axis(fig[1,1],
        width = 250, height = 250,aspect=1,
        xlabel = L"d",ylabel = L"P(d)", title = "D = 0.0049")
    ax2 = Axis(fig[1,2],
        width = 250, height = 250,aspect=1,
        xlabel = L"d",ylabel = L"P(d)", title = "D = 2.5")
    barplot!(ax1,rng,control)
    #vlines!(ax1,mean(sample))
    barplot!(ax1,rng,dis_small_D_c)
    #vlines!(ax1,mean(dis_small_D))
    barplot!(ax2,rng,control)
    #vlines!(ax2,mean(sample))
    barplot!(ax2,rng,dis_large_D_c)
    #vlines!(ax2,mean(dis_large_D))
fig





###########################################################################
###########################################################################
###########################################################################
###########################################################################

=#