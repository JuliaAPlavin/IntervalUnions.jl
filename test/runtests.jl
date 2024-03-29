using TestItems
using TestItemRunner
@run_package_tests


@testitem "basic usage" begin
    using IntervalSets
    using IntervalUnions: intervals

    x = 1..2
    a = IntervalUnion(x)
    @test length(intervals(a)) == 1
    @test intervals(a)[1] === x

    x2 = 3..4
    b = IntervalUnion((x, x2))
    @test length(intervals(b)) == 2
    @test intervals(b) === (x, x2)

    x3 = 5..6
    b3 = b ∪ x3
    @test intervals(b3) === (x, x2, x3)

    @test intervals(setdiff(b3, x2)) === (x, x3)
    @test intervals(complement(x2)) === (Interval{:open, :open}(-Inf, 3), Interval{:open, :open}(4, Inf))
    @test intervals(setdiff(b3, 3.3..3.5)) === (1..2, Interval{:closed, :open}(3, 3.3), Interval{:open, :closed}(3.5, 4), 5..6)
    @test intervals(setdiff(b3, 4..10)) === (1..2, Interval{:closed, :open}(3., 4.))
    @test intervals(setdiff(b3, IntervalUnion((3.3..3.5, 5..10.)))) === (1..2, Interval{:closed, :open}(3, 3.3), Interval{:open, :closed}(3.5, 4))
    @test intervals(b3 ∩ IntervalUnion((3.3..3.5, 5..10.))) === (3.3..3.5, 5..6.)

    c = x ∪ (1..0)
    @test length(intervals(c)) == 1
    @test intervals(c)[1] == x

    @test IntervalUnion(1..2) == 1..2
    @test isempty(IntervalUnion(1..0))
    @test !isempty(IntervalUnion(1..2))

    @test 3.3 ∈ b
    @test 4.3 ∉ b
    @test extrema(b) == (1, 4)

    @test sprint(show, IntervalUnion(())) == "∅"
    @test sprint(show, b) == "1 .. 2 ∪ 3 .. 4"
end

@testitem "equality" begin
    using IntervalSets

    @test IntervalUnion(1..2) == 1..2
    @test IntervalUnion(1..2) == 1..2.0
    @test IntervalUnion(1..2) == IntervalUnion(1..2)
    @test IntervalUnion(1..2) != 1.1..2
    @test IntervalUnion(1..2) != IntervalUnion(1..3)
    @test IntervalUnion(1..2) != IntervalUnion((1..2, 3..4))
    @test IntervalUnion(1..2) != IntervalUnion(())

    @test_broken IntervalUnion((1..2, 3..4)) == IntervalUnion((3..4, 1..2))
    @test_broken IntervalUnion((1..2, 2..3)) == 1..3

    @test IntervalUnion(()) == IntervalUnion(())
    @test IntervalUnion(()) != 1..2
    @test (1..0) == (2..1)
    @test IntervalUnion(1..0) == 2..1
    @test IntervalUnion(()) == 2..1
end

@testitem "empty" begin
    using IntervalSets

    ∅ = IntervalUnion(())
    
    int = 1..3
    @test int ∩ ∅ == ∅
    @test int ∪ ∅ == int
    @test ∅ ∩ int == ∅
    @test ∅ ∪ int == int
    @test setdiff(int, ∅) == int
    @test setdiff(∅, int) == ∅
    
    @test IntervalUnion((int,)) ∩ ∅ == ∅
    @test IntervalUnion((int,)) ∪ ∅ == IntervalUnion((int,))
    @test ∅ ∩ IntervalUnion((int,)) == ∅
    @test ∅ ∪ IntervalUnion((int,)) == IntervalUnion((int,))
    @test setdiff(IntervalUnion((int,)), ∅) == IntervalUnion((int,))
    @test setdiff(∅, IntervalUnion((int,))) == ∅

    @test ∅ ∩ ∅ == ∅
    @test ∅ ∪ ∅ == ∅
    @test setdiff(∅, ∅) == ∅
    @test_throws Exception minimum(∅)
    @test_throws Exception supremum(∅)
end

@testitem "interval collection types" begin
    using IntervalSets
    using UnionCollections

    ia = 1..2
    ib = 3..4.
    iu_t = IntervalUnion((ia, ib))
    iu_v = IntervalUnion([ia, ib])
    iu_uv = IntervalUnion(unioncollection([ia, ib]))

    @testset for iu in (iu_t, iu_v, iu_uv)
        for b in (iu_t, iu_v, iu_uv)
            @test iu == b
        end

        @test !isempty(iu)
        @test 1.5 ∈ iu
        @test 2.5 ∉ iu
        
        @test setdiff(iu, 2.4..2.5) == iu
        @test setdiff(iu, 2..3) == IntervalUnion((Interval{:closed,:open}(1, 2), Interval{:open,:closed}(3, 4)))
        @test setdiff(iu, 1..3) == Interval{:open,:closed}(3, 4)
        @test setdiff(iu, 0..10) |> isempty
        @test setdiff(iu, iu) |> isempty

        @test iu ∩ (2.4..2.5) |> isempty
        @test iu ∩ (2..3) == IntervalUnion((2..2, 3..3))
        @test iu ∩ (1..4) == iu
        @test iu ∩ iu == iu
        @test iu ∪ (2.4..2.5) == IntervalUnion((1..2, 3..4, 2.4..2.5))
        @test_broken iu ∪ (2.4..2.5) == IntervalUnion((1..2, 2.4..2.5, 3..4))
        @test_broken iu ∪ (3..3.5) == iu
        @test_broken iu ∪ (1..4) == iu
        @test_broken iu ∪ iu == iu
    end
end


@testitem "_" begin
    import Aqua
    Aqua.test_all(IntervalUnions; ambiguities=false)
    Aqua.test_ambiguities(IntervalUnions)

    import CompatHelperLocal as CHL
    CHL.@check()
end
