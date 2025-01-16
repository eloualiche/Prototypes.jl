@testset "tabulate" begin

    # on existing dataset
    df = dropmissing(DataFrame(PalmerPenguins.load()))
    cols = :island
    col_length = combine(groupby(df, cols), cols .=> length => :_N)
    sort!(col_length, cols)
    col_tab = tabulate(df, :island; out=:df);
    sort!(col_tab, cols)

    @test col_length._N == col_tab.freq

    # on a specific dataset (see issue #1)
    df = DataFrame(x = [1, 2, 5, "NA", missing], y = ["a", "c", "b", "e", "d"])
    df_tab = tabulate(df, :x, reorder_cols=true, out=:df)
    @test isequal(df_tab.x, df.x)

    # test the group type options
    df = DataFrame(x = [1, 2, 2, "NA", missing], y = ["c", "c", "b", "z", "d"])
    @test isequal(
        tabulate(df, [:x, :y], out=:df).y, 
        sort(df.y))
    @test nrow(tabulate(df, [:x, :y], group_type = :value, out=:df)) == 5
    @test nrow(tabulate(df, [:x, :y], group_type = :type, out=:df)) == 3
    @test nrow(tabulate(df, [:x, :y], group_type = [:type, :value], out=:df)) == 4 
    @test nrow(tabulate(df, [:x, :y], group_type = [:value, :type], out=:df)) == 4

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
