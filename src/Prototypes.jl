module Prototypes


# --------------------------------------------------------------------------------------------------
import ColorSchemes: get, colorschemes
import Crayons: @crayon_str
import DataFrames: AbstractDataFrame, ByRow, DataFrame, groupby, combine, nrow,  Not,  nonunique, proprow, 
    rename, rename!, select, select!, transform, transform!, unstack
import Dates: format, now, DatePeriod, Dates, Dates.AbstractTime, ISODateTimeFormat
import Interpolations: Linear, Constant, Previous, Next, BSpline, interpolate
import Logging: global_logger, Logging, Logging.Debug, Logging.Info, Logging.Warn, AbstractLogger
import LoggingExtras: ConsoleLogger, EarlyFilteredLogger, FileLogger, FormatLogger, 
    MinLevelLogger, TeeLogger, TransformerLogger
import Missings: disallowmissing
import PrettyTables: Crayon, ft_printf, get, Highlighter, hl_col, pretty_table
import Random: seed!
import StatsBase: quantile, UnitWeights, Weights
# --------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------
# Import functions
include("CustomLogger.jl")
include("PanelData.jl")
include("StataUtils.jl")
include("Winsorize.jl")
# --------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------
# List of exported functions
export custom_logger
export panel_fill, panel_fill!
export tabulate 
export xtile
export winsorize
# --------------------------------------------------------------------------------------------------


end
