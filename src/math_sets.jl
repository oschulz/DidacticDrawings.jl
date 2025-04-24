# This file is a part of DidacticDrawings.jl, licensed under the MIT License (MIT).


"""
    abstract type SetOfPoints{N,T<:Number} <: AbstractSet{Vec{N,T}}

Abstract supertype for sets of points embedded in ℝ^N with underlying
numerical type `T`.
"""
abstract type SetOfPoints{N,T<:Number} <: AbstractSet{Vec{N,T}} end
export SetOfPoints

getrotaxis(::SetOfPoints{2,T}) where T = Vec3f(zero(T), zero(T), one(T))
