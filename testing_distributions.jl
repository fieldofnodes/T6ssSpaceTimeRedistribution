### A Pluto.jl notebook ###
# v0.18.1

using Markdown
using InteractiveUtils

# ╔═╡ f044c094-9ff6-11ec-0a93-29df5fd65576
using Pkg;Pkg.activate(".");using PlutoUI;PlutoUI.TableOfContents()

# ╔═╡ 788cbe38-b107-4422-b7f8-35c1775d422b
begin
	using RandomWalker
	using Telegraph
	using AlgebraOfGraphics
	using JSON3
	using Distances
	using Colors
	using StructTypes
	using Chain
	using CairoMakie
	using Distributed
end

# ╔═╡ f9b77acd-2a29-4911-b852-2bef9b3766b1
include("FunctionsNeeded.jl")

# ╔═╡ e9920f71-3bce-45c9-9d1b-cf0885265a09


# ╔═╡ 69322f2c-5756-45e7-b68c-2b5d835ec280
parameters = @chain "parameters/" begin
    find(_,0,1,"jl")
    filter(x -> !occursin.("2abcd",x),_)
    filter(x -> !occursin.("6abc",x),_)
    filter(x -> !occursin.("6def",x),_)
    sort(_)
end

# ╔═╡ 5f1ef3fc-7281-4715-aa66-8ac84347018f
md"""
### Simulate first and last positions of the random walk
"""

# ╔═╡ 1a395aa5-da69-4321-a463-051abb584cce
begin
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
	# get simulation of randomly drawn samples
	function simulate_random_walk(xwidth,ylength,N)
        w() = (first_walker = get_random_position(xwidth,ylength;step=1),
        last_walker = get_random_position(xwidth,ylength;step=1))
        sols = [w() for i in 1:10^N]
        return (machine_positions = sols)
    end
	
end

# ╔═╡ 5c20d38b-5d9b-4b60-9932-443039f0122f
begin
	N,xwidth,ylength,boundary = 6,20,20,"no_flux"
	machine_positions = simulate_random_walk(xwidth,ylength,N)
	solution = get_distance_count_sample_experimental(machine_positions,xwidth,ylength,N,boundary)
end

# ╔═╡ 8f5b4153-a062-4482-b019-36165a5ec50f
begin
	dark_cyan = colorant"#006390"
	sindx = size(solution[:indx],1)
	lims = Tuple(reshape([-1/2,1/2].*[xwidth ylength],4,1))
	axis = (width = 512, height = 512,aspect=1,xlimits = (0,sindx))
	norm_count_bar = 
		data(solution) *
		mapping(:indx => L"d",keys(solution)[5] => L"count") * 
		visual(BarPlot,color=dark_cyan)
	fnorm_count_bar = draw(norm_count_bar;axis = axis)
	tab_dist_count = (
    x = repeat(solution[:indx],outer = sindx),
    y = vcat(
        solution[:count_experimental],
        solution[:count_sample]),
    c = repeat(["Experimental", "Sample"],inner = sindx))
end

# ╔═╡ 8681ff77-ee27-4a86-ac09-c8ac4b4431c1
begin
	dist_count_bar = data(tab_dist_count) *
    	mapping(:x => L"d",:y => L"count",color = :c => "Group") *
    	visual(BarPlot, alpha = 0.4)
	fdist_count_bar = draw(
    	dist_count_bar;
    	axis = axis, 
    	legend=(position=:top, titleposition=:left, framevisible=true, padding=5))
end

# ╔═╡ 6ef96761-54f7-474c-8cc9-dea599e8239f
md"""
## Use the solve function
"""

# ╔═╡ d8a85c0c-5803-4972-a78b-62a4ad329e2a
soluition1 = solve(parameters[2];walker_ic = "random")

# ╔═╡ e711391f-a9bf-4cc2-8b85-fda03a08d837


# ╔═╡ Cell order:
# ╠═f044c094-9ff6-11ec-0a93-29df5fd65576
# ╠═788cbe38-b107-4422-b7f8-35c1775d422b
# ╠═e9920f71-3bce-45c9-9d1b-cf0885265a09
# ╠═f9b77acd-2a29-4911-b852-2bef9b3766b1
# ╠═69322f2c-5756-45e7-b68c-2b5d835ec280
# ╟─5f1ef3fc-7281-4715-aa66-8ac84347018f
# ╠═1a395aa5-da69-4321-a463-051abb584cce
# ╠═5c20d38b-5d9b-4b60-9932-443039f0122f
# ╠═8f5b4153-a062-4482-b019-36165a5ec50f
# ╠═8681ff77-ee27-4a86-ac09-c8ac4b4431c1
# ╠═6ef96761-54f7-474c-8cc9-dea599e8239f
# ╠═d8a85c0c-5803-4972-a78b-62a4ad329e2a
# ╠═e711391f-a9bf-4cc2-8b85-fda03a08d837
