# This file is a part of DidacticDrawings.jl, licensed under the MIT License (MIT).

using Test
using DidacticDrawings
import Documenter

Documenter.DocMeta.setdocmeta!(
    DidacticDrawings,
    :DocTestSetup,
    :(using DidacticDrawings);
    recursive=true,
)
Documenter.doctest(DidacticDrawings)
