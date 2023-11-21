# ------------------------------------------------------------------------------------------

# StataUtils.jl

# Collection of functions that replicate some stata utilities
# ------------------------------------------------------------------------------------------



# ------------------------------------------------------------------------------------------
# List of exported functions
 # tabulate # (tab alias)
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

# TO DO
allow user to specify order of columns (reorder = false flag)
"""
function tabulate(df::AbstractDataFrame, cols::Union{Symbol, Array{Symbol}};
    reorder_cols=true)

    if typeof(cols) <: Symbol
        N_COLS = 1
    else
        N_COLS = size(cols,1)
        # error("Only accepts one variable for now ...")
    end


# debug
    # cols = :island
    # cols = [:island, :species]
    # df = dropmissing(DataFrame(PalmerPenguins.load()))


    # Count the number of observations by `columns`
    # tab = combine(groupby(df, cols), cols .=> length)
    df_out = combine(groupby(df, cols), nrow => :freq, proprow =>:pct)
    if reorder_cols
        sort!(df_out, cols)                          # order before we build cumulative
    end
    transform!(df_out, :pct => cumsum => :cum)   # Construct a Frequency Column

    pretty_table(df_out;
        hlines = [1],
        vlines = [N_COLS],
        alignment = vcat(repeat([:l], N_COLS), :c, :c, :c),
        cell_alignment = reduce(push!, 
            map(i -> (i,1)=>:l, 1:N_COLS+3), 
            init=Dict{Tuple{Int64, Int64}, Symbol}()),
        header = [string.(cols); "Freq."; "Percent"; "Cum"],
        formatters = (ft_printf("%.2f", 3), ft_printf("%.2f", 4)),
        highlighters = (
            hl_col(1, crayon"cyan bold"),
            hl_col(2, crayon"cyan bold"),
            hl_custom_gradient(cols=(N_COLS+1), colorscheme=:Oranges_9, scale=maximum(df_out.freq)),
            hl_custom_gradient(cols=(N_COLS+2), colorscheme=:Greens_9),
            hl_custom_gradient(cols=(N_COLS+3), colorscheme=:Greens_9)            
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
    colorscheme::Symbol=:Oranges_9,
    scale::Int=1) 

    Highlighter(
        (data, i, j) -> j==cols,
        (h, data, i, j) -> begin
            color = get(colorschemes[colorscheme], data[i, j], (0, scale))
             return Crayon(foreground = (round(Int, color.r * 255),
                                         round(Int, color.g * 255),
                                         round(Int, color.b * 255)))
    end)
end
# ------------------------------------------------------------------------------------------
