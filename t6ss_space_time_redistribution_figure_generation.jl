using Pkg; Pkg.activate(".")
using Telegraph
using RandomWalker
using T6SSModellingStochasticTimerRW 







input_values = pre_defined_params(5)
generate_figure_5_data(input_values)
iters_get_values = generate_iters_get_values() 
figsa = generate_figure_5_a(iters_get_values)
figsb = generate_figure_5_b(input_values,iters_get_values)
figsc = generate_fi 














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
    
        return figsd
    end





