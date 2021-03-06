# UnitfulLsqFit

Least squares fitting for `Unitful` quantities.

```@example 1
using Unitful
using LsqFit, Latexify, Plots
using UnitfulLsqFit, UnitfulLatexify, UnitfulRecipes
default(;fontfamily="Computer Modern")

length = 1000
@. model(x, p) = p[1] + p[2]*exp(-((x-p[3])/p[4])^2) + p[5]*x
p0 = [
        2.0u"m/s", # y offset
        10.2u"m/s", # peak height
        -1.0u"s", # x offset
        0.6u"s", # peak width
        1.2u"m/s^2", # slope
     ]
t = range(-5, 5; length)u"s"
v = model(t, p0) + randn(length)*u"m/s" # noisy signal
fit = curve_fit(model, t, v, [0.0u"m/s", 1.0u"m/s", 0.0u"s", 1.0u"s", 1.0u"m/s^2"])
mdtable([p0 fit.param];head=latexraw.([:Truth, :Fit]))
```

```@example 1
plot(t, v; st=:scatter, label="Samples")
plot!(t,model(t, fit.param);
         linewidth=2, label="Fit",
         xguide="t", yguide="v", unitformat=(l,u)->"\$$l / $(latexraw(u))\$", legend=-45,
     )
savefig("1.svg") # hide
nothing # hide
```
![](1.svg)

## Warning concerning exponential fits

Consider the function ``y(x) = x^p``. If you know the dimension of ``y`` and
``x``, and neither of them is unitless, there is exactly one choice of ``p``
that allows this comparison -- and any adjacent ``p^*`` will not only make the
comparison inaccurate but impossible. Curve fitting in this case doesn't make
sense, and will most likely simply fail with `UnitfulLsqFit`. *The
dimensionality of the edxpression can not be determined by the values of the
fit parameters.*
