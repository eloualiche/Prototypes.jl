#!/usr/bin/env julia
push!(LOAD_PATH, "../src/")
using Prototypes


# -- 
using Documenter
using DocumenterVitepress

# -- 
makedocs(
    # format = Documenter.HTML(),
    format = MarkdownVitepress(
        repo = "https://github.com/eloualiche/Prototypes.jl",
    ),
    repo = Remotes.GitHub("eloualiche", "Prototypes.jl"),

    sitename = "Prototypes.jl",
    modules  = [Prototypes],
    authors = "Erik Loualiche",
    # remotes=Dict(
    #     "Prototypes" => 
    #         "https://github.com/eloualiche/Prototypes.jl"
    #     ), 
    pages=[
        "Home" => "index.md",
        "Manual" => [
            "man/logger_guide.md"
        ],
        "Demos" => [
            "demo/stata_utils.md",
        ],
        "Library" => [
            "lib/public.md",
            "lib/internals.md"
        ]
    ]
)


deploydocs(;
    repo = "github.com/eloualiche/Prototypes.jl",
    target = "build", # this is where Vitepress stores its output
    devbranch = "main",
    branch = "gh-pages",
    push_preview = true,
)


# deploydocs(;
#     repo = "github.com/eloualiche/Prototypes.jl",
#     devbranch = "build",
# )

# deploydocs(;
#     repo = "github.com/eloualiche/Prototypes.jl",
#     target = "build",
#     branch = "gh-pages",
# )

