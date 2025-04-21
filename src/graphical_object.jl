# This file is a part of DidacticDrawings.jl, licensed under the MIT License (MIT).


"""
    abstract type GraphicalObject{N}

Abstract supertype for `N`-dimensional graphical objects.
"""
abstract type GraphicalObject{N} end
export GraphicalObject


"""
    getobs(obj::GraphicalObject)

Get the `Observables.Observable` object associated with `obj`.
"""
function getobs end
export getobs


"""
    getplot(obj::GraphicalObject)

Get the `MakieCore.AbstractPlot` object associated with `obj`.
"""
function getplot end
export getplot


"""
    getrotaxis(obj::GraphicalObject)

Get the default rotation axis for `obj`.
"""
function getrotaxis end
export getrotaxis


"""
    mathobj(obj::GraphicalObject)

Get the underlying mathematical object drawn as the graphical object `obj`.
"""
function mathobj end
export mathobj

struct DrawProperties
    translation::Vec{3,Float64}
    rotation::Quaternion{Float64}
    scale::Float64
    linecolor::RGBA{Float32}
    fillcolor::RGBA{Float32}
    strokewidth::Float64
    visible::Bool
end


"""
    DrawnSetOfPoints{N,T<:Number} <: GraphicalObject{N}

The graphical representation of a set of point embedded in ℝ^N with underlying
numerical type `T`.

Use `mathobj(obj)` to get the underlying mathematical `SetOfPoints`.
"""
mutable struct DrawnSetOfPoints{
    N,T<:Number,
    MathT <: SetOfPoints{N,T},
    RefT <: GraphicalObject{N}
} <: GraphicalObject{N}
    _ref::RefT
    _math::MathT
    _plt::AbstractPlot
    _rotaxis::Vec{3,T}
end

getrotaxis(::DrawnSetOfPoints{2,T}) where T = Vec3f(zero(T), zero(T), one(T))

(:corners, :translation, :rotation, :scale, :visible, :linecolor, :fillcolor)
