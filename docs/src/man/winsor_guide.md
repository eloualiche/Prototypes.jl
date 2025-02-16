# Winsorizing

The function `winsorize` tries to emulate stata winsor function.

There is a [`winsor`](https://juliastats.org/StatsBase.jl/stable/robust/#StatsBase.winsor) function in StatsBase.jl but I think it's a little less full-featured.


```@setup hist
import Pkg; Pkg.add("Plots");
using Plots, Random
gr(); theme(:wong2); Plots.default(display_type=:inline, size=(2000,1200), thickness_scaling=1)
```


## Basic usage

Start with a simple distribution to visualize the effect of *winsorizing*
```@example hist
Random.seed!(3); x = randn(10_000)
histogram(x, bins=-4:0.1:4, color="blue", label="distribution")
```

Replace the outliers based on quantile
```@example hist; continued=true
x_win = winsorize(x, probs=(0.05, 0.95));
# histogram(x, bins=-4:0.1:4, color="blue", label="distribution"); 
# histogram!(x_win, bins=-4:0.1:4, color="red", opacity=0.5, label="winsorized")
histogram([x, x_win], bins=-4:0.1:4, 
          color=["blue" "red"], opacity=[1.0 0.5], 
          label=["distribution" "winsorized"])
```

It is possible to only trim one side
```@example hist; continued=true
x_win = winsorize(x, probs=(0, 0.8));
histogram(x, bins=-4:0.1:4, color="blue", label="distribution"); 
histogram!(x_win, bins=-4:0.1:4, color="red", opacity=0.5, label="winsorized")
```


Another type of winsorizing is to specify your own cutpoints (they do not have to be symmetric):
```@example hist; continued=true
x_win = winsorize(x, cutpoints=(-1.96, 2.575));
histogram(x, bins=-4:0.1:4, color="blue", label="distribution"); 
histogram!(x_win, bins=-4:0.1:4, color="red", opacity=0.5, label="winsorized")
```

If you do not specify either they will specified automatically
```@example hist; continued=true
x_win = winsorize(x; verbose=true);
histogram(x, bins=-4:0.1:4, color="blue", label="distribution"); 
histogram!(x_win, bins=-4:0.1:4, color="red", opacity=0.5, label="winsorized")
```

If you do not want to replace the value by the cutoffs, specify `replace_value=missing`:
```@example hist; continued=true
x_win = winsorize(x, cutpoints=(-2.575, 1.96), replace_value=missing);
histogram(x, bins=-4:0.1:4, color="blue", label="distribution"); 
histogram!(x_win, bins=-4:0.1:4, color="red", opacity=0.5, label="winsorized")
```

The `replace_value` command gives you some flexibility to do whatever you want in your outlier data transformation
```@example hist; continued=true
x_win = winsorize(x, cutpoints=(-2.575, 1.96), replace_value=(-1.96, 1.28));
histogram(x, bins=-4:0.1:4, color="blue", label="distribution"); 
histogram!(x_win, bins=-4:0.1:4, color="red", opacity=0.5, label="winsorized")
```




## Within a DataFrame

I try to mimick the `gtools winsor` [example](https://raw.githubusercontent.com/mcaceresb/stata-gtools/master/docs/examples/gstats_winsor.do)

```@setup dataframe
import Pkg; 
Pkg.add("DataFrames"); Pkg.add("Plots");
 Pkg.add("PalmerPenguins"); ENV["DATADEPS_ALWAYS_ACCEPT"] = true
```


```@example dataframe
using DataFrames, PalmerPenguins, Plots
gr(); theme(:wong2); Plots.default(display_type=:inline, size=(2000,1200), thickness_scaling=1)
df = DataFrame(PalmerPenguins.load())
```

Winsor one variable
```@example dataframe; continued=true
# gstats winsor wage
transform!(df, :body_mass_g => (x -> winsorize(x, probs=(0.1, 0.9)) ) => :body_mass_g_w)
histogram(df.body_mass_g, bins=2700:100:6300, color="blue", label="distribution"); 
histogram!(df.body_mass_g_w, bins=2700:100:6300, color="red", opacity=0.5, label="winsorized")
```

Winsor multiple variables
```@example dataframe; continued=true
# gstats winsor wage age hours, cuts(0.5 99.5) replace
var_to_winsorize = ["bill_length_mm", "bill_depth_mm", "flipper_length_mm"]
transform!(df, 
    var_to_winsorize .=> (x -> winsorize(x, probs=(0.1, 0.9)) ) .=> var_to_winsorize .* "_w")
```

Winsor on one side only
```@example dataframe; continued=true
# left-winsorizing only, at 1th percentile; 
# cap noi gstats winsor wage, cuts(1 100); gstats winsor wage, cuts(1 100) s(_w2)
transform!(df, :body_mass_g => (x -> winsorize(x, probs=(0.1, 1)) ) => :body_mass_g_w )
```

Winsor by groups
```@example dataframe; continued=true
transform!(
    groupby(df, :sex),
    :body_mass_g => (x -> winsorize(x, probs=(0.2, 0.8)) ) => :body_mass_g_w)
histogram(df[ isequal.(df.sex, "male"), :body_mass_g], bins=3000:100:6300, color="blue", label="distribution"); 
histogram!(df[ isequal.(df.sex, "male"), :body_mass_g_w], bins=3000:100:6300, color="red", opacity=0.5, label="winsorized")
```



