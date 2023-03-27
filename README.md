
## Getting started with Julia
Download Julia with your favourite OS at the [download page](https://julialang.org/downloads/) for [www.julialang.org](https://julialang.org/). 

Once downloaded and installed, open a terminal session.

 ![julia terminal](https://github.com/fieldofnodes/T6ssSpaceTimeRedistribution/blob/main/figs/julia_terminal_begin.png)
 
 ## REPL
 Read, evaluate, print loop (REPL) is the terminal/shell interface to use with Julia.
 
 ```julia
 julia>
 ```
 To add a package press the `]` in the terminal
 
 ```julia
 julia> ]
 ```
 the terminal will automatically change to
 
 ```julia
 (@v1.8) pkg> 
 ```
 
 Note that `@v1.8` will appear if you open up Julia in any directory, to convert a current directory to a project, which is reccomented to ensure package versions are consitent and installed in desired places. For this project, download the repository
 
 ```
 
 ```
 
 
 ### Install Pluto

```julia
 ] add Pluto PlutoUI
 ```
 
## Package installations
This repository depends on three unregistered packages (unregistered as they have not requiest the general register to be accepted as a registered packagem,
1. [`Telegraph.jl`](https://github.com/fieldofnodes/Telegraph.jl)
2. [`RandomWalker.jl`](https://github.com/fieldofnodes/RandomWalker.jl)
3. [`T6SSModellingStochasticTimerRW.jl`](https://github.com/fieldofnodes/T6SSModellingStochasticTimerRW.jl) 

Still in the terminal, 
```julia
] add https://github.com/fieldofnodes/Telegraph.jl
] add https://github.com/fieldofnodes/RandomWalker.jl
] add https://github.com/fieldofnodes/T6SSModellingStochasticTimerRW.jl
```
### Script
```julia
using Pkg
Pkg.add(url = "https://github.com/fieldofnodes/Telegraph.jl")
Pkg.add(url = "https://github.com/fieldofnodes/RandomWalker.jl")
Pkg.add(url = "https://github.com/fieldofnodes/T6SSModellingStochasticTimerRW.jl")
```

Once complete run

```julia
using Telegraph
using RandomWalker
using T6SSModellingStochasticTimerRW
```
