# This file is a part of DidacticDrawings.jl, licensed under the MIT License (MIT).

using Test
using DidacticDrawings

using Accessors: PropertyLens, IndexLens

@testset "getsetval" begin
    @testset "immutable struct" begin
        struct FooImmutable
            a::Int
            b::Int
        end

        obj = FooImmutable(4, 7)

        @test @inferred(getval(obj)) == FooImmutable(4, 7)
        @test @inferred(setval!!(identity, obj, FooImmutable(5, 8))) == FooImmutable(5, 8)

        @test @inferred(getval(PropertyLens{:b}(), obj)) == 7
        @test @inferred(setval!!(PropertyLens{:b}(), obj, 8)) == FooImmutable(4, 8)

        @test_throws ErrorException setval!(PropertyLens{:b}(), obj, 8)
    end


    @testset "mutable struct" begin
        mutable struct FooMutable
            a::Int
            b::Int
        end

        obj = FooMutable(4, 7)

        @test @inferred(getval(obj)) === obj
        # Not implemented yet:
        # @test @inferred(setval!!(identity, obj, FooImmutable(5, 8))) === obj

        @test @inferred(getval(PropertyLens{:b}(), obj)) == 7
        @test @inferred(setval!!(PropertyLens{:b}(), obj, 8)) === obj
        @test obj.a == 4 && obj.b == 8
        @test @inferred(setval!(PropertyLens{:b}(), obj, 6)) == 6
        @test obj.a == 4 && obj.b == 6
    end


    @testset "Ref" begin
        obj = Ref(9)
        @test @inferred(getval(obj)) == 9
        @test @inferred(getval(sqrt, obj)) == 3
        #setval!(obj, 10)      
    end
end
