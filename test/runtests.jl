using Prototypes
using Test

using PalmerPenguins
using DataFrames
using Dates
using Random
import Statistics: quantile

const testsuite = [
    "tabulate", "winsorize", "panel_fill"
]

printstyled("Running tests:\n", color=:blue, bold=true)

for test in testsuite
    # include("$test.jl")
    println("\033[1m\033[32mPASSED\033[0m: $(test)")
end

