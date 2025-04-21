# This file is a part of DidacticDrawings.jl, licensed under the MIT License (MIT).

"""
    DidacticDrawings

Template for Julia packages.
"""
module DidacticDrawings

import StaticArrays
import GeometryBasics
import Observables
import MakieCore
import Makie

using GeometryBasics: Point, Point2f, Point3f, Vec, Vec2f, Vec3f

using ColorTypes: RGBA, RGB, HSV

using MakieCore: AbstractPlot

using Makie: Figure, Axis, LScene, Camera3D
using Makie: current_figure, current_axis
using Makie: Quaternion

using Accessors: @set

include("init.jl")
include("graphical_object.jl")
include("geometry_2d.jl")

end # module
