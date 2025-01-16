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
- `group_type::Union{Symbol, Vector{Symbol}}`: grouping is done based on type in column or values (default)
   must be of the size of cols if it is a vector
- `reorder_cols::Bool=true`: sort by columns
- `out::Symbol=:stdout`: output is a nothing; other options are :string for string; :df for a dataframe

# Returns
- `PrettyTableInt`: the index where `val` is located in the `array`

# Throws
- `NotFoundError`: I guess we could throw an error if `val` isn't found.

# TO DO
allow user to specify order of columns (reorder = false flag)
"""
function tabulate(
    df::AbstractDataFrame, cols::Union{Symbol, Vector{Symbol}};
    group_type::Union{Symbol, Vector{Symbol}}=:value, 
    reorder_cols::Bool=true, 
    out::Symbol=:stdout)

    if typeof(cols) <: Symbol # check if it's an array or just a point
        N_COLS = 1
    else
        N_COLS = size(cols,1)
        # error("Only accepts one variable for now ...")
    end

    # Count the number of observations by `columns`: this is the main calculation
    group_type_error_msg = """
        \ngroup_type input must specify either ':value' or ':type' for columns; 
        options are :value, :type, or a vector combining the two;
        see help for more information
        """
    if group_type == :value
        df_out = combine(groupby(df, cols), nrow => :freq, proprow =>:pct)
        new_cols = cols
    elseif group_type == :type
        name_type_cols = Symbol.(cols, "_typeof")
        df_out = transform(df, cols .=> ByRow(typeof) .=> name_type_cols) |>
            (d -> combine(groupby(d, name_type_cols), nrow => :freq, proprow =>:pct))
        new_cols = name_type_cols
        # rename!(df_out, name_type_cols .=> cols)
    elseif typeof(group_type) <: Vector{Symbol}
        !all(s -> s in [:value, :type], group_type) && (@error group_type_error_msg)
        (size(group_type, 1) != size(cols, 1)) && 
            (@error "\ngroup_type and cols must be the same size; \nsee help for more information")
        type_cols = cols[group_type .== :type]
        name_type_cols = Symbol.(type_cols, "_typeof")
        group_cols = [cols[group_type .== :value]; name_type_cols]
        df_out = transform(df, type_cols .=> ByRow(typeof) .=> name_type_cols) |>
            (d -> combine(groupby(d, group_cols), nrow => :freq, proprow =>:pct))
        new_cols = group_cols
    else
        @error group_type_error_msg
    end


    if reorder_cols 
        cols_sortable = [ # check whether it makes sense to sort on the variables
            name
            for (name, col) in pairs(eachcol(select(df_out, new_cols)))
            if eltype(col) |> t -> hasmethod(isless, Tuple{t,t})
        ]
        if size(cols_sortable, 1)>0
            cols_sortable
            sort!(df_out, cols_sortable)  # order before we build cumulative
        end
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
