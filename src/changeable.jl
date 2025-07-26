# This file is a part of DidacticDrawings.jl, licensed under the MIT License (MIT).

struct LensedAsObj{LT,PT}
    _lens::LT
    _orig::PT
end


@inline Base.getindex(obj::LensedAsObj) = getval(identity, obj)
@inline Base.setindex!(obj::LensedAsObj, x) = setval!(identity, obj, x)

@inline Base.propertynames(obj::LensedAsObj) = propertynames(getval(obj))
@inline Base.getproperty(obj::LensedAsObj, sym::Symbol) = getval(PropertyLens{sym}(), obj)
@inline Base.setproperty!(obj::LensedAsObj, sym::Symbol, x) = setval!(PropertyLens{sym}(), obj, x)

function Base.show(io::IO, obj::LensedAsObj)
    print(io, "lensed: ")
    show(io, obj[])
end

function Base.show(io::IO, mime::MIME"text/plain", obj::LensedAsObj)
    print(io, "lensed: ")
    show(io, mime, obj[])
end



struct LensedAsArray{T,N,LT,PT} <: AbstractArray{T,N}
    _lens::LT
    _orig::PT
end

LensedAsArray{T,N}(lens::LT, orig::PT) where {T,N,LT,PT} = LensedAsArray{T,N,LT,PT}(lens, orig)

@inline Base.getindex(obj::LensedAsArray, idx::Integer) = getval(IndexLens((idx,)), obj)
@inline Base.getindex(obj::LensedAsArray, idx::AbstractArray{<:Integer}) = getval(IndexLens((idx,)), obj)
@inline Base.getindex(obj::LensedAsArray, idxs::Tuple{Vararg{Any,N}}) where N = getval(IndexLens(idxs), obj)

@inline Base.setindex!(obj::LensedAsArray, x, idx::Integer) = setval!(IndexLens((idx,)), obj, x)
@inline Base.setindex!(obj::LensedAsArray, x, idx::AbstractArray{<:Integer}) = setval!(IndexLens((idx,)), obj, x)
@inline Base.setindex!(obj::LensedAsArray, x, idxs::Tuple{Vararg{Any,N}}) where N = setval!(IndexLens(idxs), obj, x)

@inline Base.size(obj::LensedAsArray) = size(getval(identity, obj))
@inline Base.length(obj::LensedAsArray) = length(getval(identity, obj))
@inline Base.IndexStyle(obj::LensedAsArray) = IndexStyle(getval(identity, obj))

function Base.show(io::IO, obj::LensedAsArray)
    print(io, "lensed: ")
    show(io, obj[])
end

function Base.show(io::IO, mime::MIME"text/plain", obj::LensedAsArray)
    print(io, "lensed: ")
    show(io, mime, obj[])
end


const _LensedLike = Union{LensedAsObj, LensedAsArray}

_similar_lensed(@nospecialize(obj::LensedAsObj), new_lens, new_orig) = LensedAsObj(new_lens, new_orig)
_similar_lensed(@nospecialize(obj::LensedAsArray), new_lens, new_orig) = LensedAsObj(new_lens, new_orig)

@inline _getlens(obj::_LensedLike) = getfield(obj, :_lens)
@inline _getorig(obj::_LensedLike) = getfield(obj, :_orig)

getval(::typeof(identity), obj::_LensedLike) = getval(_getlens(obj), _getorig(obj))
getval(lens, obj::_LensedLike) = getval(lens, getval(obj))


@inline function setval!!(::typeof(identity), obj::_LensedLike, x)
    orig_lens = _getlens(obj)
    old_orig = _getorig(obj)
    new_orig = setval!!(_getlens(obj), _getorig(obj), x)
    if old_orig === new_orig
        return obj
    else
        return _similar_lensed(obj, orig_lens, new_orig)
    end
end

@inline function setval!!(lens, obj::_LensedLike, x)
    old_value = getval(lens, obj)
    new_value = setval!!(lens, old_value, x)
    return setval!!(identity, obj, new_value)
end


setval!(::typeof(identity), obj::_LensedLike, x) = setval!(_getlens(obj), _getorig(obj), x)

function setval!(lens, obj::_LensedLike, x)
    old_value = getval(obj)
    new_value = setval!!(lens, old_value, x)
    setval!(obj, new_value)
    return x
end



"""
    DidacticDrawings.changeable(obj)

Get a changeable view of `obj`.

If obj is a struct, then

```
cobj = changeable(obj)
```

allows for `getproperty(cobj, propname)`, `setproperty!(cobj, propname)`
and `cobj[] === obj[]`. `getproperty` will return wrapped properties that
allow for modification even if the original property is immutable.

If `obj` is an array, then `cobj` will be a wrapper array that allows for
`getindex` and `setindex!`. `getindex` will return wrapped elements that
allow for modification even if the original element immutable.

The wrapper scheme operates recursively, any changes to content in some
nesting layer under `cobj` will result to calls to `setproperty!` resp.
`setindex!` in the parent layers, all the way up to the original `obj`

This allows for change notification to nested structures of structs,
arrays and `Observable` objects.
"""
@inline changeable(obj) = _getlensed(identity, obj)

@inline function _getlensed(lens, obj::PT) where PT
    VT = Core.Compiler.return_type(lens, Tuple{PT})
    return _getlensed_impl(lens, obj, VT)
end

_getlensed_impl(lens, obj, ::Type{<:Any}) = LensedAsObj(lens, obj)

_getlensed_impl(lens, obj, ::Type{<:AbstractArray{T,N}}) where {T,N} = LensedAsArray{T,N}(lens, obj)
