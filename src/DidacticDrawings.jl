# This file is a part of DidacticDrawings.jl, licensed under the MIT License (MIT).

"""
    DidacticDrawings

Template for Julia packages.
"""
module DidacticDrawings

import MakieCore
import Makie
import GeometryBasics

using Makie: Figure, Axis, LScene, Camera3D
using Makie: current_figure, current_axis

export current_figure
export current_axis

include("init.jl")
include("shapes.jl")

end # module
