# This file is a part of DidacticDrawings.jl, licensed under the MIT License (MIT).

using DidacticDrawings
using Test


@testset "hello_world" begin
    @test DidacticDrawings.hello_world() == 42
end
