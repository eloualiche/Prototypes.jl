module Prototypes

# ------------------------------------------------------------------------------------------
import ColorSchemes: get, colorschemes
import Crayons: @crayon_str
import DataFrames: AbstractDataFrame, DataFrame, groupby, combine, nrow, proprow, transform!
import Dates: format, now
import Logging: global_logger, Logging, Logging.Debug, Logging.Info, Logging.Warn
import LoggingExtras: ConsoleLogger, EarlyFilteredLogger, FileLogger, MinLevelLogger, TeeLogger, 
    TransformerLogger
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
