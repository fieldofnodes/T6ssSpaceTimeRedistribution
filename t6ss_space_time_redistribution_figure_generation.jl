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
        dif_max = 2.5
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
    dom = dimensions(vars)
    iter = Iterations(simulation_iterations,parameter_iterations)
    λ₀_vec = range(0,.05,iter.parameter_iterations)
    h_vec = range(0,hmax,iter.parameter_iterations)
    a_vec = range(0,amax,iter.parameter_iterations)
    D_vec = range(dif_min,dif_max,iter.parameter_iterations) 
    parameter_colours = [colorant"#d471d1", colorant"#60dce5"]
    x = t⃗(vars)

    # Show two generic time series
    par =  map(x -> Parameters(x,λ₁,h),[λ₀_vec[10],λ₀_vec[end-1]])
    Δp = map(x -> Δ(x,vars),par)
    y = map(x->get_state_time_series(vars,x),Δp)
    xy12 = [(x[i],y[j][i]) for i in 1:size(x,1), j in 1:2]

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

function generate_figure_4_b(grouped_file_paths,iters_get_values)
    Δx = 0.1
    first_plot = "02"
    
    parameter_colours = [colorant"#d471d1", colorant"#60dce5"]

    # For everything except the last figure
    data_figsb = @chain grouped_file_paths begin
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

function generate_figure_4_c(grouped_file_paths,input_values,iters_get_values)
    Δx = 0.1
    second_plot = lpad(input_values.parameter_iterations - 1,2,"0")
    parameter_colours = [colorant"#d471d1", colorant"#60dce5"]
    data_figsc = @chain grouped_file_paths begin
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

function generate_figure_4_d(grouped_file_paths,iters_get_values)
    sols_mem = @chain grouped_file_paths begin
        map(io -> read_solution_from_memory(io,SolutionVarParDom),_)
    end
    

    theoretical = map(x->get_t6ss_walk_theoretical_dist(x),sols_mem)

    figsd = @chain grouped_file_paths begin
        map(x-> read_solution_from_memory(x,SolutionVarParDom),_)
    end

    
    param = λ₀_vec 
    exper = [mean(i.experimental) for i in figsd] ./ (1/.1)
    sampl = [mean(i.sample) for i in figsd] ./ (1/.1)
    theor = theoretical
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
    figure_4_data(input_values)
    grouped_file_paths = get_grouped_file_paths(input_values)
    figsa = figure_4_a(grouped_file_paths)
    figsb = figure_4_b(grouped_file_paths)
    figsc = figure_4_c(grouped_file_paths,input_values)
    figsdscat = figure_4_d(grouped_file_paths)    

    save_figure(figsa,figa)
    save_figure(figsb,figb)
    save_figure(figsc,figc)
    save_figure(figsdscat,figd)

end



"""
    Not sure if using an IDE or should print figures
"""
//
        figure_root = "figures/"
        fig_numeric_label = 3
        fig_alph_label = ("b","c","d")
        figure_paths = [figure_root*
                append_forward_slash_figure(x)*
                join_figure_number_letter(x,y)
                for x in fig_numeric_label 
                for y in fig_alph_label] .* 
                ".pdf"

        figb,figc,figd = figure_paths
        
//












function generate_figure_3()

end




function generate_figure_5()
 
end