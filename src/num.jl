# This file is a part of DidacticDrawings.jl, licensed under the MIT License (MIT).

"""
    num(x)

Get the numeric value of `x`.

`x` may be standard Julia numerical type, nested structure, of numerical
data, but may also be or contain values of type `Ref`,
`Observables.Observable`, or `Symbolics.Num`.
"""
function num end
export num
