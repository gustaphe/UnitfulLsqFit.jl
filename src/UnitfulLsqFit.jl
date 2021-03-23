module UnitfulLsqFit

using Unitful:
    AbstractQuantity, Unit, Units, NoDims, dimension, unit, ustrip, @u_str, @unit, register
import LsqFit: curve_fit, LsqFitResult
import Base: *

function __init__()
    return register(UnitfulLsqFit)
end

# One {{{
@unit one "" One 1 false
register(UnitfulLsqFit)
*(q::AbstractQuantity, ::Units{(Unit{:One,NoDims}(0, 1),),NoDims,nothing}) = q
function *(
    a::AbstractQuantity, b::T
) where {
    T<:AbstractQuantity{<:Number,NoDims,<:Units{(Unit{:One,NoDims}(0, 1),),NoDims,nothing}},
}
    return a * b.val
end
function *(
    b::T, a::AbstractQuantity
) where {
    T<:AbstractQuantity{<:Number,NoDims,<:Units{(Unit{:One,NoDims}(0, 1),),NoDims,nothing}},
}
    return b.val * a
end
# One }}}

function curve_fit(
    model,
    xdata::AbstractArray{<:AbstractQuantity},
    ydata::AbstractArray{<:AbstractQuantity},
    p0::AbstractArray{<:AbstractQuantity};
    normalize=false,
    kwargs...,
)
    # unit check
    dimension(model(first(xdata), p0)...) === dimension(first(ydata)) ||
        error("Model and ydata dimensions incompatible")
    xunit = unit(first(xdata))
    yunit = unit(first(ydata))
    punits = unit.(p0)

    X = ustrip.(xunit, xdata)
    Y = ustrip.(yunit, ydata)
    P = ustrip.(punits, p0)

    auxfit = curve_fit(model, X, Y, P; kwargs...)

    return LsqFitResult(
        auxfit.param .* punits,
        auxfit.resid * yunit,
        auxfit.jacobian * yunit ./ reshape(punits, 1, :),
        auxfit.converged,
        auxfit.wt,
    )
end

function curve_fit(
    model,
    xdata::AbstractArray{<:AbstractQuantity},
    ydata::AbstractArray,
    p0::AbstractArray;
    kwargs...,
)
    return curve_fit(model, xdata, ydata * u"one", p0 * u"one"; kwargs...)
end
function curve_fit(
    model,
    xdata::AbstractArray,
    ydata::AbstractArray{<:AbstractQuantity},
    p0::AbstractArray;
    kwargs...,
)
    return curve_fit(model, xdata * u"one", ydata, p0 * u"one"; kwargs...)
end

end
