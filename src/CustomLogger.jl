# --------------------------------------------------------------------------------------------------

# CustomLogger.jl

# Function to create a custom logger 
# --------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------
# Exported function
# custom_logger
# --------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------
"""
    custom_logger(filename; kw...)
    
# Arguments
- `filename::AbstractString`: base name for the log files 
- `output_dir::AbstractString=./log/`: name of directory where log files are written
- `filtered_modules::Vector{Symbol}=nothing`: which modules do you want to filter out of logging (only for debug)
- `absolute_filtered_modules::Vector{Symbol}=nothing`: which modules do you want to filter out of logging (across for debug)
- `log_date_format::AbstractString="yyyy-mm-dd"`: time stamp format at beginning of each logged lines for dates
- `log_time_format::AbstractString="HH:MM:SS"`: time stamp format at beginning of each logged lines for times
- `displaysize::Tuple{Int,Int}=(50,100)`: how much to show on log (same for all logs for now!)
- `overwrite::Bool=false`: do we overwrite previously created log files

The custom_logger function creates four files in `output_dir` for four different levels of logging:
    from least to most verbose: `filename.info.log.jl`, `filename.warn.log.jl`, `filename.debug.log.jl`, `filename.full.log.jl`
The debug logging offers the option to filter messages from specific packages (some packages are particularly verbose) using the `filter` optional argument
The full logging gets all of the debug without any of the filters.
Info and warn log the standard info and warning level logging messages. 

Note that the default **overwrite** old log files. 

"""    
function custom_logger(filename::Union{AbstractString, Vector{AbstractString}}; 
    filtered_modules::Union{Nothing, Vector{Symbol}}=nothing, 
    absolute_filtered_modules::Union{Nothing, Vector{Symbol}}=nothing,
    log_date_format::AbstractString="yyyy-mm-dd",
    log_time_format::AbstractString="HH:MM:SS",
    displaysize::Tuple{Int,Int}=(50,100),
    overwrite=false)
    
    # name of the 4 different files ... if we only provide one
    l_logfiles = if typeof(filename) <: AbstractString
        filename .* [".warn.log", ".info.log", ".debug.log", ".full.log"]
    else
        (length(filename)<4) && (@warn "Please provide adequate number of logs (>=4) for sinks")
        filename[1:min(4, length(filename))]
    end

    overwrite && map(x->rm(x, force=true), l_logfiles) # clean up the files

    # warning if some non imported get filtered ... 
    imported_modules = filter((x) -> typeof(getfield(Main, x)) <: Module && x ≠ :Main, 
        names(Main,imported=true))
    all_filters = filter(x->!isnothing(x), unique([filtered_modules; absolute_filtered_modules]))
    catch_nonimported = map(x -> x ∈ imported_modules, all_filters)
    (!(reduce(&, catch_nonimported))) ? 
        (@warn "Some non (directly) imported modules are being filtered ... $(join(string.(all_filters[ .!catch_nonimported ]), ","))") : 
        nothing

    # custom filter: remove message that match some packages for example
    # imported_modules = filter((x) -> typeof(getfield(Main, x)) <: Module && x ≠ :Main, 
    #     names(Main,imported=true))
    # if !isnothing(filtered_modules)
    #     catch_nonimported = map(x -> x ∈ imported_modules, filtered_modules) 
    #     (!(reduce(&, catch_nonimported))) ? 
    #     (@warn "Trying to filter non imported modules ... $(join(string.(filtered_modules[ .!catch_nonimported ]), ",")) ... check your preamble") : 
    #     nothing
    #     specific_modules_tofilter = filtered_modules[ catch_nonimported ]
    # end

    function module_specific_message_filter(log)
        # return( isnothing(filtered_modules) ? true : !(Symbol(string(log._module)) ∈ specific_modules_tofilter) )
        return( isnothing(filtered_modules) ? true : !(Symbol(string(log._module)) ∈ unique([filtered_modules; absolute_filtered_modules]) ) )
    end

    # if !isnothing(absolute_filtered_modules)
    #     catch_nonimported = map(x -> x ∈ imported_modules, absolute_filtered_modules) 
    #     (!(reduce(&, catch_nonimported))) ? 
    #     (@warn "Trying to filter non imported modules ... $(join(string.(absolute_filtered_modules[ .!catch_nonimported ]), ",")) ... check your preamble") : 
    #     nothing
    #     absolute_modules_tofilter = absolute_filtered_modules[ catch_nonimported ]
    # end
    function module_absolute_message_filter(log)
        # return( isnothing(absolute_filtered_modules) ? true : !(Symbol(string(log._module)) ∈ absolute_modules_tofilter) )
        return( isnothing(absolute_filtered_modules) ? true : !(Symbol(string(log._module)) ∈ absolute_filtered_modules) )
    end

    format_log = (io,log_record)->custom_format(io, log_record; 
        displaysize=displaysize, log_date_format=log_date_format, log_time_format=log_time_format)

    demux_logger = TeeLogger(
        MinLevelLogger(
            EarlyFilteredLogger(module_absolute_message_filter, 
                FormatLogger(format_log, open(l_logfiles[1], "a"))
                ), 
            Logging.Warn),
        MinLevelLogger(
            EarlyFilteredLogger(module_absolute_message_filter, 
                FormatLogger(format_log, open(l_logfiles[2], "a"))
                ), 
            Logging.Info),
        MinLevelLogger(
            EarlyFilteredLogger(module_specific_message_filter, 
                FormatLogger(format_log, open(l_logfiles[3], "a"))
            ), 
            Logging.Debug),
        MinLevelLogger(
            EarlyFilteredLogger(module_absolute_message_filter, 
                FormatLogger(format_log, open(l_logfiles[4], "a"))
                ), 
            Logging.Debug),
        MinLevelLogger(
            EarlyFilteredLogger(module_absolute_message_filter, 
                FormatLogger(format_log, stdout),
            ),
            Logging.Info)
        ) |> global_logger;

    return(demux_logger)
end    



# version for starting julia in batch mode
function custom_logger(
    filtered_modules::Vector{Symbol}=nothing, 
    absolute_filtered_modules::Vector{Symbol}=nothing,
    output_dir::AbstractString="./log",
    overwrite=true)

    if abspath(PROGRAM_FILE) == @__FILE__  # true if not in REPL
        custom_logger(@__FILE__; 
            filtered_modules=filtered_modules, absolute_filtered_modules=absolute_filtered_modules,
            output_dir=output_dir, overwrite=overwrite)
    else
        @error "Could not get proper filename for logger ... filename = $(@__FILE__)"
    end
end
# --------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------
# Custom format function with box-drawing characters for wrap-around effect
function custom_format(io, log_record; 
    displaysize::Tuple{Int,Int}=(50,100), 
    log_date_format::AbstractString="yyyy-mm-dd", log_time_format::AbstractString="HH:MM:SS",
 )

    # colors
    BOLD = "\033[1m"
    EMPH = "\033[2m"
    RESET = "\033[0m"
    
    date = format(now(), log_date_format)    
    time = format(now(), log_time_format)

    timestamp = "$BOLD$time$RESET $EMPH$date$RESET"  # Apply bold only to the time

    level = log_record.level
    color = get_color(level)

    # Format source
    module_name = log_record._module
    file = log_record.file
    line = log_record.line
    source_info = " @ $module_name[$file:$line]"
    
    # Prepare the first part of the message prefix
    first_line = "┌ [$timestamp] $color$level\033[0m | $source_info"
    prefix_continuation_line = "│ "
    prefix_last_line = "└ "
    
    # we view strings as simple and everything else as complex
    if log_record.message isa AbstractString
        formatted_message = log_record.message
    else
        buf = IOBuffer()
        show(IOContext(buf, :limit=>true, :compact=>true, :color=>true, :displaysize=>displaysize), 
            "text/plain", log_record.message)
        formatted_message = String(take!(buf))
    end

    message_lines = split(formatted_message, "\n")
    num_lines = length(message_lines)
    # printing
    println(io, "$first_line")
    for (index, line) in enumerate(message_lines)
        if index < num_lines
            println(io, "$prefix_continuation_line$line")
        else  # Last line
            println(io, "$prefix_last_line$line")
        end
    end

end


function get_color(level)

    RESET = "\033[0m"
    BOLD = "\033[1m"
    LIGHT_BLUE = "\033[94m"
    RED = "\033[31m"
    GREEN = "\033[32m"
    YELLOW = "\033[33m"

    return level == Logging.Debug ? LIGHT_BLUE :  # Use light blue for Debug
           level == Logging.Info  ? GREEN :
           level == Logging.Warn  ? "$YELLOW$BOLD" :
           level == Logging.Error ? "$RED$BOLD" :
           RESET  # Default to no specific color
end
# --------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------
