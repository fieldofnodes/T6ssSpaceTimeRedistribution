
## Installation
This repository depends on two other unregistered packages which I wrote, `Telegraph.jl` and `RandomWalker.jl`. To install this package, `T6SSModellingStochasticTimerRW.jl` open julia in your preferred way.

### `REPL`
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
