# This file is a part of DidacticDrawings.jl, licensed under the MIT License (MIT).


"""
    Polygon{N,T<:Number} <: SetOfPoints{N,T}

A polygon (triangle, quadrilateral, etc.).

Constructors:

```julia
Polygon(points::Vector{Vec{N,T}})
```
"""
struct Polygon{
    N,T<:Number,VT<:AbstractVector{<:Point{N,<:T}}
} <: SetOfPoints{N,T}
    points::Vector{Vec{N,T}}
end
export Polygon
