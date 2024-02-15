# Prototypes

[![CI](https://github.com/eloualiche/Prototypes.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/eloualiche/Prototypes.jl/actions/workflows/CI.yml)
[![Lifecycle:Experimental](https://img.shields.io/badge/Lifecycle-Experimental-339999)](https://github.com/eloualiche/Prototypes.jl/actions/workflows/CI.yml)


`Prototypes.jl` is a placeholder package for some functions that I use in julia frequently.

So far the package provides one function to tabulate data in a dataframe and some custom logging function.
Note that as the package grow in different directions, dependencies might become overwhelming. Feel  c 

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
