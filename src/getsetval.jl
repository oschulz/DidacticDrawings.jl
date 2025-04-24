# This file is a part of DidacticDrawings.jl, licensed under the MIT License (MIT).


"""
    getval(lens, obj)
    getval(obj) == getval(identity, obj)

Get the value of `obj` under the given `lens` function (n the sense
of Accessors.jl lenses).

Returns `lens(obj)` for "direct" objects. For "refenrence-like" objects of
types like  `Ref`, `Observables.Observable` or `Symbolics.Num`, applies `lens`
to the value they contain (the default value for `Symbolics.Num`).

Do not specialize `getval(obj::SomeType)`, specialize
`getval(::typeof(identity), obj::SomeType)` instead.
"""
function getval end
export getval

@inline getval(value) = getval(identity, value)
@inline getval(::typeof(identity), value) = value
@inline getval(lens, value) = lens(getval(value))



"""
    setval!!(lens, obj, x)
    setval!!(obj, x) == setval!!(identity, obj, x)

Modifies `obj` under the function `lens`, similar to `Accessors.set`, but
under the semantics of [`getval`](@ref) and may mutate `obj` in-place or not.

`changed_obj = setval!!(lens, obj, x)` ensures that
`getval(lens, changed_obj)` is equivalent to x (though not necessarily exactly
equal).

Do not specialize `setval!!(obj::SomeType, x)`, specialize
`setval!!(::typeof(identity), obj::SomeType, x)` instead.
"""
function setval!! end
export setval!!

@inline function setval!!(lens, value, x)
    if ismutable(value)
        setval!(lens, value, x)
        return value
    else
        new_value = Acessors.set(lens, value, x)
        return new_value
    end
end


"""
    setval!(lens, obj, x)
    setval!(obj, x) == setval!(identity, obj, x)

Mutates `obj` under the function `lens`, similar to `Accessors.set`, but
under the semantics of [`getval`](@ref) and mutates `obj` in-place.

Returns an equivalent of of `x`, *not* `obj` itself (similar to the behavior
of `setproperty!` and `setindex!`).

`setval!(lens, obj, x)` ensures that
`getval(lens, obj)` is equivalent to x (though not necessarily exactly
equal).

Do not specialize `setval!(obj::SomeType, x)`, specialize
`setval!(::typeof(identity), obj::SomeType, x)` instead.
"""
function setval! end
export setval!



@inline setval!(lens, value, x) = _set_generic!(lens, value, x)
# ToDo: Add _set_generic! with identity lens for mutable objects in general?
#@inline _set_generic!(::typeof(identity), value, x) = ...
@inline _set_generic!(::PropertyLens{sym}, value, x) where sym = setproperty!(value, sym, x)
@inline _set_generic!(lens::IndexLens, value, x) = setindex!(value, x, lens.indices...)


@inline _reflike_getval(lens, obj) = getval(lens, obj[])

@inline function _reflike_setval!!(lens, obj, x)
    setval!(lens, obj, x)
    return obj
end

function _reflike_setval!(lens, obj, x)
    new_value = setval!!(lens, getval(obj), x)
    obj[] = new_value
    return x
end


@inline getval(lens, obj::Ref) = _reflike_getval(lens, obj)
@inline setval!!(lens, obj::Ref, x) = _reflike_setval!!(lens, obj, x)
@inline setval!(lens, obj::Ref, x) = _reflike_setval!(lens, obj, x)


# = Observables ==============================================================

@inline getval(lens, obj::Observable) = _reflike_getval(lens, obj)
@inline setval!!(lens, obj::Observable, x) = _reflike_setval!!(lens, obj, x)
@inline setval!(lens, obj::Observable, x) = _reflike_setval!(lens, obj, x)


# = Symbolics ===============================================================

const _SymObject = Union{Symbolics.Num, Symbolics.Arr}

#!!!!!!!!
function getval(lens, obj::_SymObject)
    vars = Symbolics.get_variables(obj)
    #substitute(h, Dict(v => Symbolics.getdefaultval(v) for v in  Symbolics.get_variables(h)))
    # collect
end
