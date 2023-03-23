### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ 31c8a0c2-1fcb-43c8-9879-59ea400faed9
begin
	using Pkg
	Pkg.activate(".")
	using PlutoUI
	PlutoUI.TableOfContents()
	Pkg.add(url = "https://github.com/fieldofnodes/Telegraph.jl")
	Pkg.add(url = "https://github.com/fieldofnodes/RandomWalker.jl")
	Pkg.add(url = "https://github.com/fieldofnodes/T6SSModellingStochasticTimerRW.jl")
end

# ╔═╡ a53f5f3b-ce19-45a8-b115-4a49c616480e
begin
	using Telegraph
	using RandomWalker
	using T6SSModellingStochasticTimerRW
end

# ╔═╡ d70a45dc-c920-11ed-0746-775e23b3881d
md"""
# Space and time on the membrane: a model of Type VI secretion system redistribution

## Jonathan Miller, Philip J. Murray

### Process to generate figures 3,4,5 from this paper

1. Load the package. The packages are not registered with the general registry, so please add them as `Pkg.add(url = github-package-name.jl)`, which is completed in the next cell.
2. For each cell, press the play icon to run that cell. Each cell `generate_figure_#` will simulate the data and the figures, this can take some time depending on your computer. 
3. Note too that `Pluto` notebooks are reactive with eachother.
"""

# ╔═╡ e27178ef-929c-40fd-bc85-c0f8cf85e265
md"""
### Figure 3
Figure 3 consists of four plots, $a,b,c$ and $d$.
"""

# ╔═╡ 7c5abd94-ab8d-4265-a684-c5d67bf38369
figure_3 = generate_figure_3()

# ╔═╡ 59de2e82-9437-4fcb-ad87-d32a0b9dea5f
figure_3[:a]

# ╔═╡ 78c5a4a7-ec80-4e2e-8763-052fd2e9fa3d
figure_3[:b]

# ╔═╡ 026559d7-a284-4bd0-ba5c-812e1dc10739
figure_3[:c]

# ╔═╡ 6772f69e-7862-4180-9738-571485904e8c
figure_3[:d]

# ╔═╡ 9c7001d6-ecb6-483d-b85a-87920ef1b692
md"""
### Figure 4
Figure 4 consists of four plots, $a,b,c$ and $d$.
"""

# ╔═╡ 6e652315-7882-476a-91e3-1ebbe4293ec1
figure_4 = generate_figure_4()

# ╔═╡ 4d880403-6900-45e6-bdc9-52b8c4736d59


# ╔═╡ 6f2b35d8-3bd6-43fe-b35a-fcde5c16af54


# ╔═╡ 2146790d-7ef8-46bc-aa3b-19ccbefb7bda


# ╔═╡ 599eb2b3-8ead-4ce8-b1e1-b1be5070b112


# ╔═╡ cbdc53b4-a54b-49d9-9cb4-47df6693e0e1
md"""
### Figure 5
Figure 5 consists of four plots, $a,b,c$ and $d$.
"""

# ╔═╡ 24ae2017-5214-4242-a475-e2ad27518543


# ╔═╡ 99f38dc1-525d-4265-9176-0798ce5b2462


# ╔═╡ 146e2d55-b295-4430-975e-dc7bbfbaeaad


# ╔═╡ aec4163c-bf37-4c91-a67d-cc50dc4885db


# ╔═╡ e9308aa6-aac0-4330-b322-d4710dd75c85


# ╔═╡ Cell order:
# ╟─d70a45dc-c920-11ed-0746-775e23b3881d
# ╠═31c8a0c2-1fcb-43c8-9879-59ea400faed9
# ╠═a53f5f3b-ce19-45a8-b115-4a49c616480e
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
