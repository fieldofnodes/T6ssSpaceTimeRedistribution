parameter_colours = [colorant"#d471d1", colorant"#60dce5"] 
simulation_iterations = 4
parameter_iterations = 49
iter = Iterations(simulation_iterations,parameter_iterations) 

Δt = 0.0001
Δx = 1
T = 10
X = 20
aspect = 1.6
boundary = "no_flux"
vars = Variables(Δt, Δx, T, X, aspect,boundary) # set variables to Variable struct
dom = dimensions(vars) # get dimensions of domain stored to Domain struct

Literature_scale = 2.7 # Ratio 1:2.7 of TssB:TssL

λ₀ = 1/60
λ₁ = λ₀*Literature_scale
dif_min = 1E-3#0.0049
dif_max = 0.1
Δx = 0.1  # need to add in later
D⃗ = @chain range(dif_min,dif_max,iter.parameter_iterations) begin
    vcat(_,0.0049)
    sort(_)    
end # Set range of the diffusion

h⃗ = round.(LitRate.(D⃗,Δx),digits=4) # Set range for h based on diffusion (D⃗) from literature
par = map(h -> Parameters(λ₀,λ₁,h),h⃗)
Δp = map(p -> Δ(p,vars),par) 



# Update Δt according to Db and Δx
function Δt_func(φ,Δx,Db,var::Variables)
    ϵ = 1e-6
    var = @set var.Δt = round((φ*Δx^2)/(Db) - ϵ,digits = 5)
    return var
end
φ = 1e-2
vars = map(Db -> Δt_func(φ,Δx,Db,vars),D⃗)


results = map((v,p) -> get_experimental_sample_dist_vecs(T6ssBiologicalInspired(),v, p, dom, iter), vars, Δp) .* Δx 

vars = [@set i.Δx = Δx for i in vars] # Re-set Δx
vars = [@set i.X = Int(X*Δx) for i in vars] # Re-set X
dom = [dimensions(i) for i in vars] # Upate dimensions
par = map(D -> Parameters(λ₀,λ₁,D),D⃗) # Update parameters

sols = [SolutionVarParDom(vars[i],par[i],dom[i],iter,results[i].experimental,results[i].sample) for i in 1:iter.parameter_iterations+1] # Convert to struct # account for special D


# Set path to write results to file
path_figure_6d = data_root .* ["Figure6SpanParamIter$(i).json" for i in 1:length(sols)]

# Write results to file
write_solution_to_file.(sols,path_figure_6d)


#=
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