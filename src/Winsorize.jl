# ------------------------------------------------------------------------------------------
"""
    winsorize(
        x::AbstractVector; 
        probs::Union{Tuple{Real, Real}, Nothing} = nothing,
        cutpoints::Union{Tuple{Real, Real}, Nothing} = nothing,
        replace::Symbol = :missing
        verbose::Bool=false
    )

# Arguments
- `x::AbstractVector`: a vector of values

# Keywords
- `probs::Union{Tuple{Real, Real}, Nothing}`: A vector of probabilities that can be used instead of cutpoints
- `cutpoints::Union{Tuple{Real, Real}, Nothing}`: Cutpoints under and above which are defined outliers. Default is (median - five times interquartile range, median + five times interquartile range). Compared to bottom and top percentile, this takes into account the whole distribution of the vector
- `replace::Symbol`:  Values by which outliers are replaced. Default to cutpoints. A frequent alternative is NA.
- `verbose::Bool`: printing level

# Returns
- `AbstractVector`: A vector the size of x with substituted values 

# Examples
- See tests

This code is based on Matthieu Gomez winsorize function in the `statar` R package 
"""
function winsorize(x::AbstractVector{T}; 
    probs::Union{Tuple{Real, Real}, Nothing} = nothing,
    cutpoints::Union{Tuple{T, T}, Nothing} = nothing,
    replace_value::Union{Tuple{Union{T, Real}, Union{T, Real}}, Nothing, Missing} = nothing,
    verbose::Bool=false
    ) where T

    if !isnothing(probs)
        lower_percentile = minimum(probs)
        upper_percentile = maximum(probs)
        (lower_percentile<0 || upper_percentile>1) && @error "bad probability input"
        verbose && any(ismissing, x) && (@info "Some missing data skipped in winsorizing")
        verbose && !isnothing(cutpoints) && (@info "input cutpoints ignored ... using probabilities")
        cutpoints = quantile(skipmissing(x), [lower_percentile, upper_percentile])
    elseif isnothing(cutpoints)
        verbose && any(ismissing, x) && (@info "Some missing data skipped in winsorizing")
        l = quantile(skipmissing(x), [0.25, 0.50, 0.75])
        cutpoints = (l[2]-5*(l[3]-l[1]), l[2]+5*(l[3]-l[1]))
        verbose && @info "Inferred cutpoints are ... $cutpoints"
    end

    if isnothing(replace_value)
        replace_value = (minimum(cutpoints), maximum(cutpoints))
    elseif ismissing(replace_value)
        replace_value = (missing, missing)
    end

    if any(ismissing.(replace_value))
        y = Vector{Union{T, Missing}}(x)  # Make a copy of x that can also store missing values
    else
        y = copy(x)
    end
    
    y[findall(skipmissing(x .< cutpoints[1]))] .= replace_value[1];
    y[findall(skipmissing(x .> cutpoints[2]))] .= replace_value[2];

    return y
end
