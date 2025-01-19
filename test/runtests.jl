# --------------------------------------------------------------------------------------------------
using Prototypes
using Test

using PalmerPenguins
using DataFrames
using Dates
import HTTP
import Logging: global_logger
import LoggingExtras: ConsoleLogger, TeeLogger
using Random
import Statistics: quantile
using StreamToString

const testsuite = [
    "tabulate", "winsorize", "panel_fill", "customlogger"
]


ENV["DATADEPS_ALWAYS_ACCEPT"] = true # for data loading of PalmerPenguins
# --------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------
printstyled("Running tests:\n", color=:blue, bold=true)

@testset verbose=true "Prototypes.jl" begin
    for test in testsuite
        println("\033[1m\033[32m  → RUNNING\033[0m: $(test)")
        include("UnitTests/$test.jl")
        println("\033[1m\033[32m  PASSED\033[0m")
    end
end
# --------------------------------------------------------------------------------------------------
