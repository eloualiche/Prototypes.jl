# ------------------------------------------------------------------------------------------

# StataUtils.jl

# Collection of functions that replicate some stata utilities
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# List of exported functions
 # tabulate # (tab alias)
# ------------------------------------------------------------------------------------------


# ------------------------------------------------------------------------------------------
function greet_FinanceRoutines()
    return "Hello FinanceRoutines!"
end
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
"""
    tabulate(array::MyArray{T}, val::T; verbose=true) where {T} -> Int

tabulate the values for the specific columns of a dataframe
builtin search :)
This was forked from TexTables.jl

# Arguments
- `df::AbstractDataFrame`: DataFrame to tabulate
- `cols::Symbol`: (single) column to tabulate

# Keywords
- `verbose::Bool=true`: print out progress details

# Returns
- `PrettyTableInt`: the index where `val` is located in the `array`

# Throws
- `NotFoundError`: I guess we could throw an error if `val` isn't found.
"""
function tabulate(df::AbstractDataFrame, cols::Symbol)

# debug
    # cols = :island
    # df = dropmissing(DataFrame(PalmerPenguins.load()))

    if length(cols) > 1
        error("Only accepts one variable for now ...")
    end

    # Count the number of observations by `columns`
    tab = combine(groupby(df, cols), cols => length => :_N)

    # Construct a Frequency Column
    sort!(tab, cols)
    vals  = Symbol.(tab[!,cols])
    freq  = tab[!,:_N]
    pct   = freq/sum(freq)*100
    cum   = cumsum(pct)

    # Construct Table 
    df_out = DataFrame(vals=vals, freq=freq, pct=pct, cum=cum)

    pretty_table(df_out;
        hlines = [1],
        vlines = [1],
        alignment = [:l, :c, :c, :c],
        cell_alignment     = Dict((1, 1) => :l, 
            (2, 1) => :l, (3, 1) => :l, (4, 1) => :l),
        header = [string(cols); "Freq."; "Percent"; "Cum"],
        formatters = (ft_printf("%.2f", 3), ft_printf("%.2f", 4)),
        highlighters = (
            hl_col(1, crayon"cyan bold"),
            hl_custom_gradient(cols=3, colorscheme=:Oranges_9),
            hl_custom_gradient(cols=4, colorscheme=:BuGn_6)
        ),
        border_crayon = crayon"bold yellow", 
        header_crayon = crayon"bold light_green",
        show_header = true,
        )

end
# ------------------------------------------------------------------------------------------


# ------------------------------------------------------------------------------------------
function hl_custom_gradient(; 
    cols::Int=0, 
    colorscheme::Symbol=:Oranges_9) 

    Highlighter(
        (data, i, j) -> j==cols,
        (h, data, i, j) -> begin
            # color = get(colorschemes[colorscheme], data[i, j], (0, 100))
            color = get(colorschemes[colorscheme], data[i, j], (0, 100))
             return Crayon(foreground = (round(Int, color.r * 255),
                                         round(Int, color.g * 255),
                                         round(Int, color.b * 255)))
    end)
end
# ------------------------------------------------------------------------------------------
