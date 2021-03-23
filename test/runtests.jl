using UnitfulLsqFit
using Unitful
using LsqFit
using Test

L = 1000
@. model(x, p) = p[1] + p[2] * exp(-((x - p[3]) / p[4])^2) + p[5] * x
x = range(-5, 5; length=L)
p0 = [1.0, 10.8, -0.3, 1.2, 0.7]
y = model(x, p0) + randn(L)
@testset "UnitfulLsqFit.jl" begin
    r = curve_fit(
        model, x * u"m", y * u"s", [0.0u"s", 1.0u"s", 0.0u"m", 1.0u"m", 1.0u"s/m"]
    )
    for (a, b) in zip(p0, r.param)
        print(a, '\t', b, '\n')
    end
    @test r.converged
    @test unit.(r.param) == [u"s", u"s", u"m", u"m", u"s/m"]
    r = curve_fit(model, x * u"m", y, [0.0, 1.0, 0.0u"m", 1.0u"m", 1.0u"1/m"])
    @test r.converged
    r = curve_fit(model, x, y * u"s", [0.0u"s", 1.0u"s", 0.0, 1.0, 1.0u"s"])
    @test r.converged
    @test_throws Exception curve_fit(
        model, x * u"m", y * u"s", [0.0u"s", 1.0u"s", 0.0u"m", 1.0u"s"]
    )
    @test_throws Exception curve_fit(
        model, x * u"m", y * u"m", [0.0u"s", 1.0u"s", 0.0u"m", 1.0u"s/m"]
    )
end
