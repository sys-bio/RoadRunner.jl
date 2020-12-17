# Julia Bindings for libRoadRunner

[![Build Status](https://travis-ci.com/SunnyXu/RoadRunner.jl.svg?branch=master)](https://travis-ci.com/SunnyXu/RoadRunner.jl)

[![Build Status](https://ci.appveyor.com/api/projects/status/github/SunnyXu/RoadRunner.jl?svg=true)](https://ci.appveyor.com/project/SunnyXu/RoadRunner-jl)

## Introduction
This project represents a set of Julia (https://julialang.org/) bindings to libRoadRunner (http://libroadrunner.org/). libRoadrunner is a SBML compliant high performance and simulation engine for systems and synthetic biology. This RoadRunner.jl package supports SBML and Antimony (http://antimony.sourceforge.net/) files as input. If you use any of the software, please cite the GitHub website (https://github.com/SunnyXu/RoadRunner.jl).

## Quick Start

    julia> import Pkg
    julia> Pkg.add("RoadRunner")
    julia> using RoadRunner

## Documentation

The documentation can be found at: https://SunnyXu.github.io/RoadRunner.jl/

The main code of this package is based on the existed software of libRoadRunner and libAntimony.

src/RoadRunner.jl and src/rrc_utilities_binding.jl refer to the documentation of libRoadRunner https://github.com/sys-bio/roadrunner.

src/antimony_binding.jl refers to the documentation of libAntimony C API-antimony_api.h (http://antimony.sourceforge.net/antimony__api_8h.html)

## Requirements

This current version of Julia package is suitable for Window 64, and it is compliant for Julia version 1.1-1.5.

## Examples

### An example illustrating how to load an SBML file.

    using RoadRunner
    sbmlFile = "\\path\\to\\file.xml"
    f = open(sbmlFile)
    sbmlStr = read(f,String)
    close(f)
    rr = RoadRunner.createRRInstance()
    RoadRunner.loadSBML(rr, sbmlStr)

### An example showing how to load a model in Antimony format.

    using RoadRunner
    ant_str = """    
        const Xo, X1
        Xo -> S1; k1*Xo - k2*S1
        S1 -> S2; k3*S2
        S2 -> X1; k4*S2

        Xo = 1;   X1 = 0
        S1 = 0;   S2 = 0
        k1 = 0.1; k2 = 0.56
        k3 = 1.2; k4 = 0.9
    """
    rr = RoadRunner.loada(ant_str)

We thank Luke Zhu (https://github.com/Lukez-pi/RoadRunner.jl) for his assisting and initiating this Julia package!
