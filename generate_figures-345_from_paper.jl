### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ 31c8a0c2-1fcb-43c8-9879-59ea400faed9
begin
	using Pkg
	Pkg.activate(".")
	using PlutoUI
	using Telegraph
	using RandomWalker
	using T6SSModellingStochasticTimerRW
end

# ╔═╡ d70a45dc-c920-11ed-0746-775e23b3881d
md"""
# Space and time on the membrane: a model of Type VI secretion system redistribution

## Jonathan Miller, Philip J. Murray

### Process to generate figures 3,4,5 from this paper
"""

# ╔═╡ c084fea8-b047-4f33-b6cc-d611ce15464c
TableOfContents(title="Table of contents")

# ╔═╡ bb466644-c211-41d3-b2a1-0981a0d40929
md"""
## Load the parameter functions
"""

# ╔═╡ 5d3217e6-a83c-4345-843f-e3a8723f4e7e
md"""
The variable `simulation_iterations` is $10^{\mathrm{simulation\_iterations}}$ and in the paper was set to `simulation_iterations = 4`. Here I set it to `0` and it is to be changed by the user, as `Pluto` notebooks are reactive and will commence by running all cells in one go. Once everything has loaded, then change to $4$. Note that some of these parameters are updated inside the function call depending on the figure.
"""

# ╔═╡ 532df85f-3a4a-4e20-90e2-8790fdccceed
begin
	simulation_iterations = 0 # 10^simulation_iterations: ran for, 4 normally
	parameter_iterations = 50 
	input_values = pre_defined_params(simulation_iterations,parameter_iterations);
end

# ╔═╡ e27178ef-929c-40fd-bc85-c0f8cf85e265
md"""
### Figure 3
Figure 3 consists of four plots, $a,b,c$ and $d$.
"""

# ╔═╡ 7c5abd94-ab8d-4265-a684-c5d67bf38369
# ╠═╡ disabled = true
#=╠═╡
figure_3 = generate_figure_3(input_values)
  ╠═╡ =#

# ╔═╡ 59de2e82-9437-4fcb-ad87-d32a0b9dea5f
# ╠═╡ disabled = true
#=╠═╡
figure_3[:a]
  ╠═╡ =#

# ╔═╡ 78c5a4a7-ec80-4e2e-8763-052fd2e9fa3d
# ╠═╡ disabled = true
#=╠═╡
figure_3[:b]
  ╠═╡ =#

# ╔═╡ 026559d7-a284-4bd0-ba5c-812e1dc10739
# ╠═╡ disabled = true
#=╠═╡
figure_3[:c]
  ╠═╡ =#

# ╔═╡ 6772f69e-7862-4180-9738-571485904e8c
# ╠═╡ disabled = true
#=╠═╡
figure_3[:d]
  ╠═╡ =#

# ╔═╡ 9c7001d6-ecb6-483d-b85a-87920ef1b692
md"""
### Figure 4
Figure 4 consists of four plots, $a,b,c$ and $d$.
"""

# ╔═╡ 6e652315-7882-476a-91e3-1ebbe4293ec1
figure_4 = generate_figure_4(input_values)

# ╔═╡ 4d880403-6900-45e6-bdc9-52b8c4736d59
figure_4[:a]

# ╔═╡ 6f2b35d8-3bd6-43fe-b35a-fcde5c16af54
# ╠═╡ disabled = true
#=╠═╡
figure_4[:b]
  ╠═╡ =#

# ╔═╡ 2146790d-7ef8-46bc-aa3b-19ccbefb7bda
# ╠═╡ disabled = true
#=╠═╡
figure_4[:c]
  ╠═╡ =#

# ╔═╡ 599eb2b3-8ead-4ce8-b1e1-b1be5070b112
# ╠═╡ disabled = true
#=╠═╡
figure_4[:d]
  ╠═╡ =#

# ╔═╡ cbdc53b4-a54b-49d9-9cb4-47df6693e0e1
md"""
### Figure 5
Figure 5 consists of four plots, $a,b,c$ and $d$.
"""

# ╔═╡ 24ae2017-5214-4242-a475-e2ad27518543
# ╠═╡ disabled = true
#=╠═╡
figure_5 = generate_figure_5(input_values)
  ╠═╡ =#

# ╔═╡ 99f38dc1-525d-4265-9176-0798ce5b2462
# ╠═╡ disabled = true
#=╠═╡
figure_5[:a]
  ╠═╡ =#

# ╔═╡ 146e2d55-b295-4430-975e-dc7bbfbaeaad
# ╠═╡ disabled = true
#=╠═╡
figure_5[:b]
  ╠═╡ =#

# ╔═╡ aec4163c-bf37-4c91-a67d-cc50dc4885db
# ╠═╡ disabled = true
#=╠═╡
figure_5[:c]
  ╠═╡ =#

# ╔═╡ e9308aa6-aac0-4330-b322-d4710dd75c85
# ╠═╡ disabled = true
#=╠═╡
figure_5[:d]
  ╠═╡ =#

# ╔═╡ Cell order:
# ╟─d70a45dc-c920-11ed-0746-775e23b3881d
# ╠═31c8a0c2-1fcb-43c8-9879-59ea400faed9
# ╟─c084fea8-b047-4f33-b6cc-d611ce15464c
# ╟─bb466644-c211-41d3-b2a1-0981a0d40929
# ╟─5d3217e6-a83c-4345-843f-e3a8723f4e7e
# ╠═532df85f-3a4a-4e20-90e2-8790fdccceed
# ╟─e27178ef-929c-40fd-bc85-c0f8cf85e265
# ╠═7c5abd94-ab8d-4265-a684-c5d67bf38369
# ╠═59de2e82-9437-4fcb-ad87-d32a0b9dea5f
# ╠═78c5a4a7-ec80-4e2e-8763-052fd2e9fa3d
# ╠═026559d7-a284-4bd0-ba5c-812e1dc10739
# ╠═6772f69e-7862-4180-9738-571485904e8c
# ╟─9c7001d6-ecb6-483d-b85a-87920ef1b692
# ╠═6e652315-7882-476a-91e3-1ebbe4293ec1
# ╠═4d880403-6900-45e6-bdc9-52b8c4736d59
# ╠═6f2b35d8-3bd6-43fe-b35a-fcde5c16af54
# ╠═2146790d-7ef8-46bc-aa3b-19ccbefb7bda
# ╠═599eb2b3-8ead-4ce8-b1e1-b1be5070b112
# ╟─cbdc53b4-a54b-49d9-9cb4-47df6693e0e1
# ╠═24ae2017-5214-4242-a475-e2ad27518543
# ╠═99f38dc1-525d-4265-9176-0798ce5b2462
# ╠═146e2d55-b295-4430-975e-dc7bbfbaeaad
# ╠═aec4163c-bf37-4c91-a67d-cc50dc4885db
# ╠═e9308aa6-aac0-4330-b322-d4710dd75c85
