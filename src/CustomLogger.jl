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
- `log_date_format::AbstractString="yyyy-mm-dd HH:MM:SS"`: time stamp format at beginning of each logged lines
- `overwrite::Bool=true`: do we overwrite previously created log files

The custom_logger function creates four files in `output_dir` for four different levels of logging:
    from least to most verbose: `filename.info.log.jl`, `filename.warn.log.jl`, `filename.debug.log.jl`, `filename.full.log.jl`
The debug logging offers the option to filter messages from specific packages (some packages are particularly verbose) using the `filter` optional argument
The full logging gets all of the debug without any of the filters.
Info and warn log the standard info and warning level logging messages. 

Note that the default **overwrite** old log files. 

"""    
function custom_logger(filename; 
    output_dir::AbstractString="./log",
    filtered_modules::Vector{Symbol}=nothing, 
    log_date_format::AbstractString="yyyy-mm-dd HH:MM:SS",
    overwrite=true)
    
    
    if overwrite # clean up the files
        map(x->rm(x, force=true), 
            ["$(output_dir)/$(filename).debug.log.jl", "$(output_dir)/$(filename).info.log.jl", 
             "$(output_dir)/$(filename).warn.log.jl", "$(output_dir)/$(filename).full.log.jl"]);
    end

    # custom timestamps
    timestamp_logger(logger) = TransformerLogger(logger) do log
        merge(log, (; message = "$(Dates.format(now(), log_date_format)) \n$(log.message)"))
    end

    # custom filter: remove message that match some packages for example
    if !isnothing(filtered_modules)
        imported_modules = filter((x) -> typeof(getfield(Main, x)) <: Module && x ≠ :Main, 
            names(Main,imported=true))
        # check if module is installed
        catch_nonimported = map(x -> x ∈ imported_modules, filtered_modules) 
        (!(reduce(&, catch_nonimported))) ? (@warn "Trying to filter non imported modules ... $(join(string.(filtered_modules[ .!catch_nonimported ]), ",")) ... check your preamble") : nothing
        modules_tofilter = filtered_modules[ catch_nonimported ]
        function module_specific_message_filter(log)
            return !(Symbol(string(log._module)) ∈ modules_tofilter)
        end
    end

    # create the debugger
    demux_logger = TeeLogger(
        MinLevelLogger(FileLogger("$(output_dir)/$(filename).info.log.jl"), Logging.Info),
        MinLevelLogger(FileLogger("$(output_dir)/$(filename).warn.log.jl"), Logging.Warn),
        MinLevelLogger(FileLogger("$(output_dir)/$(filename).full.log.jl"), Logging.Debug),
        MinLevelLogger(EarlyFilteredLogger(module_specific_message_filter, 
            FileLogger("$(output_dir)/$(filename).debug.log.jl")), 
            Logging.Debug),
        ConsoleLogger(stdout, Logging.Info),   # Common logger to be able to see info and warning in repl
    ) |> timestamp_logger |> global_logger;

    return(demux_logger)
end    

# version for starting julia in batch mode
function custom_logger(
    filtered_modules::Vector{Symbol}=nothing, 
    output_dir::AbstractString="./log",
    overwrite=true)

    if abspath(PROGRAM_FILE) == @__FILE__  # true if not in REPL
        custom_logger(@__FILE__; 
            filtered_modules=filtered_modules, output_dir=output_dir, overwrite=overwrite)
    else
        @error "Could not get proper filename for logger ... filename = $(@__FILE__)"
    end
end
# --------------------------------------------------------------------------------------------------
