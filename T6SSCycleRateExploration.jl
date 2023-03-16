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

################################
#### Stipulate Input Values ####
################################
//


        Δt = 0.01
        Δx = 1
        T = 200
        X = 20
        aspect = 1.6
        boundary = "no_flux"
        simulation_iterations = 4
        parameter_iterations = 30
        λ₀ = 0.017
        λ₁ = 0.045
        
        dif_min = 0.0049
        dif_max = 2.5
        dif_base = 0.01
        h = LitRate(dif_base,0.1)
        λmax = 100
        hmax = 10
        amax = 4
        data_root = "data"
        input_values = T6ssDataGenerateInput(
                Δt,Δx,T,X,aspect,boundary,simulation_iterations,parameter_iterations,λ₀,λ₁,h,dif_min,dif_max,λmax,hmax,amax,data_root)
        @unpack Δt, Δx, T, X, aspect,boundary,simulation_iterations,parameter_iterations,λ₀,λ₁,h,dif_min,dif_max,λmax,hmax,amax,data_root = input_values


        var = Variables(Δt, Δx, T, X, aspect,boundary)
        par =  Parameters(λ₀,λ₁,h)
        Δp = Δ(par,var)
        
        dom = dimensions(var)
        iter = Iterations(simulation_iterations,parameter_iterations)
        iters_get_values = [
                (group = 1, data_type = "parameters", data_value = "λ₀", data_label = L"\lambda_0", data_measure = "",xaxis = L"d_T",yaxis = L"P(d_T)", dist_axis = L"\bar{d}_T"),
                (group = 2, data_type = "parameters", data_value = "h", data_label = L"h_0", data_measure = "",xaxis = L"d_T",yaxis = L"P(d_T)", dist_axis = L"\bar{d}_T"),
                (group = 3, data_type = "variables", data_value = "aspect", data_label = L"aspect", data_measure = "",xaxis = L"d_T",yaxis = L"P(d_T)", dist_axis = L"\bar{d}_T"),
                (group = 4, data_type = "parameters", data_value = "h", data_label = L"D_0 \> (\mu m^2/s)", data_measure = L"\mu m^2/s",xaxis = L"d_{T_{OC}}\>\mu m",yaxis = L"P(d_{T_{OC}})", dist_axis = L"\bar{d}_{T_{OC}}\>\mu m")]


    # Set data path and file names
    fig_numeric_label =3
    parameter_span = "Span"
    iterations = lpad.(1:iter.parameter_iterations,2,"0")
    data_path_json_vec = [
        data_root*
        join_figure_number_letter(x,parameter_span)*
        "ParamIter"*
        string(z) 
            for x in fig_numeric_label 
            for z in iterations] .* 
            ".json"

//



##########################
#### Set figure paths ####
##########################
//
        fig_numeric_label = 4
        fig_alph_label = ("b","c","d")
        figure_paths = [figure_root*
                append_forward_slash_figure(x)*
                join_figure_number_letter(x,y)
                for x in fig_numeric_label 
                for y in fig_alph_label] .* 
                ".pdf"

        figb,figc,figd = figure_paths
        
//



#######################
#### Generate Data ####
######################



    λ₀ₘᵢₙ = 0.01
    λ₀ₘₐₓ = 10
    λ₀_vec = range(λ₀ₘᵢₙ,λ₀ₘₐₓ,iter.parameter_iterations)
    λ₁_vec = ones(iter.parameter_iterations) .* λ₁
    parλ₀ = [Parameters(λ₀_vec[i],λ₁_vec[i],h) for i in 1:iter.parameter_iterations]
    Δparλ₀ = [Δ(p,var) for p in parλ₀]       
    
    
    

    function sol(var, Δp, dom, iter,data_path_json_vec)
        res = get_experimental_sample_dist_vecs(var, Δp, dom, iter)
        solu = SolutionVarParDom(var,Δp,dom,iter,res.experimental,res.sample)
        return write_solution_to_file(solu,data_path_json_vec)
    end


    for i in 1:iter.parameter_iterations
        sol(var, Δparλ₀[i], dom, iter,data_path_json_vec[i])
    end
    

#############################
#### Retrieve Data Paths ####
#############################
//
    grouped_file_paths = @chain input_values begin
            _.data_root
            find(_,1,2,"json") 
            sort(_)
        end

                
//


#################################################
#### Generate Theoretical Data Per Parameter ####
#################################################
//
    sols_mem = @chain grouped_file_paths begin
        map(io -> read_solution_from_memory(io,SolutionVarParDom),_)
    end

    theoretical = map(x->get_t6ss_walk_theoretical_dist(x),sols_mem)
//



##################################
#### Load, Plot and Save Data ####
##################################
//
    Δx = 0.1
    ####################################
    ### For the plots 4,5,6
    ####################################
    first_plot = "02"
    second_plot = lpad(input_values.parameter_iterations - 1,2,"0")
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
    
    
    
    # D For everything except the last figure
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
    #ylims!(ax,0,4.5)
    figsdscat
    save_figure(figsdscat,figd)
        

