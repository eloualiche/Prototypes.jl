using Prototypes
using Test
using PalmerPenguins
using DataFrames

@testset "Prototypes.jl" begin

    df = dropmissing(DataFrame(PalmerPenguins.load()))
    cols = :island
    col_length = combine(groupby(df, cols), cols .=> length => :_N)
    sort!(col_length, cols)
    col_tab = tabulate(df, :island; out=:df);
    sort!(col_tab, cols)

    @test col_length._N == col_tab.freq

end

