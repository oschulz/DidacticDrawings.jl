# This file is a part of DidacticDrawings.jl, licensed under the MIT License (MIT).



struct LensedAsObj{LT,PT}
    _lens::LT
    _orig::PT
end


@inline Base.getindex(obj::LensedAsObj) = _get(obj, identity)
@inline Base.setindex!(obj::LensedAsObj, x) = _set!(obj, identity, x)

@inline Base.propertynames(obj::LensedAsObj) = _propnames(obj)
@inline Base.getproperty(obj::LensedAsObj, sym::Symbol) = _get(obj, PropertyLens{sym}())
@inline Base.setproperty!(obj::LensedAsObj, sym::Symbol, x) = set!(obj, PropertyLens{sym}(), x)

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

@inline Base.getindex(obj::LensedAsArray, idx) = _get(obj, IndexLens(idx,))
@inline Base.getindex(obj::LensedAsArray, idx...) = _get(obj, IndexLens(idxs))
@inline Base.setindex!(obj::LensedAsArray, x, idx) = _set!(obj, IndexLens(idx,), x)
@inline Base.setindex!(obj::LensedAsArray, x, idxs...) = _set!(obj, IndexLens(idxs), x)

@inline Base.size(obj::LensedAsArray) = size(_get(obj, identity))
@inline Base.length(obj::LensedAsArray) = length(_get(obj, identity))
@inline Base.IndexStyle(obj::LensedAsArray) = IndexStyle(_get(obj, identity))

function Base.show(io::IO, obj::LensedAsArray)
    print(io, "lensed: ")
    show(io, obj[])
end

function Base.show(io::IO, ::MIME"text/plain", obj::LensedAsArray)
    print(io, "lensed: ")
    show(io, mime, obj[])
end



const _Identity = typeof(identity)

@inline _getlens(obj::Union{LensedAsObj, LensedAsArray}) = getfield(obj, :_lens)
@inline _getorig(obj::Union{LensedAsObj, LensedAsArray}) = getfield(obj, :_orig)


_propnames(value) = propertynames(value)

_propnames(value::LensedAsObj) = _propnames(_get(value, identity))

_propnames(value::Observable) = _propnames(_get(value, identity))


@inline _get(value, ::_Identity) = value
@inline _get(value, lens) = lens(value)

_get(value::Union{LensedAsObj, LensedAsArray}, ::_Identity) = _get(_getorig(value), _getlens(value))
_get(value::Union{LensedAsObj, LensedAsArray}, lens) = _get(_get(value, identity), lens)

@inline _get(value::Observable, ::_Identity) = value[]
@inline _get(value::Observable, lens) = _get(_get(value, identity), lens)


@inline function _set!!(value, lens, x)
    if ismutable(value)
        ret = _set!(value, lens, x)
        return value, ret
    else
        new_value = set(value, lens,  x)
        return new_value, x
    end
end

@inline function _set!!(value::Union{LensedAsObj, LensedAsArray}, lens, x)
    ret = _set!(value, lens, x)
    return value, ret
end

@inline function _set!!(value::Observable, lens, x)
    ret = _set!(value, lens, x)
    return value, ret
end


# ToDo: Add generic set! with identity lens for mutable objects?
_set!(value::Union{LensedAsObj, LensedAsArray},  ::_Identity, x) = _set!(_getorig(value), _getlens(value), x)
_set!(value::Observable, ::_Identity, x) = value[] = x


@inline _set!(value, lens, x) = _set_generic!(value, lens, x)
@inline _set_generic!(value, ::PropertyLens{sym}, x) where sym = setproperty!(value, sym, x)
@inline _set_generic!(value, lens::IndexLens, x) = setindex!(value, x, lens.indices...)

function _set!(value::Union{LensedAsObj, LensedAsArray}, lens, x)
    new_value, ret = set!!(_get(value, identity), lens, x)
    set!(value, identity, new_value)
    return ret
end

function _set!(value::Observable, lens, x)
    new_value, ret = set!!(_get(value, identity), lens, x)
    set!(value, identity, new_value)
    return ret
end



@inline function _getlensed(lens, obj::PT) where PT
    VT = Core.Compiler.return_type(lens, Tuple{PT})
    return _getlensed_impl(lens, obj, VT)
end

_getlensed_impl(lens, obj, ::Type{<:Any}) = LensedAsObj(lens, obj)

_getlensed_impl(lens, obj, ::Type{<:AbstractArray{T,N}}) where {T,N} = LensedAsArray{T,N}(lens, obj)



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
