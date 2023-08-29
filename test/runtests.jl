using Prototypes
using Test
using PalmerPenguins
using DataFrames

@testset "Prototypes.jl" begin

    df = dropmissing(DataFrame(PalmerPenguins.load()))
    cols = :island
    tab = combine(groupby(df, cols), cols .=> length => :_N)
    tabulate(df, :island)

    # Write your tests here.
end
