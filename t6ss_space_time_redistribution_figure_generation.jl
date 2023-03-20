using Pkg; Pkg.activate(".")
using Telegraph
using RandomWalker
using T6SSModellingStochasticTimerRW 




function pre_defined_params()
        #hrange = range(0,4,length=30)
        Δt = 0.0001
        Δx = 1
        T = 10
        X = 20
        aspect = 1
        boundary = "no_flux"
        simulation_iterations = 4
        parameter_iterations = 30
        λ₀ = 0.1
        λ₁ = 1
        h = 1
        dif_min = 0.0049
        dif_max = 0.1
        λmax = 100
        hmax = 10
        amax = 4
        data_root = "data/"
        input_values = T6ssDataGenerateInput(
                Δt,Δx,T,X,aspect,boundary,
                simulation_iterations,parameter_iterations,
                λ₀,λ₁,h,dif_min,dif_max,λmax,hmax,amax,data_root)
        return input_values
end

function data_path_filenames(data_numeric_label::Int)
    input_values = pre_defined_params()
    @unpack Δt, Δx, T, X, aspect,boundary,simulation_iterations,parameter_iterations,λ₀,λ₁,h,dif_min,dif_max,λmax,hmax,amax,data_root = input_values
    iter = Iterations(simulation_iterations,parameter_iterations)
    parameter_span = "Span"
    iterations = lpad.(1:iter.parameter_iterations,2,"0")
    data_path_json_vec = [
        data_root*
        join_figure_number_letter(x,parameter_span)*
        "ParamIter"*
        string(z) 
            for x in data_numeric_label 
            for z in iterations] .* 
            ".json"
    return data_path_json_vec
end

function get_grouped_file_paths(input_values)
    
    grouped_file_paths = @chain input_values begin
            _.data_root
            find(_,1,2,"json") 
            sort(_)
        end
    return grouped_file_paths
end

function generate_iters_get_values() 
    iters_get_values = [
        (group = 1, data_type = "parameters", data_value = "λ₀", data_label = L"\lambda_0", data_measure = "",xaxis = L"d_T",yaxis = L"P(d_T)", dist_axis = L"\bar{d}_T"),
        (group = 2, data_type = "parameters", data_value = "h", data_label = L"h_0", data_measure = "",xaxis = L"d_T",yaxis = L"P(d_T)", dist_axis = L"\bar{d}_T"),
        (group = 3, data_type = "variables", data_value = "aspect", data_label = L"aspect", data_measure = "",xaxis = L"d_T",yaxis = L"P(d_T)", dist_axis = L"\bar{d}_T"),
        (group = 4, data_type = "parameters", data_value = "h", data_label = L"D_0 \> (\mu m^2/s)", data_measure = L"\mu m^2/s",xaxis = L"d_{T_{OC}}\>\mu m",yaxis = L"P(d_{T_{OC}})", dist_axis = L"\bar{d}_{T_{OC}}\>\mu m")]
    return iters_get_values
end

function generate_figure_3()
end

function figure_4_data(input_values)
    
    @unpack Δt, Δx, T, X, aspect,boundary,simulation_iterations,parameter_iterations,λ₀,λ₁,h,dif_min,dif_max,λmax,hmax,amax,data_root = input_values
    var = Variables(Δt, Δx, T, X, aspect,boundary)
    par =  Parameters(λ₀,λ₁,h)
    Δp = Δ(par,var)    
    dom = dimensions(var)
    iter = Iterations(simulation_iterations,parameter_iterations)
    λ₀ₘᵢₙ = 0.01
    λ₀ₘₐₓ = 10
    figure_number = 4
    λ₀_vec = range(λ₀ₘᵢₙ,λ₀ₘₐₓ,iter.parameter_iterations)
    λ₁_vec = ones(iter.parameter_iterations) .* λ₁
    parλ₀ = [Parameters(λ₀_vec[i],λ₁_vec[i],h) for i in 1:iter.parameter_iterations]
    Δparλ₀ = [Δ(p,var) for p in parλ₀]       
    
    

    data_path_json_vec = data_path_filenames(figure_number)
    

    function sol(var, Δp, dom, iter,data_path_json_vec)
        res = get_experimental_sample_dist_vecs(var, Δp, dom, iter)
        solu = SolutionVarParDom(var,Δp,dom,iter,res.experimental,res.sample)
        return write_solution_to_file(solu,data_path_json_vec)
    end
    
    for i in 1:iter.parameter_iterations
        sol(var, Δparλ₀[i], dom, iter,data_path_json_vec[i])
    end
end

function generate_figure_4_a(input_values)
    @unpack Δt, Δx, T, X, aspect,boundary,simulation_iterations,parameter_iterations,λ₀,λ₁,h,dif_min,dif_max,λmax,hmax,amax,data_root = 
    input_values
    vars = Variables(Δt, Δx, T, X, aspect,boundary)
    par =  Parameters(λ₀,λ₁,h)
    Δp = Δ(par,vars)
    iter = Iterations(simulation_iterations,parameter_iterations)
    λ₀_vec = range(0,.05,iter.parameter_iterations)
    parameter_colours = [colorant"#d471d1", colorant"#60dce5"]
    x = t⃗(vars)

    # Show two generic time series
    par =  map(x -> Parameters(x,λ₁,h),[λ₀_vec[10],λ₀_vec[end-1]])
    Δp = map(x -> Δ(x,vars),par)
    y = map(x->get_state_time_series(vars,x),Δp)
    size_x = size(x,1)
    xy12 = [(x[i],y[j][i]) for i in 1:size_x, j in 1:2]

    fig4a = Figure(resolution=(800,800))
    fontsize_theme = Theme(fontsize = 35)
    set_theme!(fontsize_theme)
    ga = fig4a[2, 1] = GridLayout()
    axtop = Axis(ga[1, 1],ylabel = L"s(t)",width = 512, height = 245,aspect=2)
    axbottom = Axis(ga[2, 1],
    width = 512, height = 256,aspect=2,
    xlabel = L"t",ylabel = L"s(t)",xlabelsize=35,ylabelsize=35)
    linkxaxes!(axbottom, axtop)
    lines!(axtop,xy12[:,1],color=parameter_colours[1])
    lines!(axbottom,xy12[:,2],color=parameter_colours[2])
    
    return fig4a
end

function generate_figure_4_b(iters_get_values)
    Δx = 0.1
    first_plot = "02"
    figure_4 = 4
    
    parameter_colours = [colorant"#d471d1", colorant"#60dce5"]

    # For everything except the last figure
    data_figsb = @chain figure_4 begin
        data_path_filenames(_)
        filter(x -> occursin("Iter$(first_plot).",x),_)[1]
        read_solution_from_memory(_,SolutionVarParDom)
    end
    
    
    data_figsb = @set data_figsb.experimental = data_figsb.experimental ./ (1/Δx)
    data_figsb = @set data_figsb.sample = data_figsb.sample ./ (1/Δx)
    data_figsb = @set data_figsb.domain = data_figsb.domain * Δx
    data_figsb = @set data_figsb.variables.Δx = data_figsb.variables.Δx ./ (1/Δx)

    
    figsb = view_distance_and_mean(data_figsb,iters_get_values[1],parameter_colours[1])
    return figsb
end

function generate_figure_4_c(input_values,iters_get_values)
    Δx = 0.1
    second_plot = lpad(input_values.parameter_iterations - 1,2,"0")
    figure_4 = 4

    parameter_colours = [colorant"#d471d1", colorant"#60dce5"]
    

    # For everything except the last figure
    data_figsc = @chain figure_4 begin
        data_path_filenames(_)
        filter(x -> occursin("Iter$(second_plot).",x),_)[1]
        read_solution_from_memory(_,SolutionVarParDom)
    end
    
    
    
    data_figsc = @set data_figsc.experimental = data_figsc.experimental ./ (1/Δx)
    data_figsc = @set data_figsc.sample = data_figsc.sample ./ (1/Δx)
    data_figsc = @set data_figsc.domain = data_figsc.domain * Δx
    data_figsc = @set data_figsc.variables.Δx = data_figsc.variables.Δx ./ (1/Δx)


    figsc = view_distance_and_mean(data_figsc,iters_get_values[1],parameter_colours[2])
    return figsc
end

function generate_figure_4_d(iters_get_values)
    Δx = 0.1
    λ₀ₘᵢₙ = 0.01
    λ₀ₘₐₓ = 10
    figure_number = 4
    λ₀_vec = range(λ₀ₘᵢₙ,λ₀ₘₐₓ,iter.parameter_iterations)
    figsd = @chain figure_number begin
        data_path_filenames(_) 
        read_solution_from_memory.(_,SolutionVarParDom)
    end

    theoretical = get_t6ss_walk_theoretical_dist.(figsd) 
    [i.parameters.λ₀ for i in figsd] |> sort
    param = λ₀_vec 
    exper = [mean(i.experimental) for i in figsd] ./ (1/Δx)
    sampl = [mean(i.sample) for i in figsd] ./ (1/Δx)
    theor = theoretical ./ (Δx)
    distance = (parameter = param, experimental = exper, sample = sampl,theoretical = theor)        


    control_colour = colorant"#d5b670"  # Medium yellow 
    simulation_color = colorant"#443b28" # Sangria
    theoretical_color = colorant"#d92121" # Maximum red
    small_parameter_color = colorant"#d471d1" # Magenta
    large_parameter_color = colorant"#60dce5" # Light cyan

    
    x = distance[:parameter]
    l = length(x)-1
    x2 = [x[2]]
    x3 = [x[l]]
    yexp = distance[:experimental]
    yexp2 = [yexp[2]]
    yexp3 = [yexp[l]]
    ysam = distance[:sample]
    theoretical = distance[:theoretical]
    figsdscat = Figure(resolution=(800,800))
    fontsize_theme = Theme(fontsize = 35)
    set_theme!(fontsize_theme)
    ax = Axis(figsdscat[2,1],
        width = 512, height = 512,aspect=1,
        xlabel = iters_get_values[1][:data_label],ylabel = iters_get_values[1][:dist_axis], xlabelsize=35, ylabelsize=35)
    scatter!(ax,x,ysam,color=control_colour)
    scatter!(ax,x,yexp,color=simulation_color)
    lines!(ax,x,theoretical,color=theoretical_color)
    scatter!(ax,x2,yexp2,markersize=30,color=(small_parameter_color,0.5))
    scatter!(ax,x3,yexp3,markersize=30,alpha=.1,color=(large_parameter_color,0.5))
    
    return figsdscat
end

function generate_figure_5_data(input_values)
    @unpack Δt, Δx, T, X, aspect,boundary,simulation_iterations,parameter_iterations,λ₀,λ₁,h,dif_min,dif_max,λmax,hmax,amax,data_root = 
            input_values
    var = Variables(Δt, Δx, T, X, aspect,boundary)
    par =  Parameters(λ₀,λ₁,h)
    dom = dimensions(var)
    iter = Iterations(simulation_iterations,parameter_iterations)
    D_vec = range(dif_min,dif_max,iter.parameter_iterations) 
    
    figure_number = 5
 
    data_path_json_vec = data_path_filenames(figure_number)
    
    # D_vec
    Δx = 0.1
    aspect = 1.6
    X = 2
    var = @set var.aspect = aspect
    dom = dimensions(var)
    parD = map(D_vec) do io    
        @set par.h = io
    end
   
    solutionD = map(parD) do io
        parDLitRate = @set io.h = round(LitRate(io.h,Δx),digits=0)
        Δp = Δ(parDLitRate,var)       
        get_experimental_sample_dist_vecs(var, Δp, dom, iter) * Δx 
    end

    var = @set var.Δx = Δx
    var = @set var.X = X
    dom = dimensions(var)
    sols = [SolutionVarParDom(var,parD[i],dom,iter,solutionD[i].experimental,solutionD[i].sample) for i in 1:iter.parameter_iterations]

    
    write_solution_to_file.(sols,data_path_json_vec)

end

function generate_figure_5_a(iters_get_values)

    first_plot = "02"
    figure_number = 5
    
    parameter_colours = [colorant"#d471d1", colorant"#60dce5"]

    figsa = @chain figure_number begin
        data_path_filenames(_)
        filter(x -> occursin("Iter$(first_plot).",x),_)[1]
        read_solution_from_memory(_,SolutionVarParDom)
        view_distance_and_mean(_,iters_get_values[4],parameter_colours[1])
    end
    
    return figsa
    
end
   
function generate_figure_5_b(input_values,iters_get_values)
    second_plot = lpad(input_values.parameter_iterations - 1,2,"0")
    figure_number = 5

    parameter_colours = [colorant"#d471d1", colorant"#60dce5"]
    
    figsb = @chain figure_number begin
        data_path_filenames(_)
        filter(x -> occursin("Iter$(second_plot).",x),_)[1]
        read_solution_from_memory(_,SolutionVarParDom)
        view_distance_and_mean(_,iters_get_values[4],parameter_colours[2])
    end

    return figsb
    
end

function generate_figure_5_c(iters_get_values)
    figure_number = 5
    first_D_value = 0.0049

    figsd_data = @chain figure_number begin
        data_path_filenames(_)
        read_solution_from_memory.(_,SolutionVarParDom)
    end
    

    D_param = @chain figsd_data begin
                map(x-> x.parameters.h,_)
        end

    l = length(D_param)
    first_point = findall(d -> d==first_D_value,D_param)
    second_point = l-3

    theoretical = get_t6ss_walk_theoretical_dist.(Ref(T6ssBiologicalInspired()),figsd_data)

    sols_plot = @chain figsd_data begin
            map(x -> (
                    get_value(
                    x,
                    iters_get_values[4][:data_type], 
                    iters_get_values[4][:data_value]),
                    mean(x.experimental),
                    mean(x.sample)),
                    _)
                    get_solutions_vector(_,theoretical)
    end


    control_colour = colorant"#d5b670"  # Medium yellow 
    simulation_color = colorant"#443b28" # Sangria
    theoretical_color = colorant"#d92121" # Maximum red
    small_parameter_color = colorant"#d471d1" # Magenta
    large_parameter_color = colorant"#60dce5" # Light cyan



    x2 = D_param[first_point]
    x3 = D_param[second_point]
    yexp = sols_plot[:experimental]
    yexp2 = yexp[first_point]
    yexp3 = yexp[second_point]
    
    ysam = sols_plot[:sample]
    theoretical = sols_plot[:theoretical]
    figsd = Figure(resolution=(800,800))
            fontsize_theme = Theme(fontsize = 35)
            set_theme!(fontsize_theme)
            ax = Axis(figsd[2,1],
            width = 512, height = 512,aspect=1,
            xlabel = iters_get_values[4][:data_label],ylabel = iters_get_values[4][:dist_axis],xlabelsize=35,ylabelsize=35)
            scatter!(ax,D_param,ysam,color=control_colour)
            scatter!(ax,D_param,yexp,color=simulation_color)
            lines!(ax,D_param,theoretical,color=theoretical_color)
            scatter!(ax,x2,yexp2,markersize=20,color=(small_parameter_color,0.5))
            scatter!(ax,x3,yexp3,markersize=20,alpha=.1,color=(large_parameter_color,0.5))
    
            figsd
end

"""
    Figure 4:
    1. Generic time series
    2. Small value of λ₀
    3. Large value of λ₀
    4. Range of λ₀ and extpected distance travelled
"""
function generate_figure_4()
    input_values = pre_defined_params()
    iters_get_values = generate_iters_get_values()
    generate_figure_4_data(input_values)
    figsa = generate_figure_4_a(input_values)
    figsb = generate_figure_4_b(iters_get_values)
    figsc = generate_figure_4_c(input_values,iters_get_values)
    figsd = generate_figure_4_d(iters_get_values)    


    return (a = figsa,b = figsb,c=figsc,d=figsd)
end

"""
    Figure 5:
    1. Small value of D
    2. Large value of D
    3. Range of D and extpected distance travelled
"""
function generate_figure_5()
    input_values = pre_defined_params()
    iters_get_values = generate_iters_get_values()
    generate_figure_5_data(input_values)
    figsa = generate_figure_5_a(iters_get_values)
    figsb = generate_figure_5_b(input_values,iters_get_values)
    figsc = generate_figure_5_c(iters_get_values)

    return (a = figsa,b = figsb,c=figsc)
end




input_values = pre_defined_params()
@unpack Δt, Δx, T, X, aspect,boundary,simulation_iterations,parameter_iterations,λ₀,λ₁,h,dif_min,dif_max,λmax,hmax,amax,data_root = 
            input_values
var = Variables(Δt, Δx, T, X, aspect,boundary)
par =  Parameters(λ₀,λ₁,h)
Δp = Δ(par,var) 
dom = dimensions(var)


telegraph_walker = get_all_walker_position(var,Δp,dom)
telegraph_walker.states
telegraph_walker.walk
get_all_indices(telegraph_walker.states)
get_indices(state_time_series,t⃗)
get_times(gi::telegraph_points,t⃗,s₀)







# Plot 3 rows by 2 columns
# p11 p12
# p21 p22
# p31 p32
# p11 := Telegraph process with showing the ability to find where the states change
# p21 := Time series of random walk in each direction
# p31 := Full random walk
# p12 := Histograms of time in state = 1 and s = 0, with theoretical distribution.
# p12 := Random walk in 2D with scatter locations at time states according to state = 0
# p22 := Position of several random walks, all starting from (0,0) include the marginal histogram
# p32 := Distance histogram taken from positions

λ₀ = .1
λ₁ = .5

//#region RUNNING THE MODEL
    function walk_position(T,r,Δt,λ₀,λ₁,domain,aspect)
        telegraph = []
        ww = []

        t = rand([0,1])
        w11 = Walker2D(0,0)
        λ₀Δt = λ₀*Δt
        λ₁Δt = λ₁*Δt
        rΔt = r*Δt
        width = domain
        length = aspect*domain

        t⃗ = range(Δt,T,step=Δt)
        st⃗ = size(t⃗,1)

        push!(telegraph,t)
        push!(ww,w11)


        for i in 2:st⃗
            t = Telegraph.update(t,λ₀Δt,λ₁Δt)
            push!(telegraph,t)
            w11 = RandomWalker.updateperiod(w11,stepping(rΔt),width,length)
            push!(ww,w11)
        end

        t₁ = telegraph[1]
        gi = Telegraph.get_indices(telegraph,t⃗)
        ti = Telegraph.get_times(gi,t⃗,t₁)

        return Dict(
            "gi" => gi,
            "ti" => ti,
            't' => telegraph,
            'w' => ww,
            'x' => (ww[1].x,ww[end].x),
            'y' => (ww[1].y,ww[end].y))
    end



    function walk_deets(walk_pos)
        W = walk_pos
        dy = abs(W['y'][2]-W['y'][1])
        dy = dy >  domain/2 ? domain - dy : dy
        dx = abs(W['x'][2]-W['x'][1])
        dx = dx >  domain/2 ? domain - dx : dx
        dis = dx + dy

        res = Dict(
            "pos" => Dict('x' => W['x'][2], 'y' => W['y'][2]),
            "dis" => dis
        )

        return res
    end
    

    # Compute the telegraph several times to see histogram of times
  


    
    # Run the model once for plots p11-p31
    solm = ModelT6SSTelegraphRandomWalker(;λ₀Δt = 0.2*Δt, λ₁Δt = 0.2*Δt)
    res = ModelStatisticsT6SSTelegraphRandomWalker(sol)
    sols(;kwargs...) = ModelStatisticsT6SSTelegraphRandomWalker(ModelT6SSTelegraphRandomWalker())
    RW_x_time_series = [i.x for i in sol[:random_walk]]
    RW_y_time_series = [i.y for i in sol[:random_walk]]
    RE_walk = [(i.x,i.y) for i in sol[:random_walk]]

    res_stat_vec = [sols() for i in 1:N]
    tele_time = [i[:tᵢ] for i in res_stat_vec]

    time₀ = reduce(vcat,[i.t₀ for i in tele_time])
    time₁ = reduce(vcat,[i.t₁ for i in tele_time])

    state_times =  
        Dict(
            :state_0_time => time₀,
            :state_1_time => time₁
        )


    iterates = 5000
    cD = pbcControl(domain,10^6)

//#endregion


//#region PLOT p11 := Telegraph process with showing the ability to find where the states change
    p11 = plot(t⃗,solm[:telegraph],
        xlabel = "t",
        ylabel = "s", 
        label = "λ₀ = $(λ₀), \nλ₁ = $(λ₁)",
        c = "#446c1c",
        linewidth = 2,
        legend=:outertopright,dpi=600)
    scatter!(t⃗[sol["gi"].i₀],sol['t'][sol["gi"].i₀], label = "s = 0", c = "#bb93e3")
    scatter!(t⃗[sol["gi"].i₁],sol['t'][sol["gi"].i₁], label = "s = 1", c = "#ffc34d")
    savefig("telegraphseries.png")

    
//#endregion


//#region PLOT p21 := Time series of random walk in each direction    
    p21 = plot(t⃗,RW_x_time_series,
            legend=:outertopright,
            label = "x time series",dpi=600)
        plot!(t⃗,RW_y_time_series,label = "y time series")
        scatter!(t⃗[sol["gi"].i₁],RW_y_time_series[sol["gi"].i₁], label = "s = 1", c = "#ffc34d")
        scatter!(t⃗[sol["gi"].i₁],RW_x_time_series[sol["gi"].i₁], label = :none, c = "#ffc34d")
        scatter!(t⃗[sol["gi"].i₀],RW_y_time_series[sol["gi"].i₀], label = :none, c = "#bb93e3")
        scatter!(t⃗[sol["gi"].i₀],RW_x_time_series[sol["gi"].i₀], label = "s = 0", c = "#bb93e3")
        savefig("randomwalk_timeseries.png")
//#endregion

//#region PLOT p31 := Full random walk
    p31 = plot(
        RE_walk,
        xlabel = "x₁",
        ylabel = "x₂",
        label = "r=$(r), λ₂ = $(λ₀)",
        legend=:outertopright,
        xlims = (-domain÷2,domain÷2),
        ylims = (-domain÷2,domain÷2),
        dpi=600)
        savefig("randomwalk_telegraph_coupled.png")
//#endregion

plot(p11,p21,p31,layout=(3,1))


//#region PLOT p12 := Histograms of time in state = 1 and s = 0, with theoretical distribution.
    p12 = histogram(t0,
        title = "(4)",
        xlabel = "t",
        ylabel = "count (normalised)",
        normalize = true,
        title_loc=:left,
        linecolor = :match,
        ylims = (0,.5),
        c = "#ae2029",
        label = "s = 0"
        )
    plot!(t⃗,Exp(λ₁,t⃗), linewidth = 3,label = "t∼Exp(λ₁ = $(λ₁))")
    histogram(t1,
                normalize = true,
                linecolor = :match,
                ylims = (0,.5),
                c = "#148804",
                label = "s = 1",
                alpha = 0.3
            )
    plot!(t⃗,Exp(λ₂,t⃗), linewidth = 3,label = "t∼Exp(λ₂ = $(λ₂))")
//#endregion


//#region PLOT # p12

//#endregion




//#region PLOT # p22
   
    p22 = marginalhist(
        xy[:,1], xy[:,2], 
        fc=:plasma, 
        bins=-(domain÷2):(domain÷2),
        title=["(5)" "" ""],
        title_loc=:left,
        xlabel = "x₁",
        ylabel = "x₂",
        label = :none)#,
        #aspect_ratio=:auto)





//#endregion


//#region PLOT # p32

    # Single run with domain = 100
    
    p32 = plot(walkdist,
        normalize=true,
        seriestype=:stephist,
        title="(6)",
        titleloc=:left,
        xlabel="Distance",
        ylabel="Normalised Count",
        label="r = $(r), λ₂ = $(λ₂)",
        bins = 1:20)   
    plot!(cD,
        normalize=true,
        seriestype=:stephist,
        label="Random draw",
        bins = 1:20)

//#endregion


plot(p11,p12,p21,p22,p31,p32,
    layout = (3,2),
    dpi = 800,
    size = (900,900),
    legend=:outertopright)


savefig("/home/pushinglimits/Projects/Dundee_PhD/src/02_spatial-time_scripts/06_telegraph_timer_2d_random_walk/figures/fig-3_single-parameter-6-panels.png")
    
savefig(img_paper_folder*"fig-3_single-parameter-6-panels.png")