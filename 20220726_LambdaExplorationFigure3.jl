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
        data_root = "data/"
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


    # Set data path and file names for figure 3


//



##########################
#### Set figure3 paths ####
##########################
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



#######################
#### Generate Data ####
######################


    
    

#############################
#### Retrieve Data Paths ####
#############################
//


                
//




figsb = figure_4_b(grouped_file_paths,input_values)
save_figure(figsb,figb)

figsc = figure_4_c(grouped_file_paths,input_values)
save_figure(figsc,figc)

figsdscat = figure_4_d(grouped_file_paths)
save_figure(figsdscat,figd)
        

