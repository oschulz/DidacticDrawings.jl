# This file is a part of DidacticDrawings.jl, licensed under the MIT License (MIT).

"""
    DidacticDrawings.AsMutable{propname}(parent)

A mutable view of the immutable field `propname` of the object `parent`.

The `parent` object must support `setproperty!(parent, propname, x)`.
"""
struct AsMutable{propname,PT}
    _parent::PT
end


@inline _parentobj(obj::AsMutable{propname}) = getfield(obj, :_parent)

@inline Base.getindex(obj::AsMutable{propname}) where propname = getproperty(_parentobj(obj), propname)
@inline Base.setindex(obj::AsMutable{propname}, x) where propname = setproperty!(_parentobj(obj), propname, x)

Base.show(io::IO, obj::AsMutable) = show(io, obj[])


@inline Base.propertynames(obj::AsMutable) = propertynames(obj[])
@inline Base.getproperty(obj::AsMutable, sym::Symbol) = getproperty(obj[], sym)
@inline Base.setproperty!(obj::AsMutable, sym::Symbol, x) = _setproperty_impl!(obj, Val(sym), x)

@inline function _setproperty_impl!(obj::AsMutable{FN}, ::Val(sym), x) where {FN,sym}
    lens = Accessors.PropertyLens{FN}()
    old_value = obj[]
    new_value = Accessors.set(old_value, lens,  x)
    setproperty!(_parentobj(obj), sym, new_value)
    return new_value
end



"""
    DidacticDrawings.getmutable(parent, ::Val{propname})
    DidacticDrawings.getmutable(parent, propname::Symbol)

Get a mutable view of the immutable field `propname` of the object `parent`.

The `parent` object must support `getproperty(parent, propname)` and
`setproperty!(parent, propname, obj)`.
"""
@inline function getmutable(obj::PT, ::Val{propname}) where {PT,propname}
    return AsMutable{propname, PT}(obj)
end

@inline getmutable(obj::PT, propname::Symbol) = getmutable(obj, Val(propname))
