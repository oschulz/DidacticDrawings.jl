# This file is a part of DidacticDrawings.jl, licensed under the MIT License (MIT).

"""
    DidacticDrawings

Template for Julia packages.
"""
module DidacticDrawings

import StaticArrays
import Accessors
import Symbolics
import GeometryBasics
import Observables
import MakieCore
import Makie

using Observables: Observable
using GeometryBasics: Point, Point2f, Point3f, Vec, Vec2f, Vec3f

using ColorTypes: RGBA, RGB, HSV

using MakieCore: AbstractPlot

using Makie: Figure, Axis, LScene, Camera3D
using Makie: current_figure, current_axis
using Makie: Quaternion

using Accessors: PropertyLens, IndexLens

include("getsetval.jl")
include("changeable.jl")
include("math_sets.jl")
include("geometry_sets.jl")
include("init_display.jl")
include("graphical_object.jl")
include("reexports.jl")

end # module
