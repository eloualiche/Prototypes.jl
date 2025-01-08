@testset "tabulate" begin

    df = dropmissing(DataFrame(PalmerPenguins.load()))
    cols = :island
    col_length = combine(groupby(df, cols), cols .=> length => :_N)
    sort!(col_length, cols)
    col_tab = tabulate(df, :island; out=:df);
    sort!(col_tab, cols)

    @test col_length._N == col_tab.freq

end

# using CSV
# using DataFrames
# custom_logger("file_to_log",                                  # where are the files generated
#     filtered_modules=[:StatsModels],     # filtering msg only for debug
#     absolute_filtered_modules=nothing,          # filtering msg for all
#     log_date_format="yyyy-mm-dd", log_time_format="HH:MM:SS", # date and time formatting
#     displaysize=(50,100),                                     # how much to show
#     overwrite=false                                           # overwrite old logs
#     )

# @info CSV.read("/Users/loulou/Dropbox/munis_home/data/willamette/StateData.csv.gz", DataFrame)
