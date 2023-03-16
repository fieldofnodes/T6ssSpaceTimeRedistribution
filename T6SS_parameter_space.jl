using Pkg; Pkg.activate(".")

# Load packages
include("packages.jl")

# Load functions and parameters
include("FunctionsNeeded.jl")
#include("ParameterConfig.jl")

solve_iterations()


