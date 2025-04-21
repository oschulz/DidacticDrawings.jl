# This file is a part of DidacticDrawings.jl, licensed under the MIT License (MIT).

import Test

Test.@testset "Package DidacticDrawings" begin
    include("test_aqua.jl")
    include("test_shapes.jl")
    include("test_docs.jl")
end # testset
