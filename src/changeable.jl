# This file is a part of DidacticDrawings.jl, licensed under the MIT License (MIT).



struct LensedAsObj{LT,PT}
    _lens::LT
    _orig::PT
end


@inline Base.getindex(obj::LensedAsObj) = getval(obj, identity)
@inline Base.setindex!(obj::LensedAsObj, x) = setval!(obj, identity, x)

@inline Base.propertynames(obj::LensedAsObj) = propertynames(getval(obj))
@inline Base.getproperty(obj::LensedAsObj, sym::Symbol) = getval(obj, PropertyLens{sym}())
@inline Base.setproperty!(obj::LensedAsObj, sym::Symbol, x) = setval!(obj, PropertyLens{sym}(), x)

function Base.show(io::IO, obj::LensedAsObj)
    print(io, "lensed: ")
    show(io, obj[])
end

function Base.show(io::IO, ::MIME"text/plain", obj::LensedAsObj)
    print(io, "lensed: ")
    show(io, mime, obj[])
end



struct LensedAsArray{T,N,LT,PT} <: AbstractArray{T,N}
    _lens::LT
    _orig::PT
end

LensedAsArray{T,N}(lens::LT, orig::PT) where {T,N,LT,PT} = LensedAsArray{T,N,LT,PT}(lens, orig)

@inline Base.getindex(obj::LensedAsArray, idx) = getval(obj, IndexLens(idx,))
@inline Base.getindex(obj::LensedAsArray, idx...) = getval(obj, IndexLens(idxs))
@inline Base.setindex!(obj::LensedAsArray, x, idx) = setval!(obj, IndexLens(idx,), x)
@inline Base.setindex!(obj::LensedAsArray, x, idxs...) = setval!(obj, IndexLens(idxs), x)

@inline Base.size(obj::LensedAsArray) = size(getval(obj, identity))
@inline Base.length(obj::LensedAsArray) = length(getval(obj, identity))
@inline Base.IndexStyle(obj::LensedAsArray) = IndexStyle(getval(obj, identity))

function Base.show(io::IO, obj::LensedAsArray)
    print(io, "lensed: ")
    show(io, obj[])
end

function Base.show(io::IO, ::MIME"text/plain", obj::LensedAsArray)
    print(io, "lensed: ")
    show(io, mime, obj[])
end



@inline _getlens(obj::Union{LensedAsObj, LensedAsArray}) = getfield(obj, :_lens)
@inline _getorig(obj::Union{LensedAsObj, LensedAsArray}) = getfield(obj, :_orig)

getval(::typeof(identity), obj::Union{LensedAsObj, LensedAsArray}) = getval(_getlens(obj), _getorig(obj))
getval(lens, obj::Union{LensedAsObj, LensedAsArray}) = getval(lens, getval(obj))

@inline function setval!!(lens, obj::Union{LensedAsObj, LensedAsArray}, x)
    setval!(obj, lens, x)
    return obj
end

setval!(::typof(identity), obj::Union{LensedAsObj, LensedAsArray}, x) = setval!(_getlens(obj), _getorig(obj), x)

function setval!(lens, obj::Union{LensedAsObj, LensedAsArray}, x)
    new_value = setval!!(lens, getval(obj), x)
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
