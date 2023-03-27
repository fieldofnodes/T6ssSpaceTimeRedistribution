

## Download (clone) the repository

For this project, download the repository
 
 ```
 git clone git@github.com:fieldofnodes/T6ssSpaceTimeRedistribution.git
 ```
 
 Note my preferred cloning is through an SSH connection. Feel free to do so in another way. Once the repository is downloaded, navigate to the root folder such that 
 
 ```bash
 ~/Projects/T6ssSpaceTimeRedistribution$
 ```
in an Ubuntu machine for example. Next the download of Julia is discussed.


## Getting started with Julia
Download Julia with your favourite OS at the [download page](https://julialang.org/downloads/) for [www.julialang.org](https://julialang.org/). 

Once downloaded and installed, open Julia in a terminal session. 

1. For MAC/Windows there will be an application icon, double click and a Julia session will commence.
2. In Linux based machines, the folder for the julia tar ball will have `~/julia/bin/` and the executable `./julia` and a session will open.
    1. Alternatively add it to path to access from anywhere.
3. Please read instructions online at Julia for OS specific directions.

If all goes well a Julia session should appear as    

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
 
Note that `@v1.8` will appear if you open up Julia in any directory, to convert a current directory to a project, which is reccomented to ensure package versions are consitent and installed in desired places. 

If not sure which directory Julia has been opened in then 

```julia
pwd()
```
will display the current directory. If Julia is not opened in the desired directory then get the text version of the full directory and enter

```julia
cd("path/in/quotes/to/project")
```
then run 

```julia
pwd()
```
and confirm correct directory. Then press `]`
 
 ```julia
 julia> ]
 ```
the terminal should read
 
 ```julia
 (@v1.8) pkg> 
 ```
 then type 
 ```julia
 (@v1.8) pkg> activate .

``` 
this will activate the current director as a project. As `T6ssSpaceTimeRedistribution` already contains the `Manifest.toml` and `Project.toml` files, Julia will read it is a project and will display

```julia
 (T6ssSpaceTimeRedistribution) pkg> 
 ```
This means Julia is opened at the correct directory. Next some package need to be installed.
 
 ### Install Pluto and PlutoUI
 
 Still in the temrinal `(T6ssSpaceTimeRedistribution) pkg>` should be waiting for an input

```julia
 add Pluto PlutoUI
 ```
 
 `Pluto.jl` is a package that allows Julia to be executed in a browser based notebook. `PlutoUI.jl` is a helper package to Pluto to show a table of contents in the notebook.
 
## Paper relevant package installations

This repository depends on three unregistered packages (unregistered as they have not requiest the general register to be accepted as a registered packaged,

1. [`Telegraph.jl`](https://github.com/fieldofnodes/Telegraph.jl)
2. [`RandomWalker.jl`](https://github.com/fieldofnodes/RandomWalker.jl)
3. [`T6SSModellingStochasticTimerRW.jl`](https://github.com/fieldofnodes/T6SSModellingStochasticTimerRW.jl) 

Still in the terminal, 

```julia
add https://github.com/fieldofnodes/Telegraph.jl
add https://github.com/fieldofnodes/RandomWalker.jl
add https://github.com/fieldofnodes/T6SSModellingStochasticTimerRW.jl


Once complete run

```julia
using Pluto
```

```julia
Pluto.run()
```



