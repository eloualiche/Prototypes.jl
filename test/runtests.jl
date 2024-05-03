using Prototypes
using Test

using PalmerPenguins
using DataFrames
using Random
import Statistics: quantile

const testsuite = [
    "tabulate", "winsorize"
]

printstyled("Running tests:\n", color=:blue, bold=true)

for test in testsuite
    # include("$test.jl")
    println("\033[1m\033[32mPASSED\033[0m: $(test)")
end

