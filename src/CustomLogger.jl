# --------------------------------------------------------------------------------------------------

# CustomLogger.jl

# Function to create a custom logger
# --------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------
# Exported function
# custom_logger
# --------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------
abstract type LogSink end

# Helper function to get filenames
function get_log_filenames(filename::AbstractString; create_files::Bool=false)
    if create_files
        files = ["$(filename)_error.log", "$(filename)_warn.log",
                 "$(filename)_info.log", "$(filename)_debug.log"]
    else
        files = repeat([filename], 4)
    end
    return files
end

function get_log_filenames(files::Vector{<:AbstractString})
    length(files) > 4  && (@warn "Please provide adequate number of logs (4 for sinks)")
    length(files) < 4  && throw(ArgumentError("Must provide at least 4 file paths"))
    return files[1:min(4, length(files))]
end

struct FileSink <: LogSink
    files::Vector{String}
    ios::Vector{IO}

    function FileSink(filename::AbstractString; create_files::Bool=false)
        files = get_log_filenames(filename; create_files=create_files)
        if create_files
            @info "Creating four different files for logging ... \n \u2B91\t$(join(files, "\n\t"))"
        else
           @info "Only one sink provided ... \n\tAll logs will be written without differentiation on $filename"
        end
        ios = [open(f, "a") for f in files]
        new(files, ios)
    end

    function FileSink(files::Vector{<:AbstractString})
        actual_files = get_log_filenames(files)
        ios = [open(f, "a") for f in actual_files]
        new(actual_files, ios)
    end
end

# Add finalizer to handle cleanup
function Base.close(sink::FileSink)
    foreach(close, sink.ios)
end
# --------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------
"""
    custom_logger(filename; kw...)

# Arguments
- `filename::AbstractString`: base name for the log files
- `output_dir::AbstractString=./log/`: name of directory where log files are written
- `filtered_modules_specific::Vector{Symbol}=nothing`: which modules do you want to filter out of logging (only for info and stdout)
  Some packages just write too much log ... filter them out but still be able to check them out in other logs
- `filtered_modules_all::Vector{Symbol}=nothing`: which modules do you want to filter out of logging (across all logs)
   Examples could be TranscodingStreams (noticed that it writes so much to logs that it sometimes slows down I/O)
- `log_date_format::AbstractString="yyyy-mm-dd"`: time stamp format at beginning of each logged lines for dates
- `log_time_format::AbstractString="HH:MM:SS"`: time stamp format at beginning of each logged lines for times
- `displaysize::Tuple{Int,Int}=(50,100)`: how much to show on log (same for all logs for now!)
- `log_format::Symbol=:log4j`: how to format the log files (stdout is always pretty); I have added an option for pretty (all or nothing for now)
- `overwrite::Bool=false`: do we overwrite previously created log files

The custom_logger function creates four files in `output_dir` for four different levels of logging:
    from least to most verbose: `filename.info.log.jl`, `filename.warn.log.jl`, `filename.debug.log.jl`, `filename.full.log.jl`
The debug logging offers the option to filter messages from specific packages (some packages are particularly verbose) using the `filter` optional argument
The full logging gets all of the debug without any of the filters.
Info and warn log the standard info and warning level logging messages.

Note that the default **overwrites** old log files (specify overwrite=false to avoid this).

"""
function custom_logger(
    sink::LogSink;
    filtered_modules_specific::Union{Nothing, Vector{Symbol}}=nothing,
    filtered_modules_all::Union{Nothing, Vector{Symbol}}=nothing,
    log_date_format::AbstractString="yyyy-mm-dd",
    log_time_format::AbstractString="HH:MM:SS",
    displaysize::Tuple{Int,Int}=(50,100),
    log_format::Symbol=:log4j, 
    shorten_path::Symbol=:no,
    verbose::Bool=false)

    # warning if some non imported get filtered ...
    imported_modules = filter((x) -> typeof(getfield(Main, x)) <: Module && x ≠ :Main,
        names(Main, imported=true))
    all_filters = filter(x->!isnothing(x), unique([filtered_modules_specific; filtered_modules_all]))
    catch_nonimported = map(x -> x ∈ imported_modules, all_filters)
    if !(reduce(&, catch_nonimported)) && verbose
        @warn "Some non (directly) imported modules are being filtered ... $(join(string.(all_filters[.!catch_nonimported]), ", "))"
    end

    # Filter functions
    function create_absolute_filter(modules)
        return function(log)
            if isnothing(modules)
                return true
            else
                module_name = string(log._module)
                # Check if the module name starts with any of the filtered module names
                # some modules did not get filtered because of submodules...
                # Note: we might catch too many modules here so keep it in mind if something does not show up in log
                for m in modules
                    if startswith(module_name, string(m))
                        return false  # Filter out if matches
                    end
                end
                return true  # Keep if no matches
            end
        end
    end
    module_absolute_message_filter = create_absolute_filter(filtered_modules_all)

    function create_specific_filter(modules)
        return function(log)
            if isnothing(modules)
                return true
            else
                module_name = string(log._module)
                # Check if the module name starts with any of the filtered module names
                # some modules did not get filtered because of submodules...
                # Note: we might catch too many modules here so keep it in mind if something does not show up in log
                for m in modules
                    if startswith(module_name, string(m))
                        return false  # Filter out if matches
                    end
                end
                return true  # Keep if no matches
            end
        end
    end
    module_specific_message_filter = create_absolute_filter(all_filters)


    format_log_pretty = (io,log_record)->custom_format(io, log_record;
        displaysize=displaysize,
        log_date_format=log_date_format,
        log_time_format=log_time_format,
        log_format=:pretty)

    format_log_file = (io,log_record)->custom_format(io, log_record;
        displaysize=displaysize,
        log_date_format=log_date_format,
        log_time_format=log_time_format,
        log_format=log_format,
        shorten_path=shorten_path)

    # Create demux_logger using sink's IO streams
    demux_logger = TeeLogger(
        MinLevelLogger(
            EarlyFilteredLogger(module_absolute_message_filter, # error
                FormatLogger(format_log_file, sink.ios[1])),
            Logging.Error),
        MinLevelLogger(
            EarlyFilteredLogger(module_absolute_message_filter, # warn
                FormatLogger(format_log_file, sink.ios[2])),
            Logging.Warn),
        MinLevelLogger(
            EarlyFilteredLogger(module_specific_message_filter, # info
                FormatLogger(format_log_file, sink.ios[3])),
            Logging.Info),
        MinLevelLogger(
            EarlyFilteredLogger(module_absolute_message_filter, # debug
                FormatLogger(format_log_file, sink.ios[4])),
            Logging.Debug),
        MinLevelLogger(
            EarlyFilteredLogger(module_specific_message_filter, # stdout
                FormatLogger(format_log_pretty, stdout)),
            Logging.Info)
    )

    global_logger(demux_logger)


    return demux_logger
end
# --------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------
# Convenience constructor that creates appropriate sink
function custom_logger(
    filename::Union{AbstractString, Vector{AbstractString}};
    create_log_files::Bool=false,
    overwrite::Bool=false,
    create_dir::Bool=false,
    kwargs...)

    files = get_log_filenames(filename; create_files=create_log_files)

    # create directory if needed and bool true
    # returns an error if directory does not exist and bool false
    log_dir = unique(dirname.(files))
    if create_dir && !isdir(log_dir)
        @warn "Creating directory for logs ... $(join(log_dir, ", "))"
        mkpath.(log_dir)
    elseif !isdir(log_dir)
        @error "Directory for logs does not exist ... $(join(log_dir, ", "))"
    end
    # Handle cleanup if needed
    overwrite && foreach(f -> rm(f, force=true), files)
    # Create sink
    sink = FileSink(filename; create_files=create_log_files)
    # Call main logger function
    custom_logger(sink; kwargs...)
end


# version for starting julia in batch mode
function custom_logger(;
    kwargs...)

    if abspath(PROGRAM_FILE) == @__FILE__  # true if not in REPL
        custom_logger(@__FILE__;
            kwargs...)
    else
        @error "Could not get proper filename for logger ... filename = $(@__FILE__)"
    end

end
# --------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------
# Custom format function with box-drawing characters for wrap-around effect
function custom_format(io, log_record;
    displaysize::Tuple{Int,Int}=(50,100),
    log_date_format::AbstractString="yyyy-mm-dd", 
    log_time_format::AbstractString="HH:MM:SS",
    log_format::Symbol=:pretty,  # available pretty or log4j
    shorten_path::Symbol=:no     # see function below tried to emulate p10k
 )

    # colors
    BOLD = "\033[1m"
    EMPH = "\033[2m"
    RESET = "\033[0m"

    # Get some information!!
    module_name = log_record._module
    line = log_record.line
    level = log_record.level
    log_level = rpad(uppercase(string(level)), 5)

    # separate what is log4j or pretty
    if log_format == :pretty
        date = format(now(), log_date_format)
        time = format(now(), log_time_format)
        timestamp = "$BOLD$time$RESET $EMPH$date$RESET"  # Apply bold only to the time
        color = get_color(level)
        file = log_record.file
        source_info = " @ $module_name[$file:$line]"
        # Prepare the first part of the message prefix
        first_line = "┌ [$timestamp] $color$log_level\033[0m | $source_info"
        prefix_continuation_line = "│ "
        prefix_last_line = "└ "
    elseif log_format == :log4j
        date = format(now(), "yyyy-mm-dd")
        time = format(now(), "HH:MM:SS")
        timestamp = "$date $time"
        file = shorten_path==:no ? log_record.file : shorten_path_str(log_record.file; strategy=shorten_path)
    end

    # -- format the message!!!
    # we view strings as simple and everything else as complex
    if log_record.message isa AbstractString
        formatted_message = log_record.message
    else
        buf = IOBuffer()
        if log_format == :pretty
            show(IOContext(buf, :limit=>true, :compact=>true, :color=>true, :displaysize=>displaysize),
                "text/plain", log_record.message)
        elseif log_format == :log4j
            show(IOContext(buf, :limit => true, :compact => true, :displaysize => (50, 100)),
                "text/plain", log_record.message)
        end
        formatted_message = String(take!(buf))
    end

    if log_format == :pretty 
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
    elseif log_format == :log4j
        # we put everything on one line for clear logging ... 
        log_entry = "$timestamp $log_level $module_name[$file:$line] - $(replace(formatted_message, "\n" => " | "))"
        # Print the log entry
        println(io, log_entry)
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
"""
    shorten_path_str(path::AbstractString; max_length::Int=40, strategy::Symbol=:truncate_middle)

Shorten a file path string to a specified maximum length using various strategies.

# Arguments
- `path::AbstractString`: The input path to be shortened
- `max_length::Int=40`: Maximum desired length of the output path
- `strategy::Symbol=:truncate_middle`: Strategy to use for shortening. Options:
  * `:no`: Return path unchanged
  * `:truncate_middle`: Truncate middle of path components while preserving start/end
  * `:truncate_to_last`: Keep only the last n components of the path
  * `:truncate_from_right`: Progressively remove characters from right side of components
  * `:truncate_to_unique`: Reduce components to unique prefixes

# Returns
- `String`: The shortened path

# Examples
```julia
# Using different strategies
julia> shorten_path_str("/very/long/path/to/file.txt", max_length=20)
"/very/…/path/to/file.txt"

julia> shorten_path_str("/usr/local/bin/program", strategy=:truncate_to_last, max_length=20)
"/bin/program"

julia> shorten_path_str("/home/user/documents/very_long_filename.txt", strategy=:truncate_middle)
"/home/user/doc…ents/very_…name.txt"
```
"""
function shorten_path_str(path::AbstractString; 
    max_length::Int=40, 
    strategy::Symbol=:truncate_middle
    )::AbstractString

    strategy == :no && return path

    # Return early if path is already short enough
    if length(path) ≤ max_length
        return path
    end

    # Split path into components
    parts = split(path, '/')
    is_absolute = startswith(path, '/')
    
    # Handle empty path or root directory
    if isempty(parts) || (length(parts) == 1 && isempty(parts[1]))
        return is_absolute ? "/" : ""
    end

    # Remove empty strings from split
    parts = filter(!isempty, parts)

    if strategy == :truncate_to_last
        # Keep only the last few components
        n = 2  # number of components to keep
        if length(parts) > n
            shortened = parts[end-n+1:end]
            result = join(shortened, "/")
            return is_absolute ? "/$result" : result
        end
    
    elseif strategy == :truncate_middle
        # For each component, truncate the middle if it's too long
        function shorten_component(comp::AbstractString; max_comp_len::Int=10)
            if length(comp) ≤ max_comp_len
                return comp
            end
            keep = max_comp_len ÷ 2 - 1
            return string(comp[1:keep], "…", comp[end-keep+1:end])
        end

        shortened = map(p -> shorten_component(p), parts)
        result = join(shortened, "/")
        if length(result) > max_length
            # If still too long, drop some middle directories
            middle_start = length(parts) ÷ 3
            middle_end = 2 * length(parts) ÷ 3
            shortened = [parts[1:middle_start]..., "…", parts[middle_end:end]...]
            result = join(shortened, "/")
        end
        return is_absolute ? "/$result" : result

    elseif strategy == :truncate_from_right
        # Start removing characters from right side of each component
        shortened = copy(parts)
        while join(shortened, "/") |> length > max_length && any(length.(shortened) .> 3)
            # Find longest component
            idx = argmax(length.(shortened))
            if length(shortened[idx]) > 3
                shortened[idx] = shortened[idx][1:end-1]
            end
        end
        result = join(shortened, "/")
        return is_absolute ? "/$result" : result

    elseif strategy == :truncate_to_unique
        # Simplified unique prefix strategy
        function unique_prefix(str::AbstractString, others::Vector{String}; min_len::Int=1)
            for len in min_len:length(str)
                prefix = str[1:len]
                if !any(s -> s != str && startswith(s, prefix), others)
                    return prefix
                end
            end
            return str
        end

        # Get unique prefixes for each component
        shortened = String[]
        for (i, part) in enumerate(parts)
            if i == 1 || i == length(parts)
                push!(shortened, part)
            else
                prefix = unique_prefix(part, String.(parts))
                push!(shortened, prefix)
            end
        end
        
        result = join(shortened, "/")
        return is_absolute ? "/$result" : result
    end

    # Default fallback: return truncated original path
    return string(path[1:max_length-3], "…")
end
# --------------------------------------------------------------------------------------------------




