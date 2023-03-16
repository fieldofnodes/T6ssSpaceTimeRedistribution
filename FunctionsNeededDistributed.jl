#################
#### Structs ####
#################
//
    struct SolutionStructure
        machine_positions::Vector{Tuple{Int64, Int64}}
        indx::Vector{Int64}
        distances_experimental::Vector{Int64}
        count_experimental::Vector{Int64}
        distance_sample::Vector{Int64}
        count_sample::Vector{Int64}
        count_norm::Vector{Float64}
    end
    StructTypes.StructType(::Type{SolutionStructure}) = StructTypes.Struct()
//



###############################
#### File system functions ####
###############################
//
    # find files based on pattern matching
    # returns vector 
    function find(src_dir::String,mindepth::Int,
        maxdepth::Int,ext::String;force=false::Bool,
        recursive=false::Bool)
        #src_dir::String - Source parent folder for files
        #dst_dir::String - Destination folder for copied renamed files
        #mindepth::Int - Minimum depth for find files
        #maxdepth::Int - Maximum dpeth to find files
        #ext::String - Extension of file to look for 
        dest_fn = "$(src_dir)/list_the_files.txt"
        run(
        pipeline(
        `find $src_dir -mindepth $mindepth -maxdepth $maxdepth -iname "*$ext*"`,
        stdout= dest_fn
        )
        )


        src = @chain dest_fn begin
        open(_)
        readlines(_)
        end

        rm(dest_fn; force=force, recursive=recursive)
        return src
    end

    # write solution to JSON
    function write_solution_to_file(solution::NamedTuple,path::String)
        # Write solutoin to JSON3
        open(path, "w") do io
            JSON3.pretty(io, solution,allow_inf=true)
        end
    end

    # read solution from JSON
    function read_solution_to_memory(path::String) 
        # Read Jason string 
        json_string = read(path, String)
        # Convert to data format
        input = JSON3.read(json_string,SolutionStructure)
        return input
    end
//




###############################
#### Independent functions ####
###############################
//
    # gets nearest even number
    even(N) = 2*Int(div(N,2,RoundNearest))

    # takes width and apect and gives dimensions
    function dimensions(xwidth;aspect=1)
        ylength = even(xwidth*aspect)
        return (xwidth = xwidth, ylength = ylength)
    end

    # discretise space/time
    function XΔt(input,Δt)
        input*Δt
    end

    # random state init
    s₀() = rand((0,1))

    # concatenates text: 
    # fig_num = 1, fig_sub_num = "a"
    # Figure1a is result
    fig_labels(fig_num::Int,fig_sub_num::String) = "Figure"*string(fig_num)*fig_sub_num

    # concatenates tuple of 3 
    # ("a","b","c")→ "abc"
    file_name_letters(fig_sub_num::Tuple) = fig_sub_num[1]*fig_sub_num[2]*fig_sub_num[3]

    # add / to path generation
    fig_labels(fig_num::Int) = "Figure"*string(fig_num)*"/"

    # add together for name generation over tuple 
    fig_labels(fig_num::Int,fig_sub_num::Tuple) = "Figure"*string(fig_num)*file_name_letters(fig_sub_num)

    # generate data path for JSON file
    data_path(data_root::String,fig_num::Int,fig_sub_num::Tuple) = data_root*"SolutionData"*fig_labels(fig_num,fig_sub_num)*".json"

    # generatre hopping rate from diffusion coefficient
    function LitRate(Diffusion,Δx)
        return Diffusion/Δx^2
    end
    # generate range -1/2x to 1/2x
    function get_range(x;step=1)
        return range(-x/2,stop=x/2,step=step)
    end
    # get random starting position for walker
    function get_random_position(xwidth,ylength;step=1)
        return Walker2D(
            Int(rand(get_range(xwidth,step=step))),
            Int(rand(get_range(ylength,step=step)))
            )
    end
//    

function boundary_conditional(boundary::String,possibile_options::Tuple)
    if boundary == "no_boundary"
        possibile_options[1]
    elseif boundary == "double_periodic"
        possibile_options[2]
    elseif boundary == "no_flux"
        possibile_options[3]
    elseif boundary == "cell_boundary"
        possibile_options[4]
    else
        error("boundary has to be no_boundary,double_periodic,no_flux or cell_boundary, not $(boundary)")
    end
end


############################
#### Distance functions ####
############################
//
    # Sample/Theoretical Distribution of Distances
    function get_sample_distribution(xwidth,ylength,N)
        RandW() = rand(0:xwidth,10^N)
        RandL() = rand(0:ylength,10^N)
        X = colwise(Cityblock(), RandW(),RandW())
        X = [(x > xwidth / 2 ? xwidth - x : x) for x in X]
        Y = colwise(Cityblock(), RandL(),RandL())
        Y = [(y > ylength / 2 ? ylength - y : y) for y in Y]
        return X .+ Y
    end

    function get_sample_distribution(xwidth,ylength,N,boundary)
        RandW() = rand(0:xwidth,10^N)
        RandL() = rand(0:ylength,10^N)
        if boundary == "no_boundary"
            X = colwise(Cityblock(), RandW(),RandW())
            Y = colwise(Cityblock(), RandL(),RandL())
        elseif boundary == "double_periodic"
            X = colwise(Cityblock(), RandW(),RandW())
            X = [(x > xwidth / 2 ? xwidth - x : x) for x in X]
            Y = colwise(Cityblock(), RandL(),RandL())
            Y = [(y > ylength / 2 ? ylength - y : y) for y in Y]
        elseif boundary == "no_flux"
            X = colwise(Cityblock(), RandW(),RandW())
            X = [(x > xwidth / 2 ? xwidth - x : x) for x in X]
            Y = colwise(Cityblock(), RandL(),RandL())
        elseif boundary == "cell_boundary"
            X = colwise(Cityblock(), RandW(),RandW())
            X = [(x > xwidth / 2 ? xwidth - x : x) for x in X]
            Y = colwise(Cityblock(), RandL(),RandL())
        else
            #nothing
        end
        return X .+ Y
    end

    # Get distances from model simulation
    # Walker IC = (0,0)
    function get_distance(w::Walker2D)
        return abs(w.x) + abs(w.y)
    end

    function get_x_distance(w₁::Walker2D,w₂::Walker2D)
        return abs(w₂.x - w₁.x)
    end

    function get_y_distance(w₁::Walker2D,w₂::Walker2D)
        return abs(w₂.y - w₁.y)
    end

    function get_periodic_boundary_distance(distance,domain)
        return distance > domain/2 ? domain - distance : distance
    end

    function get_no_periodic_boundary_distance(distance,domain)
        return distance
    end

    # Gives distance post boundary processing
    function update_distance(distance,domain,boundary::Function)
        return boundary(distance,domain)
    end

    # Accumulated function to take walker starting and ending 
    # position and return the distance dependent upon the 
    # domain and boundary conditions.
    #=
    get_distance(
        w₁,w₂,                              --Walkers
        xwidth,ylength,                     --domains
        get_periodic_boundary_distance,     --boundary conditions
        get_no_periodic_boundary_distance   --boundary conditions    
        )

    =#
    function get_distance(w₁::Walker2D,w₂::Walker2D,xwidth,ylength,xboundary::Function,yboundary::Function)
            x = update_distance(
                get_x_distance(w₁::Walker2D,w₂::Walker2D),
                xwidth,
                xboundary)
            y = update_distance(
                get_y_distance(w₁::Walker2D,w₂::Walker2D),
                ylength,
                yboundary)
            return x + y
    end


    # Set range for possible distances
    function  set_range_iter(xwidth,ylength,boundary::String)
        possibile_options = (
            collect(0:Int((xwidth + ylength))),
            collect(0:Int((1/2)*(xwidth + ylength))),
            collect(0:Int(((1/2)*(xwidth) + ylength))),
            collect(0:Int(((1/2)*(xwidth) + ylength)))
        )
        return boundary_conditional(boundary,possibile_options)
    end

    # Get count over all possible distances
    function get_count(vect_to_count,range)
        counts = [Base.count(i->i==j,vect_to_count) for j in range]
        return counts
    end

    # Collect all distances and counts
    # The experimental is the result of the model
    # sample is the results of random sampling
    function get_distance_count_sample_experimental(machine_positions,xwidth,ylength,N,boundary)
        if boundary == "no_boundary"
            xboundary,yboundary = get_no_periodic_boundary_distance,get_no_periodic_boundary_distance
        elseif boundary == "double_periodic"
            xboundary,yboundary = get_periodic_boundary_distance,get_periodic_boundary_distance
        elseif boundary == "no_flux"
            xboundary,yboundary = get_periodic_boundary_distance,get_no_periodic_boundary_distance
        elseif boundary == "cell_boundary"
            xboundary,yboundary = get_periodic_boundary_distance,get_no_periodic_boundary_distance
        else
            #nothing
        end
        
        distances_iter = set_range_iter(xwidth,ylength,boundary)
        distances_experimental = [get_distance(x[:first_walker],x[:last_walker],xwidth,ylength,xboundary,yboundary) for x in machine_positions]
        distance_sample = get_sample_distribution(xwidth,ylength,N,boundary)
        count_experimental = get_count(distances_experimental,distances_iter)
        count_sample = get_count(distance_sample,distances_iter)
        count_norm = count_experimental ./ count_sample
        return (
            machine_initial = [RandomWalker.position(x[:first_walker]) for x in machine_positions],    
            machine_final = [RandomWalker.position(x[:last_walker]) for x in machine_positions],
            indx = distances_iter,
            distances_experimental = distances_experimental,
            count_experimental = count_experimental,
            distance_sample = distance_sample,
            count_sample = count_sample,
            count_norm = count_norm)
    end
//



##############################
#### T6SS Model functions ####
##############################
//
    # Single iteration walker is predefined
    function get_walker_position(λ₀Δt,λ₁Δt,hΔt,t⃗,walker,xwidth,ylength,boundary)
        state = s₀()
        positions = []
        states = []
        T6SS = []
        push!(states = state)
        push!(positions,RandomWalker.position(walker))
        (machine_states = states, machine_positions = positions)
        if boundary == "no_boundary"
            for i in t⃗
                state = Telegraph.update(state,λ₀Δt,λ₁Δt)
                walker = RandomWalker.update(walker,stepper(state,hΔt),xwidth,ylength)
                push!(states,state)
                push!(positions,RandomWalker.position(walker))
            end
        elseif boundary == "double_periodic"
            for i in t⃗
                state = Telegraph.update(state,λ₀Δt,λ₁Δt)
                walker = RandomWalker.updateperiod(walker,stepper(state,hΔt),xwidth,ylength)
                push!(states,state)
                push!(positions,RandomWalker.position(walker))
            end
        elseif boundary == "no_flux"
            for i in t⃗
                state = Telegraph.update(state,λ₀Δt,λ₁Δt)
                walker = RandomWalker.updatenoflux(state,walker, hΔt, xwidth, ylength)
                push!(states,state)
                push!(positions,RandomWalker.position(walker))
            end
        elseif boundary == "cell_boundary"
            for i in t⃗
                state = Telegraph.update(state,λ₀Δt,λ₁Δt)
                walker = RandomWalker.updatecell(walker,stepper(state,hΔt),xwidth,ylength)
                push!(states,state)
                push!(positions,RandomWalker.position(walker))
            end
        else
            #nothing
        end
        return (machine_states = states, machine_positions = positions)
    end

    # single iteration, walker is chosen at random
    function get_walker_position(λ₀Δt,λ₁Δt,hΔt,t⃗,xwidth,ylength,boundary)
        walker = get_random_position(xwidth,ylength;step=1)
        state = s₀()
        positions = []
        states = []
        push!(positions,RandomWalker.position(walker))
        push!(states,state)
        push!(states = state)
        push!(positions,RandomWalker.position(walker))
        (machine_states = states, machine_positions = positions)
        if boundary == "no_boundary"
            for i in t⃗
                state = Telegraph.update(state,λ₀Δt,λ₁Δt)
                walker = RandomWalker.update(walker,stepper(state,hΔt),xwidth,ylength)
                push!(states,state)
                push!(positions,RandomWalker.position(walker))
            end
        elseif boundary == "double_periodic"
            for i in t⃗
                state = Telegraph.update(state,λ₀Δt,λ₁Δt)
                walker = RandomWalker.updateperiod(walker,stepper(state,hΔt),xwidth,ylength)
                push!(states,state)
                push!(positions,RandomWalker.position(walker))
            end
        elseif boundary == "no_flux"
            for i in t⃗
                state = Telegraph.update(state,λ₀Δt,λ₁Δt)
                walker = RandomWalker.updatenoflux(state,walker, hΔt, xwidth, ylength)
                push!(states,state)
                push!(positions,RandomWalker.position(walker))
            end
        elseif boundary == "cell_boundary"
            for i in t⃗
                state = Telegraph.update(state,λ₀Δt,λ₁Δt)
                walker = RandomWalker.updatecell(walker,stepper(state,hΔt),xwidth,ylength)
                push!(states,state)
                push!(positions,RandomWalker.position(walker))
            end
        else
            #nothing
        end
        return (machine_states = states, machine_positions = positions)
    end

    # N iterations, walker predefined
    function get_walker_position(λ₀Δt,λ₁Δt,hΔt,t⃗,N,walker,xwidth,ylength,boundary)
        state = s₀()
        last_position = []
        if boundary == "no_boundary"
            for j in 1:10^N
                for i in t⃗
                    state = Telegraph.update(state,λ₀Δt,λ₁Δt)
                    walker = RandomWalker.update(walker,stepper(state,hΔt),xwidth,ylength)
                end
                push!(last_position,walker)
                walker = Walker2D(0,0)
            end
        elseif boundary == "double_periodic"
            for j in 1:10^N
                for i in t⃗
                    state = Telegraph.update(state,λ₀Δt,λ₁Δt)
                    walker = RandomWalker.updateperiod(walker,stepper(state,hΔt),xwidth,ylength)
                end
                push!(last_position,walker)
                walker = Walker2D(0,0)
            end
        elseif boundary == "no_flux"
            for j in 1:10^N
                for i in t⃗
                    state = Telegraph.update(state,λ₀Δt,λ₁Δt)
                    walker = RandomWalker.updatenoflux(state,walker, hΔt, xwidth, ylength)
                end
                push!(last_position,walker)
                walker = Walker2D(0,0)
            end
        elseif boundary == "cell_boundary"
            for j in 1:10^N
                for i in t⃗
                    state = Telegraph.update(state,λ₀Δt,λ₁Δt)
                    walker = RandomWalker.updatecell(walker,stepper(state,hΔt),xwidth,ylength)
                end
                push!(last_position,walker)
                walker = Walker2D(0,0)
            end
        else
            #nothing
        end
        return (machine_positions = last_position)
    end

    # N iterations, walker sampled at random
    function get_walker_position(λ₀Δt,λ₁Δt,hΔt,t⃗,N,xwidth,ylength,boundary)

        state = s₀()
        last_position = []
        if boundary == "no_boundary"
            for j in 1:10^N
                walker = get_random_position(xwidth,ylength;step=1)
                w₀ = walker
                for i in t⃗
                    state = Telegraph.update(state,λ₀Δt,λ₁Δt)
                    walker = RandomWalker.update(walker,stepper(state,hΔt),xwidth,ylength)
                end
                push!(last_position,(first_walker = w₀,last_walker = walker))
            end
        elseif boundary == "double_periodic"
            for j in 1:10^N
                walker = get_random_position(xwidth,ylength;step=1)
                w₀ = walker
                for i in t⃗
                    state = Telegraph.update(state,λ₀Δt,λ₁Δt)
                    walker = RandomWalker.updateperiod(walker,stepper(state,hΔt),xwidth,ylength)
                end
                push!(last_position,(first_walker = w₀,last_walker = walker))
            end
        elseif boundary == "no_flux"
            for j in 1:10^N
                walker = get_random_position(xwidth,ylength;step=1)
                w₀ = walker
                for i in t⃗
                    state = Telegraph.update(state,λ₀Δt,λ₁Δt)
                    walker = RandomWalker.updatenoflux(state,walker, hΔt, xwidth, ylength)
                end
                push!(last_position,(first_walker = w₀,last_walker = walker))
            end
        elseif boundary == "cell_boundary"
            for j in 1:10^N
                walker = get_random_position(xwidth,ylength;step=1)
                w₀ = walker
                for i in t⃗
                    state = Telegraph.update(state,λ₀Δt,λ₁Δt)
                    walker = RandomWalker.updatecell(walker,stepper(state,hΔt),xwidth,ylength)
                end
                push!(last_position,(first_walker = w₀,last_walker = walker))
            end
        else
            #nothing
        end
        return (machine_positions = last_position)
    end
//




###################################################
#### Solve the T6SS model and compute distance ####
###################################################
//
    # loads a .jl file of parameters
    # solves the T6SS equation
    # returns distances
    function solve(parameter_file::String)
        include(parameter_file)
        machine_positions = get_walker_position(λ₀Δt,λ₁Δt,hΔt,t⃗,N,walker,xwidth,ylength,boundary)
        return get_distance_count_sample_experimental(machine_positions,xwidth,ylength,N,boundary)
    end

    function solve(parameter_file::String;walker_ic::String = "random")
        include(parameter_file)
        if walker_ic == "random"
            machine_positions = get_walker_position(λ₀Δt,λ₁Δt,hΔt,t⃗,N,xwidth,ylength,boundary)
        else 
            machine_positions = get_walker_position(λ₀Δt,λ₁Δt,hΔt,t⃗,N,walker,xwidth,ylength,boundary)
        end
        return get_distance_count_sample_experimental(machine_positions,xwidth,ylength,N,boundary)
    end
//




#####################################################
#### Visualise the multiple iterations solutions ####
#####################################################
//
    # define data in terms of a vector of random Walkers
    # for use in algebra of graphics
    AlgebraOfGraphics.data(w::Vector{Walker2D{Int64}}) = RandomWalker.position.(w)




    # take solution of T6SS
    # visualise solution
    # copy parameters used to figure folder for reference
    function visualise_save_solution(
        solution::NamedTuple,fig_num::Int,fig_sub_num::Tuple,fig_folder::String,parameter_file::String)
        figure_names = fig_labels.(fig_num,fig_sub_num)
        figure_folder = fig_labels(fig_num)
        data_name = fig_labels(fig_num,fig_sub_num)
        
        # Get maximum distance size based on 
        # xwidth and ylength of domain
        sindx = size(solution[:indx],1)
        
        # Get a dark cyan color for bar plot
        dark_cyan = colorant"#006390"

        # Set axis sizes
        lims = Tuple(reshape([-1/2,1/2].*[xwidth ylength],4,1))
        axishtmp = (width = 512, height = 512,aspect=1,limits = lims)
        axis = (width = 512, height = 512,aspect=1,xlimits = (0,sindx))
        
        # Set figure resolution
        #size_inches = (4, 3)
        #size_pt = 72 .* size_inches
        
        # Plot heatmap
        
        htmp = 
            data(solution[:machine_positions]) * 
            mapping("1" => L"x","2" => L"y") * 
            AlgebraOfGraphics.histogram()
        fhtmp = draw(htmp;axis = axishtmp,colorbar=(position=:top, size=25, label="Count"))

        

        # Plot distances for sample and experimental
        tab_dist_count = (
            x = repeat(solution[:indx],outer = sindx),
            y = vcat(
                solution[:count_experimental],
                solution[:count_sample]),
            c = repeat(["Experimental", "Sample"],inner = sindx))
        dist_count_bar = data(tab_dist_count) *
            mapping(:x => L"d",:y => L"count",color = :c => "Group") *
            visual(BarPlot)
        fdist_count_bar = draw(
            dist_count_bar;
            axis = axis, 
            legend=(position=:top, titleposition=:left, framevisible=true, padding=5))
        

        # Plot count norm ratio
        norm_count_bar = 
            data(solution) *
            mapping(:indx => L"d",:count_norm => L"count") * 
            visual(BarPlot,color=dark_cyan)
        fnorm_count_bar = draw(norm_count_bar;axis = axis)
        
        # Store figure in tuple 
        figures = (fhtmp,fdist_count_bar,fnorm_count_bar)

        
        

        # Save all figures
        [save(fig_folder*figure_folder*figure_names[i]*".pdf",figures[i],pt_per_unit = 1) for i in 1:3]

        # Copy parametes used in simultions to figure folder
        cp(
            parameter_file, 
            fig_folder*figure_folder*"ParameterConfig"*data_name*".txt"; 
            force = true)

    end

    function visualise_save_solution(
        solution::NamedTuple,fig_num::Int,fig_sub_num::Tuple,fig_folder::String,parameter_file::String;walker_ic::String = "random")
        figure_names = fig_labels.(fig_num,fig_sub_num)
        figure_folder = fig_labels(fig_num)
        data_name = fig_labels(fig_num,fig_sub_num)
        
        # Get maximum distance size based on 
        # xwidth and ylength of domain
        sindx = size(solution[:indx],1)
        
        # Get a dark cyan color for bar plot
        dark_cyan = colorant"#006390"

        # Set axis sizes
        lims = Tuple(reshape([-1/2,1/2].*[xwidth ylength],4,1))
        axishtmp = (width = 512, height = 512,aspect=1,limits = lims)
        axis = (width = 512, height = 512,aspect=1,xlimits = (0,sindx))
        
        # Set figure resolution
        #size_inches = (4, 3)
        #size_pt = 72 .* size_inches
        
        # Plot heatmap
        if walker_ic == "random"
        htmp = 
            data(solution[:machine_final]) * 
            mapping("1" => L"x","2" => L"y") * 
            AlgebraOfGraphics.histogram()
        else
            htmp = 
            data(solution[:machine_positions]) * 
            mapping("1" => L"x","2" => L"y") * 
            AlgebraOfGraphics.histogram()
        end
        fhtmp = draw(htmp;axis = axishtmp,colorbar=(position=:top, size=25, label="Count"))


        

        # Plot distances for sample and experimental
        tab_dist_count = (
            x = repeat(solution[:indx],outer = sindx),
            y = vcat(
                solution[:count_experimental],
                solution[:count_sample]),
            c = repeat(["Experimental", "Sample"],inner = sindx))
        dist_count_bar = data(tab_dist_count) *
            mapping(:x => L"d",:y => L"count",color = :c => "Group") *
            visual(BarPlot)
        fdist_count_bar = draw(
            dist_count_bar;
            axis = axis, 
            legend=(position=:top, titleposition=:left, framevisible=true, padding=5))
        

        # Plot count norm ratio
        norm_count_bar = 
            data(solution) *
            mapping(:indx => L"d",:count_norm => L"count") * 
            visual(BarPlot,color=dark_cyan)
        fnorm_count_bar = draw(norm_count_bar;axis = axis)
        
        # Store figure in tuple 
        figures = (fhtmp,fdist_count_bar,fnorm_count_bar)

        
        

        # Save all figures
        [save(fig_folder*figure_folder*figure_names[i]*".pdf",figures[i],pt_per_unit = 1) for i in 1:3]

        # Copy parametes used in simultions to figure folder
        cp(
            parameter_file, 
            fig_folder*figure_folder*"ParameterConfig"*data_name*".txt"; 
            force = true)

    end
//




############################################
#### Solve, visualise and save solution ####
############################################
//
    # aggregate all functions into this functions
    # all variables/parameters are defined in the 
    # parameter config file
    function run_simulation(parameter_file::String)
        # Solve 
        solution = solve(parameter_file)


        # Store visuals
        visualise_save_solution(
            solution,fig_num,fig_sub_num,fig_folder,parameter_file)
            
            # Create json path
        json_path = data_path(data_root,fig_num,fig_sub_num)    
        # Write to file
        write_solution_to_file(solution,json_path)
        return json_path
    end

    function run_simulation(parameter_file::String,walker_ic::String = "random")
        # Solve 
        if walker_ic == "random"
            solution = solve(parameter_file; walker_ic = walker_ic)
        else
            solution = solve(parameter_file)
        end


        # Store visuals
        visualise_save_solution(
            solution,fig_num,fig_sub_num,fig_folder,parameter_file)
            
            # Create json path
        json_path = data_path(data_root,fig_num,fig_sub_num)    
        # Write to file
        write_solution_to_file(solution,json_path)
        return json_path
    end
//
