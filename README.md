# Prototypes

[![CI](https://github.com/eloualiche/Prototypes.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/eloualiche/Prototypes.jl/actions/workflows/CI.yml)
[![Lifecycle:Experimental](https://img.shields.io/badge/Lifecycle-Experimental-339999)](https://github.com/eloualiche/Prototypes.jl/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/eloualiche/Prototypes.jl/graph/badge.svg?token=53QO3HSSRT)](https://codecov.io/gh/eloualiche/Prototypes.jl)

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


## Usage

### Tabulate data

The `tabulate` function tries to emulate the tabulate function from stata (see oneway [here](https://www.stata.com/manuals/rtabulateoneway.pdf) or twoway [here](https://www.stata.com/manuals13/rtabulatetwoway.pdf)).
This relies on the `DataFrames.jl` package and is useful to get a quick overview of the data.

```julia
using DataFrames
using Prototypes
using PalmerPenguins

df = DataFrame(PalmerPenguins.load())

tabulate(df, :island)
tabulate(df, [:island, :species])

# If you are looking for groups by type (detect missing e.g.)
df = DataFrame(x = [1, 2, 2, "NA", missing], y = ["c", "c", "b", "z", "d"])
tabulate(df, [:x, :y], group_type = :type) # only types for all group variables
tabulate(df, [:x, :y], group_type = [:value, :type]) # mix value and types
```

I have not implemented all the features of the stata tabulate function, but I am open to [suggestions](#3).


### Winsorize data

There was no standard function to winsorize data in julia, so I implemented one.
This is fairly standard and I offer options to specify probabilities or cutpoints; moreover you can replace the values that are winsorized with a missing, the cutpoints, or some specific values.

The test suit has a large set of all the different examples, but you can start using it like this:
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

Sometimes it is unpractical to work with unbalanced panel data.
There are many ways to fill values between dates (what interpolation to use) and I try to implement a few of them.
I use the function sparingly, so it has not been tested extensively.

See the following example (or the test suite) for more information.
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

This one is a little niche.
I wanted to have a custom logger that would allow me to filter messages from specific modules and redirect them to different files, which I find useful to monitor long jobs in a format that is easy to read and that I can control.
The formatter is hard-coded to what I like but I guess I could change it easily and make it an option.

Here is an example where you can create a custom logger and redirect logging to different files
```julia
custom_logger(
        "./log/logfile-prefix";                                   # where are the files generated (will generate 4 files for different log levels)

        filtered_modules_all=[:HTTP],                             # filtering messages across all loggers from specific modules
        filtered_modules_specific=[:TranscodingStreams],          # filtering messages for stdout and info from specific modules

        create_log_files=true,                                    # if false all logs are written to a single file
        log_date_format="yyyy-mm-dd", log_time_format="HH:MM:SS", # date and time formatting
        displaysize=(50,100),                                     # how much to show
        overwrite=true                                            # overwrite old logs
        );

# if you have run the previous example
@info tabulate(df, :island, out=:string)
@warn tabulate(df, :island, out=:df)
@debug tabulate(df, :island)
```


### Future work ...

I am writing some documentation that will a little more complete than this readme.

See my other package [FinanceRoutines.jl](https://github.com/eloualiche/FinanceRoutines.jl) which is more focused and centered on working with financial data.
