# Prototypes

[![CI](https://github.com/eloualiche/Prototypes.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/eloualiche/Prototypes.jl/actions/workflows/CI.yml)
[![Lifecycle:Experimental](https://img.shields.io/badge/Lifecycle-Experimental-339999)](https://github.com/eloualiche/Prototypes.jl/actions/workflows/CI.yml)


`Prototypes.jl` is a placeholder package for some functions that I use in julia frequently.

So far the package provides a couple of functions 
  
  1. tabulate some data (`tabulate`)
  2. winsorize some data (`winsorize`)
  3. fill unbalanced panel data (`panel_fill`)
  4. some custom logging function (`custom_logger`)

Note that as the package grow in different directions, dependencies might become overwhelming. 
The readme serves as documentation; there might be more examples inside of the test folder.

## Installation

`Prototypes.jl` is a not yet a registered package.
You can install it from github  via

```julia
import Pkg
Pkg.add(url="https://github.com/eloualiche/Prototypes.jl")
```

## Examples


### Tabulate data

First import the monthly stock file and the compustat funda file
```julia
using DataFrames
using Prototypes
using PalmerPenguins

df = DataFrame(PalmerPenguins.load())

tabulate(df, :island)
tabulate(df, [:island, :species])
```

### Winsorize data

```julia
using DataFrames
using Prototypes
using PalmerPenguins

df = DataFrame(PalmerPenguins.load())
winsorize(df.flipper_length_mm, probs=(0.05, 0.95)) # skipmissing by default
transform(df, :flipper_length_mm => 
    (x->winsorize(x, probs=(0.05, 0.95), replace_value=missing)), renamecols=false)
```

### Panel Fill

```julia
df3 = DataFrame(        # missing t=2 for id=1
    id = ["a","a", "b","b", "c","c","c", "d","d","d","d"], 
    t  = [Date(1990, 1, 1), Date(1990, 4, 1), Date(1990, 8, 1), Date(1990, 9, 1),
          Date(1990, 1, 1), Date(1990, 2, 1), Date(1990, 4, 1),
          Date(1999, 11, 10), Date(1999, 12, 21), Date(2000, 2, 5), Date(2000, 4, 1)],
    v1 = [1,1, 1,6, 6,0,0, 1,4,11,13],
    v2 = [1,2,3,6,6,4,5, 1,2,3,4],
    v3 = [1,5,4,6,6,15,12.25, 21,22.5,17.2,1]) 

panel_fill(df3, :id, :t, [:v1, :v2, :v3], 
    gap=Month(1), method=:backwards, uniquecheck=true, flag=true, merge=true)
panel_fill(df3, :id, :t, [:v1, :v2, :v3], 
    gap=Month(1), method=:forwards, uniquecheck=true, flag=true, merge=true)
panel_fill(df3, :id, :t, [:v1, :v2, :v3], 
    gap=Month(1), method=:linear, uniquecheck=true, flag=true, merge=true)

```

### Custom Logging

Here is an example where you can create a custom logger and redirect logging to different files
```julia
custom_logger("file_to_log",                                  # where are the files generated
    filtered_modules=[:TranscodingStreams, :StatsModels],     # filtering msg only for debug
    absolute_filtered_modules=[:TranscodingStreams],          # filtering msg for all
    log_date_format="yyyy-mm-dd", log_time_format="HH:MM:SS", # date and time formatting
    displaysize=(50,100),                                     # how much to show
    overwrite=false                                           # overwrite old logs
    )

# if you have run the previous example
@info tabulate(df, :island, out=:string)
@warn tabulate(df, :island, out=:df)
@debug tabulate(df, :island)
```
