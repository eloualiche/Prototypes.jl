module Prototypes

# ------------------------------------------------------------------------------------------
import ColorSchemes: get, colorschemes
import Crayons: @crayon_str
import DataFrames: AbstractDataFrame, DataFrame, groupby, combine, nrow, proprow, transform!
import Logging
import LoggingExtras
import PrettyTables: Crayon, ft_printf, get, Highlighter, hl_col, pretty_table
# ------------------------------------------------------------------------------------------


# ------------------------------------------------------------------------------------------
# Import functions
include("StataUtils.jl")
include("CustomLogger.jl")
# ------------------------------------------------------------------------------------------


# ------------------------------------------------------------------------------------------
# List of exported functions
export custom_logger
export tabulate 
# ------------------------------------------------------------------------------------------


end
