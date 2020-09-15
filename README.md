# RoadRunner

[![Build Status](https://travis-ci.com/Lukez-pi/RoadRunner.jl.svg?branch=master)](https://travis-ci.com/Lukez-pi/RoadRunner.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/Lukez-pi/RoadRunner.jl?svg=true)](https://ci.appveyor.com/project/Lukez-pi/roadrunner-jl)
[![Codecov](https://codecov.io/gh/Lukez-pi/RoadRunner.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/Lukez-pi/RoadRunner.jl)
[![Coverage Status](https://coveralls.io/repos/github/Lukez-pi/RoadRunner.jl/badge.svg?branch=master)](https://coveralls.io/github/Lukez-pi/RoadRunner.jl?branch=master)


Julia binding for libRoadRunner is a package written in the language of Julia (https://julialang.org/) to make use of libRoadRunner (http://libroadrunner.org/). This package is connecting libRoadRunner by dynamic link library (dll) on the platform of Windows.

The main code of this package is based on the existed software of libRoadRunner and libAntimony (http://antimony.sourceforge.net/).

src/RoadRunner.jl refers to the documentation of libRoadRunner C API-rrc_api.h (http://sys-bio.github.io/roadrunner/c_api_docs/html/rrc__api_8h.html).

src/rrc_utilities_binding.jl refers to the documentation of libRoadRunner C API-rrc_utilities.h (http://sys-bio.github.io/roadrunner/c_api_docs/html/rrc__utilities_8h.html)

src/antimony_binding.jl refers to the documentation of libAntimony C API-antimony_api.h (http://antimony.sourceforge.net/antimony__api_8h.html)
