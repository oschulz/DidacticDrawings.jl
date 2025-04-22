# This file is a part of DidacticDrawings.jl, licensed under the MIT License (MIT).



struct LensedAsObj{LT,PT}
    _lens::LT
    _orig::PT
end

@inline _getlens(obj::LensedAsObj{propname}) = getfield(obj, :_lens)
@inline _getorig(obj::LensedAsObj{propname}) = getfield(obj, :_orig)

@inline Base.getindex(obj::LensedAsObj) = _getlens(obj)(_getorig(obj))
@inline Base.setindex(obj::LensedAsObj{PropertyLens{PN}}, x) where PN = _setproperty!(_getorig(obj), Val(PN), x)

@inline Base.propertynames(obj::LensedAsObj) = propertynames(obj[])
@inline Base.getproperty(obj::LensedAsObj, sym::Symbol) = getproperty(obj[], sym)
@inline Base.setproperty!(obj::LensedAsObj, sym::Symbol, x) = _setproperty_impl!(obj, Val(sym), x)



@inline function _setproperty_impl!(value::LensedAsObj, ::Val(sym), x) where sym
    value = value[]
    if ismutable(value)
        setproperty!(value, sym, x)
        value[] = value
    else
        new_value = Accessors.set(value, Accessors.PropertyLens{sym}(),  x)
        value[] = new_value
    end
    return x
end


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



@inline function _set!!(::value, lens, x)
    if ismutable(value) # Includes Observable
        ret = _set!(value, lens, x)
        return value, ret
    else
        new_value = set(value, lens,  x)
        return new_value, x
    end
end


@inline _set!(value, lens, x) where sym = _set_generic!(value, lens, x)
@inline _set_generic!(value, ::PropertyLens{sym}, x) where sym = setproperty!(value, sym, x)
@inline _set_generic!(value, lens::IndexLens, x) = setindex!(value, x, lens.indices...)

function _set!(value::Observable, lens, x)
    new_value, ret = set!!(value[], lens, x)
    value[] = new_value
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
