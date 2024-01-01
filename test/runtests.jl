using TestItems
using TestItemRunner
@run_package_tests


@testitem "_" begin
    import Aqua
    Aqua.test_all(IntervalUnions; ambiguities=false)
    Aqua.test_ambiguities(IntervalUnions)

    import CompatHelperLocal as CHL
    CHL.@check()
end
