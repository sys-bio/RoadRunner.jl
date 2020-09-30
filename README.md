# RoadRunner

[![Build Status](https://ci.appveyor.com/api/projects/status/github/SunnyXu/RoadRunner.jl?svg=true)](https://ci.appveyor.com/project/SunnyXu/RoadRunner-jl)

Julia binding for libRoadRunner is a package written in the language of Julia (https://julialang.org/) to make use of libRoadRunner (http://libroadrunner.org/). This package is connecting libRoadRunner by dynamic link library (dll) on the platform of Windows 64 for the language of Julia. If you use any of the codes, please cite the GitHub website (https://github.com/SunnyXu/RoadRunner.jl).

===

Quickstart:

import Pkg

Pkg.add("RoadRunner")

using RoadRunner

rr = RoadRunner.createRRInstance()

(Roadrunner.FUNCTION_NAME)

You can refer to the test cases under /test for more examples.

===

The main code of this package is based on the existed software of libRoadRunner and libAntimony (http://antimony.sourceforge.net/).

src/RoadRunner.jl refers to the documentation of libRoadRunner C API-rrc_api.h (http://sys-bio.github.io/roadrunner/c_api_docs/html/rrc__api_8h.html).

src/rrc_utilities_binding.jl refers to the documentation of libRoadRunner C API-rrc_utilities.h (http://sys-bio.github.io/roadrunner/c_api_docs/html/rrc__utilities_8h.html)

src/antimony_binding.jl refers to the documentation of libAntimony C API-antimony_api.h (http://antimony.sourceforge.net/antimony__api_8h.html)

