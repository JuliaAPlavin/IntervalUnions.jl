using TestItems
using TestItemRunner
@run_package_tests


@testitem "basic usage" begin
    using IntervalSets
    using IntervalUnions: intervals

    x = 1..2.
    a = IntervalUnion(x)
    @test length(intervals(a)) == 1
    @test intervals(a)[1] === x

    x2 = 3..4.
    b = IntervalUnion([x, x2])
    @test length(intervals(b)) == 2
    @test intervals(b) == [x, x2]

    b = IntervalUnion((x, x2))
    @test length(intervals(b)) == 2
    @test intervals(b) === (x, x2)

    x3 = 5..6.
    b3 = b ∪ x3
    @test intervals(b3) === (x, x2, x3)

    @test intervals(setdiff(b3, x2)) === (x, x3)
    @test intervals(setdiff(b3, 3.3..3.5)) === (1..2., Interval{:closed, :open}(3, 3.3), Interval{:open, :closed}(3.5, 4), 5..6.)
    @test intervals(setdiff(b3, 3.3..10)) === (1..2., Interval{:closed, :open}(3, 3.3))
    @test intervals(setdiff(b3, IntervalUnion((3.3..3.5, 5..10.)))) === (1..2., Interval{:closed, :open}(3, 3.3), Interval{:open, :closed}(3.5, 4))
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

    @test sprint(show, b) == "1.0 .. 2.0 ∪ 3.0 .. 4.0"
end


@testitem "_" begin
    import Aqua
    Aqua.test_all(IntervalUnions; ambiguities=false)
    Aqua.test_ambiguities(IntervalUnions)

    import CompatHelperLocal as CHL
    CHL.@check()
end
