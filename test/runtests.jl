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


N_COLS = 2
highlighters_ideal = (
    (hl_custom_gradient(cols=(N_COLS+1), colorscheme=:Oranges_9, scale=maximum(df_out.freq)),
     hl_custom_gradient(cols=(N_COLS+2), colorscheme=:Greens_9),
     hl_custom_gradient(cols=(N_COLS+3), colorscheme=:Greens_9) )
     )

typeof(highlighters_ideal)

highlighters = (
            (hl_custom_gradient(cols=(N_COLS+1), colorscheme=:Oranges_9, scale=maximum(df_out.freq)),
             hl_custom_gradient(cols=(N_COLS+2), colorscheme=:Greens_9),
             hl_custom_gradient(cols=(N_COLS+3), colorscheme=:Greens_9) )...,
            (map(i -> (hl_col(i, crayon"cyan bold")), 1:N_COLS))
        )

typeof(highlighters)
flatten(highlighters)
x = vcat(highlighters...)


