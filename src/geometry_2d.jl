# This file is a part of DidacticDrawings.jl, licensed under the MIT License (MIT).

struct Polygon{N,T,VT<:AbstractVector{Vec{N,T}}} <: SetOfPoints{N,T}
    points::Vector{Vec{N,T}}
end


"""
    Polygon()

Create a polygon (triangle, quadrilateral, etc.) object.
"""
struct Polygon{OBS<:Observable, PLT<:AbstractPlot} <: SetOfPoints
    _obs::OBS
    _plt::PLT
end
export Polygon

getobs(obj::Polygon) = getfield(obj, :_obs)
getplot(obj::Polygon) = getfield(obj, :_plt)

Base.propertynames(::Polygon) = propertynames(getobs(obj)[])

# (:corners, :translation, :rotation, :scale, :visible, :linecolor, :fillcolor)
