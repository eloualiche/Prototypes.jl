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
    tabulate(df::AbstractDataFrame, cols::Union{Symbol, Array{Symbol}}; 
        reorder_cols=true, out::Symbol=:stdout)

tabulate the values for the specific columns of a dataframe
builtin search :)
This was forked from TexTables.jl

# Arguments
- `df::AbstractDataFrame`: DataFrame to tabulate
- `cols::Symbol`: (single) column to tabulate

# Keywords
- `reorder_cols::Bool=true`: sort by columns
- `out::Symbol=:stdout`: output is a nothing; other options are :string for string; :df for a dataframe

# Returns
- `PrettyTableInt`: the index where `val` is located in the `array`

# Throws
- `NotFoundError`: I guess we could throw an error if `val` isn't found.

# TO DO
allow user to specify order of columns (reorder = false flag)
"""
function tabulate(df::AbstractDataFrame, cols::Union{Symbol, Array{Symbol}};
    reorder_cols=true, out::Symbol=:stdout)

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
    df_out = combine(groupby(df, cols), nrow => :freq, proprow =>:pct)
    if reorder_cols
        sort!(df_out, cols)                          # order before we build cumulative
    end
    transform!(df_out, :pct => cumsum => :cum, :freq => (x-> Int.(x)) => :freq) 

    col_highlighters = vcat(
        map(i -> (hl_col(i, crayon"cyan bold")), 1:N_COLS),
        hl_custom_gradient(cols=(N_COLS+1), colorscheme=:Oranges_9, scale=maximum(df_out.freq)),
        hl_custom_gradient(cols=(N_COLS+2), colorscheme=:Greens_9),
        hl_custom_gradient(cols=(N_COLS+3), colorscheme=:Greens_9)    
    )
    col_highlighters = Tuple(x for x in col_highlighters)


    if out ∈ [:stdout, :df]

        pretty_table(df_out;
            hlines = [1],
            vlines = [N_COLS],
            alignment = vcat(repeat([:l], N_COLS), :c, :c, :c),
            cell_alignment = reduce(push!, 
                map(i -> (i,1)=>:l, 1:N_COLS+3), 
                init=Dict{Tuple{Int64, Int64}, Symbol}()),
            header = [string.(cols); "Freq."; "Percent"; "Cum"],
            formatters = (ft_printf("%d", 1), ft_printf("%d", 3), ft_printf("%.3f", 4), ft_printf("%.2f", 5)),
            highlighters = col_highlighters,   
            border_crayon = crayon"bold yellow", 
            header_crayon = crayon"bold light_green",
            show_header = true,
        )

        if out==:stdout
            return(nothing)
        elseif out==:df
            return(df_out)
        end
        
    elseif out==:string # this might be costly as I am regenerating the table. 
        pt = pretty_table(String, df_out;
            hlines = [1],
            vlines = [N_COLS],
            alignment = vcat(repeat([:l], N_COLS), :c, :c, :c),
            cell_alignment = reduce(push!, 
                map(i -> (i,1)=>:l, 1:N_COLS+3), 
                init=Dict{Tuple{Int64, Int64}, Symbol}()),
            header = [string.(cols); "Freq."; "Percent"; "Cum"],
            formatters = (ft_printf("%d", 1), ft_printf("%d", 3), ft_printf("%.3f", 4), ft_printf("%.2f", 5)),
            highlighters = col_highlighters,   
            border_crayon = crayon"bold yellow", 
            header_crayon = crayon"bold light_green",
            show_header = true,
        )
        return(pt)
    end

end
# --------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------
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
