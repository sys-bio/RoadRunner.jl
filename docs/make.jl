using Documenter, RoadRunnerJulia, DocumenterLaTeX

isCI = get(ENV, "CI", nothing) == "true"

makedocs(
    modules = [RoadRunnerJulia],
    pages = [
        "Home" => "index.md"
    ],
    sitename = "RoadRunnerJulia",
    doctest = true
)


deploydocs(
    repo = "github.com/Lukez-pi/RoadRunnerJulia.git",
)
