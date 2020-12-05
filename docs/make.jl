using Documenter, RoadRunner

makedocs(
    modules = [RoadRunner],
    authors = "Jin Xu",
    repo="https://github.com/sunnyXu/RoadRunner.jl/blob/{commit}{path}#L{line}",
    sitename = "RoadRunner.jl",
    format=Documenter.HTML(;
    prettyurls=get(ENV, "CI", "false") == "true",
    canonical="https://sunnyXu.github.io/RoadRunner.jl",
    assets=String[],
    ),
    pages = [
        "Home" => "index.md",
    ],
    doctest = true
)


deploydocs(;
    deps = Deps.pip("mkdocs","python-markdown-math"),
    repo = "github.com/SunnyXu/RoadRunner.jl",
)
