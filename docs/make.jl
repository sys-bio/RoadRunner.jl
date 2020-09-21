using Documenter, RoadRunner

isCI = get(ENV, "CI", nothing) == "true"

makedocs(
    modules = [RoadRunner],
    pages = [
        "Home" => "index.md"
    ],
    sitename = "RoadRunner.jl",
    doctest = true
)


deploydocs(
    repo = "github.com/Lukez-pi/RoadRunner.jl.git",
)
