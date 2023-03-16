################################################################
# File          : General model exploration
# Author        : Jonathan Miller
# Date created  : 20220509
# Aim           : To produce model results for observation
################################################################


################################################################
# Load parameters and variables
################################################################
Δt = 0.01
Δx = 1
bioΔx = 0.1
T = 200
X = 20
aspect = 1.6
boundary = "no_flux"
simulation_iterations = 4
parameter_iterations = 30
λ₀ = 0.017
λ₁ = 0.045
dif_base = 0.05
h = LitRate(dif_base,0.1)
state_0_colour = colorant"#2a498f" # Sangria
state_1_colour = colorant"#d5b670"  # Medium yellow 
time_series_color = colorant"#4b5258" # Maximum red

################################################################
# Set structs
################################################################
vars = Variables(Δt, Δx, T, X, aspect,boundary)                 # set variables to Variable struct
par =  Parameters(λ₀,λ₁,h)                                      # Set parameter values to Parameter struct
Δp = Δ(par,vars)                                                # Convert parameters to be scaled by Δt
dom = dimensions(vars)                                          # get dimensions of domain stored to Domain struct
iter = Iterations(simulation_iterations,parameter_iterations)   # Set iteration variables to Iterations struct
parameter_colours = [colorant"#d471d1", colorant"#60dce5"]      # Set colors
bio_vars = Variables(Δt, bioΔx, T, X*bioΔx, aspect,boundary) 
bio_dom = dimensions(bio_vars)  

################################################################
# Run simulation for figure 3 a,c,d
# a : Simple time series
# b : Expected waiting times
# c : Random walk over time 
# d : Random walk
################################################################


t6ss_model = get_all_walker_position(vars,Δp,dom)        
time_vec = t⃗(vars)      
indices    = get_indices(t6ss_model.states,time_vec)


wₓ₁ = [i[1] for i in RandomWalker.position.(t6ss_model.walk)] ./ (1/bioΔx)
wₓ₂ = [i[2] for i in RandomWalker.position.(t6ss_model.walk)] ./ (1/bioΔx)

Exp(λ,t) = (λ) .* exp.(-λ .* t) # get exponential distribution

function get_waiting_times(vars,Δp)
    
    #state_time_series = get_state_time_series(vars,par)
    state_time_series = get_state_time_series(vars,Δp)
    while all(state_time_series .== 0) || all(state_time_series .== 1)
        state_time_series = get_state_time_series(vars,Δp)
    end

    sz = size(state_time_series,1)
    last = state_time_series[end]
    last_indice_to_keep = []
    for i in sz:-1:1
        if state_time_series[i] == last
            continue
        elseif state_time_series[i] != last && state_time_series[i+1] == last
            push!(last_indice_to_keep,i) 
            break
        else
            #nothin
        end
    end


    state_time_series = state_time_series[1:last_indice_to_keep[1]]

    inds = get_all_indices(state_time_series)
    diff_inds = diff(inds) .* vars.Δt

    if state_time_series[1] == 0
		t₀ = diff_inds[1:2:end]
		t₁ = diff_inds[2:2:end]
	# If first state is basal
	elseif state_time_series[1] == 1
		t₀ = diff_inds[2:2:end]
		t₁ = diff_inds[1:2:end]
    else
        #nothing
	end

    return telegraph_time_dist(t₀,t₁)
end



times_per_state = [get_waiting_times(vars,Δp) for i in 1:10^5]


time_state_0 = @chain times_per_state begin
    reduce(vcat,[i.t₀ for i in _]) 
    filter(x -> x < vars.T,_)
end
    
time_state_1 = @chain times_per_state begin
    reduce(vcat,[i.t₁ for i in _]) 
    filter(x -> x < vars.T,_)
end
    


    


################################################################
# a : Simple time series
################################################################
fig3a = Figure(resolution=(800,800))
    fontsize_theme = Theme(fontsize = 35)
    set_theme!(fontsize_theme)
    ax = Axis(fig3a[1,1],
        width = 512, height = 512,aspect=1,
        xlabel = L"t", ylabel = L"s(t)",xlabelsize=35,ylabelsize=35,yticks = ([0,1]))
    ts = lines!(ax,time_vec,Int.(t6ss_model.states),color=time_series_color)
    s0 = scatter!(ax,time_vec[indices.i₀],Int.(t6ss_model.states[indices.i₀]),color=state_0_colour,markersize=12)
    s1 = scatter!(ax,time_vec[indices.i₁],Int.(t6ss_model.states[indices.i₁]),color=state_1_colour,markersize=12)
    Legend(fig3a[1,1],[[ts,s0],[ts,s1]],[L"s = 0",L"s = 1"],halign=:right,valign=:top)
fig3a
################################################################
# b : Test of exponential waiting times
################################################################
fig3b = Figure(resolution=(800,800))
    fontsize_theme = Theme(fontsize = 35)
    set_theme!(fontsize_theme)
    ax = Axis(fig3b[1,1],
        width = 512, height = 512,aspect=1,
        xlabel = L"\tau", ylabel = L"P(\tau)",xlabelsize=35,ylabelsize=35)
    hλ₀ = hist!(ax,time_state_0, bins = 100,normalization = :pdf,color=(state_0_colour,0.5))
    lines!(ax,time_vec,Exp(par.λ₀,time_vec),color=:red)
    hλ₁ = hist!(ax,time_state_1, bins = 100,normalization = :pdf,color=(state_1_colour,0.5))
    lines!(ax,time_vec,Exp(par.λ₁,time_vec),color=:red)
    Legend(fig3b[1,1], [hλ₀, hλ₁], [L"\lambda_0", L"\lambda_1"],halign=:right,valign=:top)
fig3b
################################################################
# c : Random walk over time
################################################################
fig3c = Figure(resolution=(800,800))
    fontsize_theme = Theme(fontsize = 35)
    set_theme!(fontsize_theme)
    ax = Axis(fig3c[1,1],
        width = 512, height = 512,aspect=1,
        xlabel = L"t", ylabel = "",xlabelsize=35,ylabelsize=35)
    xwalk = lines!(ax,time_vec,wₓ₁,color=(state_0_colour,0.5))
    ywalk = lines!(ax,time_vec,wₓ₂,color=(state_1_colour,0.5))
    xstate = scatter!(ax,time_vec[indices.i₀],wₓ₁[indices.i₀],color=state_0_colour,markersize=12)
    ystate = scatter!(ax,time_vec[indices.i₁],wₓ₂[indices.i₁],color=state_1_colour,markersize=12)
    ylims!(-bio_dom.length/2,bio_dom.length/2)
    Legend(fig3c[1,1], [[xwalk,xstate], [ywalk,ystate]], [L"x(t)", L"y(t)"],halign=:right,valign=:top)
fig3c
################################################################
# d : Random walk
################################################################
fig3d = Figure(resolution=(800,800))
    fontsize_theme = Theme(fontsize = 35)
    set_theme!(fontsize_theme)
    ax = Axis(fig3d[1,1],
        width = 512, height = 512,aspect=1,
        xlabel = L"x", ylabel = L"y",
        xlabelsize=35,ylabelsize=35,
        xticks =([-1,0,1]))
    rw = lines!(ax,wₓ₁,wₓ₂,color=time_series_color)
    scatter!(ax,wₓ₁[indices.i₀],wₓ₂[indices.i₀],color=state_0_colour,markersize=12)
    scatter!(ax,wₓ₁[indices.i₁],wₓ₂[indices.i₁],color=state_1_colour,markersize=12)
    xlims!(-bio_dom.width/2,bio_dom.width/2)
    ylims!(-bio_dom.length/2,bio_dom.length/2)
    Legend(fig3d[1,1], [rw], [L"RW"],halign=:right,valign=:top)
fig3d
################################################################
# Save figures to file
################################################################

figure2a_path = "/home/fieldofnodes/Projects/Dundee_PhD/documentation/ModellingStochasticTimerRandomMotionT6SS/images/FiguresPaper/Figure2/Figure2a.pdf"
figure2b_path = "/home/fieldofnodes/Projects/Dundee_PhD/documentation/ModellingStochasticTimerRandomMotionT6SS/images/FiguresPaper/Figure2/Figure2b.pdf"
figure2c_path = "/home/fieldofnodes/Projects/Dundee_PhD/documentation/ModellingStochasticTimerRandomMotionT6SS/images/FiguresPaper/Figure2/Figure2c.pdf"
figure2d_path = "/home/fieldofnodes/Projects/Dundee_PhD/documentation/ModellingStochasticTimerRandomMotionT6SS/images/FiguresPaper/Figure2/Figure2d.pdf"
save(figure2a_path,fig3a)
save(figure2b_path,fig3b)
save(figure2c_path,fig3c)
save(figure2d_path,fig3d)



