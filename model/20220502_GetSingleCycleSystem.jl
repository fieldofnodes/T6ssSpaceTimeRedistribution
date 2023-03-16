@unpack Δt, Δx, T, X, aspect,boundary,simulation_iterations,parameter_iterations,λ₀,λ₁,h,dif_min,dif_max,λmax,hmax,amax,data_root = 
            input_values
vars = Variables(Δt, Δx, T, X, aspect,boundary) # set variables to Variable struct
par =  Parameters(λ₀,λ₁,h) # Set parameter values to Parameter struct
Δp = Δ(par,vars) # Convert parameters to be scaled by Δt
dom = dimensions(vars) # get dimensions of domain stored to Domain struct
iter = Iterations(simulation_iterations,parameter_iterations) # Set iteration variables to Iterations struct
parameter_colours = [colorant"#d471d1", colorant"#60dce5"] 


get_walker_position(
    T6ssBiologicalInspired(),
    vars,
    Δp,
    dom)

"""
Run the T6SS for one cycle of State 0 and State 1
"""        
function get_walker_position(
    ::T6ssBiologicalInspired,
    var::Variables,
    par::Parameters,
    dom::Domain)

    walker = rand_walker(dom,var)
    
    state = s₀()
    states = []
    walkers = []
    cycle = 1
    while cycle < 3
        state = Telegraph.update(state,par.λ₀,par.λ₁)
        walker = walker_update(walker,state,var,par,dom)
        push!(walkers,walker)
        push!(states,state)
        sz_states = size(states,1)
        if cycle == 1 && (states[sz_states] == states[1])
            continue
        elseif cycle == 1 && (states[sz_states] != states[1])
            cycle = 2
        elseif cycle == 2 && (states[sz_states] == states[1])
            cycle  = 3
            walkers = walkers[1:sz_states-1]
            states = states[1:sz_states-1]
        else
            # do nothing
        end
        
        return WalkerFirstLast(walkers[1],walkers[end])
    end
    return RandomWalker.position.(walkers)
end
