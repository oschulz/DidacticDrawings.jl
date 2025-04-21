# This file is a part of DidacticDrawings.jl, licensed under the MIT License (MIT).

import Test
import Aqua
import DidacticDrawings

Test.@testset "Package ambiguities" begin
    Test.@test isempty(Test.detect_ambiguities(DidacticDrawings))
end # testset

Test.@testset "Aqua tests" begin
    Aqua.test_all(
        DidacticDrawings,
        ambiguities = true
    )
end # testset
