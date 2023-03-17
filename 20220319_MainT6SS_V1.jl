####################
#### T6SS Model ####
####################


#########################################
#### Initialise project and packages ####
#########################################
# Initialise Julia project

using Pkg; Pkg.activate(".")

# Load packages needed
include("packages.jl")


T6SSModellingStochasticTimerRW

########################
#### Initiate Model ####
########################

# Load functions to interact with simulated data
# Load functions to set up structs and type needed
include("model/20220319_GetStructsTypes_V1.jl")

# Load functions to aid in file and naming convections
include("model/20220319_GetFileAndNamingFunc_V1.jl")

# Load helper functions
include("model/20220319_GetHelperFunc_V1.jl")

# Load walker helper functions
include("model/20220319_GetWalkerHelperFunc_V1.jl")

# Load functions to get walker positions
include("model/20220319_GetWalkerPositionsFunc_V1.jl")

# Load functions to get distances
include("model/20220319_GetDistanceFunc_V1.jl")

# Load function to get solutions
include("model/20220319_GetSolutionWalkerFunc_V1.jl")

# Load function to run simulations
include("model/20220319_RunSimulationSaveFile_V1.jl")

# Generate data function to save to file
include("model/20220325_GenerateT6ssData_V1.jl")

# Generate theoretical function for distance over a Parameter
include("model/20220405_GenerateTheoreticalData_V1.jl")


#######################
#### Initiate View ####
#######################
# Load view to visualise the walker Distances
include("view/20220319_ViewWalkerDistSolutionFunc_V1.jl")

# Load view to visualise multiple parameters
include("view/20220319_ViewMultipleParamsIters_V1.jl")

# Load view to visualise the distances
include("view/20220329_GetHistogramDistancesT6ss_V1.jl")


################################
#### Stipulate Input Values ####
################################
//
        hrange = range(0,4,length=30)
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
        data_root = "/home/fieldofnodes/Projects/Dundee_PhD/data/02_T6ssTelegraphRWModel/"
        input_values = T6ssDataGenerateInput(
                Δt,Δx,T,X,aspect,boundary,simulation_iterations,parameter_iterations,λ₀,λ₁,h,dif_min,dif_max,λmax,hmax,amax,data_root)
        iters_get_values = [
                (group = 1, data_type = "parameters", data_value = "λ₀", data_label = L"\lambda_0", data_measure = "",xaxis = L"d_T",yaxis = L"P(d_T)", dist_axis = L"\bar{d}_T"),
                (group = 2, data_type = "parameters", data_value = "h", data_label = L"h_0", data_measure = "",xaxis = L"d_T",yaxis = L"P(d_T)", dist_axis = L"\bar{d}_T"),
                (group = 3, data_type = "variables", data_value = "aspect", data_label = L"aspect", data_measure = "",xaxis = L"d_T",yaxis = L"P(d_T)", dist_axis = L"\bar{d}_T"),
                (group = 4, data_type = "parameters", data_value = "h", data_label = L"D_0 \> (\mu m^2/s)", data_measure = L"\mu m^2/s",xaxis = L"d_{T_{OC}}\>\mu m",yaxis = L"P(d_{T_{OC}})", dist_axis = L"\bar{d}_{T_{OC}}\>\mu m")]

//


#######################
#### Generate Data ####
#######################
//
        # I already ran this -- do again if needed.
        generate_t6ss_data(input_values)
//


##########################
#### Set figure paths ####
##########################
//
        figure_root = "figures"
        fig_numeric_label =(3,4,5,6)
        fig_alph_label = ("b","c","d")
        figure_paths = [figure_root*
                append_forward_slash_figure(x)*
                join_figure_number_letter(x,y)
                for x in fig_numeric_label 
                for y in fig_alph_label] .* 
                ".pdf"

        figb = figure_paths[1:3:end]
        figc = figure_paths[2:3:end]
        figd = figure_paths[3:3:end]
//


#############################
#### Retrieve Data Paths ####
#############################
//
        grouped_file_paths = @chain input_values begin
                _.data_root
                find(_,1,2,"json")
                map(
                        y -> filter(
                                x -> occursin("Figure$(y)", x),
                                _),
                        (3,4,5,6))
                map(x->sort(x,lt=NaturalSort.natural),_)
        end
//


#################################################
#### Generate Theoretical Data Per Parameter ####
#################################################
//
    theoretical = get_theoretical_tuple(grouped_file_paths,iters_get_values)
    Δx = 0.1
    theoretical[4] = [(i[1], i[2] * Δx ) for i in theoretical[4]]
    
    
//

####################
#### T6SS Model ####
####################


#########################################
#### Initialise project and packages ####
#########################################
# Initialise Julia project

using Pkg; Pkg.activate(".")

# Load packages needed
include("packages.jl")

########################
#### Initiate Model ####
########################

# Load functions to interact with simulated data
# Load functions to set up structs and type needed
include("model/20220319_GetStructsTypes_V1.jl")

# Load functions to aid in file and naming convections
include("model/20220319_GetFileAndNamingFunc_V1.jl")

# Load helper functions
include("model/20220319_GetHelperFunc_V1.jl")

# Load walker helper functions
include("model/20220319_GetWalkerHelperFunc_V1.jl")

# Load functions to get walker positions
include("model/20220319_GetWalkerPositionsFunc_V1.jl")

# Load functions to get distances
include("model/20220319_GetDistanceFunc_V1.jl")

# Load function to get solutions
include("model/20220319_GetSolutionWalkerFunc_V1.jl")

# Load function to run simulations
include("model/20220319_RunSimulationSaveFile_V1.jl")

# Generate data function to save to file
include("model/20220325_GenerateT6ssData_V1.jl")

# Generate theoretical function for distance over a Parameter
include("model/20220405_GenerateTheoreticalData_V1.jl")


#######################
#### Initiate View ####
#######################
# Load view to visualise the walker Distances
include("view/20220319_ViewWalkerDistSolutionFunc_V1.jl")

# Load view to visualise multiple parameters
include("view/20220319_ViewMultipleParamsIters_V1.jl")

# Load view to visualise the distances
include("view/20220329_GetHistogramDistancesT6ss_V1.jl")
hrange = range(0,4,length=30)
hrange[28]
################################
#### Stipulate Input Values ####
################################
//
        Δt = 0.0001
        Δx = 1
        bioΔx = 0.1
        T = 10
        X = 20
        aspect = 1.6
        boundary = "no_flux"
        simulation_iterations = 4
        parameter_iterations = 30
        λ₀ = 0.0017
        λ₁ = 0.045
        
        dif_min = 0.0049
        dif_max = 2.5
        dif_base = 0.05
        h = LitRate(dif_base,bioΔx)
        λmax = 100
        hmax = 10
        amax = 4
        data_root = "/home/fieldofnodes/Projects/Dundee_PhD/data/02_T6ssTelegraphRWModel/"
        input_values = T6ssDataGenerateInput(
                Δt,Δx,T,X,aspect,boundary,simulation_iterations,parameter_iterations,λ₀,λ₁,h,dif_min,dif_max,λmax,hmax,amax,data_root)
        iters_get_values = [
                (group = 1, data_type = "parameters", data_value = "λ₀", data_label = L"\lambda_0", data_measure = "",xaxis = L"d_T",yaxis = L"P(d_T)", dist_axis = L"\bar{d}_T"),
                (group = 2, data_type = "parameters", data_value = "h", data_label = L"h_0", data_measure = "",xaxis = L"d_T",yaxis = L"P(d_T)", dist_axis = L"\bar{d}_T"),
                (group = 3, data_type = "variables", data_value = "aspect", data_label = L"aspect", data_measure = "",xaxis = L"d_T",yaxis = L"P(d_T)", dist_axis = L"\bar{d}_T"),
                (group = 4, data_type = "parameters", data_value = "h", data_label = L"D_0 \> (\mu m^2/s)", data_measure = L"\mu m^2/s",xaxis = L"d_{T_{OC}}\>\mu m",yaxis = L"P(d_{T_{OC}})", dist_axis = L"\bar{d}_{T_{OC}}\>\mu m")]


    # Set data path and file names
    fig_numeric_label =3
    parameter_span = "Span"
    
    data_path_json_vec = [
        data_root*
        join_figure_number_letter(x,parameter_span)*
        "ParamIter"*
        string(z) 
            for x in fig_numeric_label 
            for z in 1:iter.parameter_iterations] .* 
            ".json"

//

#######################
#### Generate Data ####
######################



    @unpack Δt, Δx, T, X, aspect,boundary,simulation_iterations,parameter_iterations,λ₀,λ₁,h,dif_min,dif_max,λmax,hmax,amax,data_root = 
        input_values
    var = Variables(Δt, Δx, T, X, aspect,boundary)
    par =  Parameters(λ₀,λ₁,h)
    dom = dimensions(var)
    iter = Iterations(simulation_iterations,parameter_iterations)
    λ₀_vec = range(0,λmax,iter.parameter_iterations)
    λ₁_vec = ones(iter.parameter_iterations)
    parλ₀ = [Parameters(λ₀_vec[i],λ₁_vec[i],h) for i in 1:iter.parameter_iterations]

    
    solutionλ₀ = map(parλ₀) do p
        Δp = Δ(p,var)       
        res = get_experimental_sample_dist_vecs(var, Δp, dom, iter)
        solu = SolutionVarParDom(var,p,dom,iter,res.experimental,res.sample)
    end
    

    write_solution_to_file.(solutionλ₀,data_path_json_vec)



    


##########################
#### Set figure paths ####
##########################
//
        figure_root = "/home/fieldofnodes/Projects/Dundee_PhD/documentation/ModellingStochasticTimerRandomMotionT6SS/images/FiguresPaper/"
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


#############################
#### Retrieve Data Paths ####
#############################
//
        grouped_file_paths = @chain input_values begin
                _.data_root
                find(_,1,2,"json") 
            end
                
//


#################################################
#### Generate Theoretical Data Per Parameter ####
#################################################
//
    Δx = 0.1    
    theoretical = @chain grouped_file_paths begin
        [get_theoretical_distance(i,iters_get_values[1]) for i in _]
        [(i[1], i[2]  ) for i in _]  
        sort(_, by = first)
    end
  
//



##################################
#### Load, Plot and Save Data ####
##################################
//
    ####################################
    ### For the plots 4,5,6
    ####################################
    first_plot = 2
    second_plot = input_values.parameter_iterations - 1
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
    save_figure(figsb,figb)



    # For everything except the last figure
    data_figsc = @chain grouped_file_paths begin
        filter(x -> occursin("Iter$(second_plot).",x),_)[1] 
        read_solution_from_memory(_,SolutionVarParDom)
    end
    
    data_figsc = @set data_figsc.experimental = data_figsc.experimental ./ (1/Δx)
    data_figsc = @set data_figsc.sample = data_figsc.sample ./ (1/Δx)
    data_figsc = @set data_figsc.domain = data_figsc.domain * Δx
    data_figsc = @set data_figsc.variables.Δx = data_figsc.variables.Δx ./ (1/Δx)


    figsc = view_distance_and_mean(data_figsc,iters_get_values[1],parameter_colours[2])
    save_figure(figsc,figc)
    
    
    
    # For everything except the last figure
    figsd = @chain grouped_file_paths begin
        map(x-> read_solution_from_memory(x,SolutionVarParDom),_)
        map(x -> (get_value(x,iters_get_values[1][:data_type], iters_get_values[1][:data_value]),mean(x.experimental),mean(x.sample)),_)
        [(i[1],i[2],i[3] / (1/Δx)) for i in _]
        sort(_, by = first)
    end


    param = [i[1] for i in figsd]
    exper = [i[2] for i in figsd]
    sampl = [i[3] for i in figsd]
    theor = theoretical#[i[2] for i in theoretical]
    distance = (parameter = param, experimental = exper, sample = sampl,theoretical = theor)        


    control_colour = colorant"#d5b670"  # Medium yellow 
    simulation_color = colorant"#443b28" # Sangria
    theoretical_color = colorant"#d92121" # Maximum red
    small_parameter_color = colorant"#d471d1" # Magentafigsdscat
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
         
    save_figure(figsdscat,figd)
        



##################################
#### Load, Plot and Save Data ####
##################################
//
        ####################################
        ### For the plots 4,5,6
        ####################################
        first_plot = 2
        second_plot = input_values.parameter_iterations - 1
        parameter_colours = [colorant"#d471d1", colorant"#60dce5"]

        # For everything except the last figure
        figsb = (@chain grouped_file_paths[1:3] begin
                map(x->x[first_plot],_) 
                map(x-> read_solution_from_memory(x,SolutionVarParDom,),_) end)[2]
                map((x,y)->view_distance_and_mean(x,y,parameter_colours[1]),_,iters_get_values[1:3])
                map((x,y)->save_figure(x,y),_,figb[1:3])
        end 
        
        # For everything except the last figure
        figsc = (@chain grouped_file_paths[1:3] begin
                map(x->x[second_plot],_)
                map(x-> read_solution_from_memory(x,SolutionVarParDom),_) end)[2]
                map((x,y)->view_distance_and_mean(x,y,parameter_colours[2]),_,iters_get_values[1:3])
                map((x,y)->save_figure(x,y),_,figc[1:3])
        end 
        
        
        
        # For everything except the last figure
        figsd = @chain grouped_file_paths[1:3] begin
                map(
                i -> get_mean_distance(
                        _,
                        i[:group],
                        i[:data_type], 
                        i[:data_value]),
                        iters_get_values[1:3])
                map(x ->
                        get_solutions_vector(_,theoretical[1:3],x),
                        1:size(_,1))
                map((x,y) -> view_scatter_mean(x,y),_,iters_get_values[1:3])
                map((x,y) -> save_figure(x,y),_,figd[1:3])
            end
            


        ####################################
        ### For the plots 7
        ####################################
        
        parameter_colours = [colorant"#d471d1", colorant"#60dce5"]

        figb[4]  = replace(figb[4],"Figure6b" => "Figure6a") 
        figc[4]  = replace(figc[4],"Figure6c" => "Figure6b") 
        figd[4]  = replace(figd[4],"Figure6d" => "Figure6c") 
        # For everything except the last figure
        x = @chain grouped_file_paths[4] begin
                map(x->read_solution_from_memory(x,SolutionVarParDom),_)
                map(x-> x.parameters.h,_)
        end
        l = length(x)
        first_point = findall(d -> d==0.0049,x)
        second_point = l-3

        figsb = @chain grouped_file_paths[4] begin
                _[first_plot]
                read_solution_from_memory(_,SolutionVarParDom)
                view_distance_and_mean(_,iters_get_values[4],parameter_colours[1])
                save_figure(_,figb[4])
        end 

        
        figsc = @chain grouped_file_paths[4] begin
                _[second_plot] 
                read_solution_from_memory(_,SolutionVarParDom)
                view_distance_and_mean(_,iters_get_values[4],parameter_colours[2])
                save_figure(_,figc[4])
        end 


        # indices are hard coded -- do again
        # this is prototyupe
        # For everything except the last figure
        sols_mem = @chain grouped_file_paths[4] begin
                map(io -> read_solution_from_memory(io,SolutionVarParDom),_)
                
        end 
        theoretical = map(
                x->get_t6ss_walk_theoretical_dist(T6ssBiologicalInspired(),
                x),
                sols_mem)

        sols_plot = @chain sols_mem begin
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
        
        
        
        x2 = x[first_point]
        x3 = [x[second_point]]
        yexp = sols_plot[:experimental]
        yexp2 = yexp[first_point]
        yexp3 = [yexp[second_point]]
        ylimmax = round(1.9*yexp3[1],digits = 2)
        ysam = sols_plot[:sample]
        theoretical = sols_plot[:theoretical]
        figsd = Figure(resolution=(800,800))
                fontsize_theme = Theme(fontsize = 35)
                set_theme!(fontsize_theme)
                ax = Axis(figsd[2,1],
                width = 512, height = 512,aspect=1,
                xlabel = iters_get_values[4][:data_label],ylabel = iters_get_values[4][:dist_axis],xlabelsize=35,ylabelsize=35)
                control_scatter = scatter!(ax,x,ysam,color=control_colour)
                simulation_scatter = scatter!(ax,x,yexp,color=simulation_color)
                theoretical_scatter = lines!(ax,x,theoretical,color=theoretical_color)
                scatter!(ax,x2,yexp2,markersize=20,color=(small_parameter_color,0.5))
                scatter!(ax,x3,yexp3,markersize=20,alpha=.1,color=(large_parameter_color,0.5))
        #        ylims!(ax, 0, ylimmax)
        
        
        save_figure(figsd,figd[4])
        















            

//
        

#### Solve Biological Model, plot and save figures and data ####
include("model/20220426_GenerateDiffusionSwitchingParameterData.jl")