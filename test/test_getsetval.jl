# This file is a part of DidacticDrawings.jl, licensed under the MIT License (MIT).

using Test
using DidacticDrawings

using Accessors: PropertyLens, IndexLens
using Observables: Observable

@testset "getsetval" begin
    function test_getval(lens, obj, ref_value)
        @test @inferred(getval(lens, obj)) == ref_value
    end

    function test_getval(obj, ref_value)
        @test @inferred(getval(obj)) == ref_value
    end

    function test_immutable_setval!!(lens, obj, x, ref_value)
        @test @inferred(setval!!(lens, obj, x)) isa typeof(obj)
        new_obj = setval!!(lens, obj, x)
        @test @inferred(getval(lens, new_obj)) == x
        @test @inferred(getval(new_obj)) == ref_value
    end

    function test_immutable_setval!!(obj, new_value)
        @test @inferred(setval!!(obj, new_value)) isa typeof(obj)
        new_obj = setval!!(obj, new_value)
        @test @inferred(getval(new_obj)) == new_value
    end

    function test_mutable_setval!!(lens, orig_obj, x, ref_value)
        obj = deepcopy(orig_obj)
        @test @inferred(setval!!(lens, obj, x)) === obj
        @test @inferred(getval(lens, obj)) == x
        @test @inferred(getval(obj)) == ref_value
    end

    function test_mutable_setval!!(orig_obj, new_value)
        obj = deepcopy(orig_obj)
        @test @inferred(setval!!(obj, new_value)) === obj
        @test @inferred(getval(obj)) == new_value
    end

    function test_setval!(lens, orig_obj, x, ref_value)
        obj = deepcopy(orig_obj)
        @test @inferred(setval!(lens, obj, x)) === x
        @test @inferred(getval(lens, obj)) == x
        @test @inferred(getval(obj)) == ref_value
    end

    function test_setval!(orig_obj, new_value)
        obj = deepcopy(orig_obj)
        @test @inferred(setval!(obj, new_value)) === new_value
        @test @inferred(getval(obj)) == new_value
    end


    struct FooImmutable
        a::Int
        b::Int
    end

    @testset "immutable struct" begin
        obj = FooImmutable(4, 7)

        @test @inferred(getval(obj)) == FooImmutable(4, 7)
        @test @inferred(setval!!(identity, obj, FooImmutable(5, 8))) == FooImmutable(5, 8)
        @test @inferred(setval!!(obj, FooImmutable(5, 8))) == FooImmutable(5, 8)

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


    function test_mutable_getsetval(label, obj)
        @testset "$label" begin
            inner = FooImmutable(4, 7)
            obj = Ref(inner)

            test_getval(obj, FooImmutable(4, 7))
            test_getval(identity, obj, FooImmutable(4, 7))
            test_getval(PropertyLens{:b}(), obj, 7)

            test_mutable_setval!!(obj, FooImmutable(5, 8))
            test_mutable_setval!!(identity, obj, FooImmutable(5, 8), FooImmutable(5, 8))
            test_mutable_setval!!(PropertyLens{:b}(), obj, 8, FooImmutable(4, 8))

            test_setval!(obj, FooImmutable(5, 8))
            test_setval!(identity, obj, FooImmutable(5, 8), FooImmutable(5, 8))
            test_setval!(PropertyLens{:b}(), obj, 8, FooImmutable(4, 8))
        end
    end

    test_mutable_getsetval("Ref", Ref(FooImmutable(4, 7)))
    test_mutable_getsetval("Observable", Observable(FooImmutable(4, 7)))
    test_mutable_getsetval("Ref_Observable", Ref(Observable(FooImmutable(4, 7))))
end
