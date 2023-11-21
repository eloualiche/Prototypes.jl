module Prototypes

# ------------------------------------------------------------------------------------------
import ColorSchemes: get, colorschemes
import Crayons: @crayon_str
import DataFrames: AbstractDataFrame, DataFrame, groupby, combine, nrow, proprow
import PrettyTables: Crayon, ft_printf, get, Highlighter, hl_col, pretty_table
# ------------------------------------------------------------------------------------------


# ------------------------------------------------------------------------------------------
# Import functions
include("StataUtils.jl")
# ------------------------------------------------------------------------------------------


# ------------------------------------------------------------------------------------------
# List of exported functions
export tabulate 

# ------------------------------------------------------------------------------------------


end
