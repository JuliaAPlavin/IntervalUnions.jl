module IntervalUnions

using IntervalSets
using Accessors
using DataPipes

export IntervalUnion

struct IntervalUnion{T} <: IntervalSets.Domain{T}
    ints::T
end

intervals(x::Interval) = (x,)
@accessor intervals(x::IntervalUnion) = x.ints

Base.:(==)(a::IntervalUnion, b::IntervalUnion) = intervals(a)::Tuple == intervals(b)::Tuple
Base.:(==)(a::IntervalUnion, b::Interval) = intervals(a)::Tuple == intervals(b)::Tuple
Base.:(==)(a::Interval, b::IntervalUnion) = intervals(a)::Tuple == intervals(b)::Tuple

IntervalUnion(x::Union{Interval, IntervalUnion}) = convert(IntervalUnion, x)
Base.convert(::Type{IntervalUnion}, x::IntervalUnion) = x
Base.convert(::Type{IntervalUnion}, x::Interval) = IntervalUnion((x,))

Base.in(x, iu::IntervalUnion) = any(in(x, i) for i in intervals(iu))
Base.isempty(iu::IntervalUnion) = all(isempty, intervals(iu))
_dropempty(iu::IntervalUnion) = IntervalUnion(filter(!isempty, intervals(iu)))

_opposite_closedness(x::Symbol) = x == :closed ? :open : x == :open ? :closed : error()
_setdiff(a::Interval{La, Ra}, b::Interval{Lb, Rb}) where {La, Ra, Lb, Rb} = intersect(a, complement(b))

complement(i::Interval{L,R,T}) where {T,L,R} = IntervalUnion((
    Interval{:open, _opposite_closedness(L)}(-T(Inf), leftendpoint(i)),
    Interval{_opposite_closedness(R), :open}(rightendpoint(i), T(Inf)),
))

Base.setdiff(a::Interval, b::IntervalUnion) = @p intervals(b) |> map(_setdiff(a, _)) |> reduce(∩) |> _dropempty
Base.setdiff(a::IntervalUnion, b::Union{Interval, IntervalUnion}) = @p intervals(a) |> map(setdiff(_, IntervalUnion(b))) |> reduce(∪)
Base.:∪(a::Interval, b::IntervalUnion) = IntervalUnion((intervals(a)..., intervals(b)...))
Base.:∪(a::IntervalUnion, b::Union{Interval, IntervalUnion}) = IntervalUnion((intervals(a)..., intervals(b)...))
Base.:∩(a::Interval, b::IntervalUnion) = @modify(i -> a ∩ i, intervals(b) |> Elements()) |> _dropempty
Base.:∩(a::IntervalUnion, b::Interval) = @modify(i -> b ∩ i, intervals(a) |> Elements()) |> _dropempty
Base.:∩(a::IntervalUnion, b::IntervalUnion) = @p intervals(a) |> map(_ ∩ b) |> reduce(∪)

IntervalSets.infimum(iu::IntervalUnion) = minimum(infinimum, intervals(iu))
IntervalSets.supremum(iu::IntervalUnion) = maximum(supremum, intervals(iu))
Base.minimum(iu::IntervalUnion) = minimum(minimum, intervals(iu))
Base.maximum(iu::IntervalUnion) = maximum(maximum, intervals(iu))
Base.extrema(iu::IntervalUnion) = (minimum(iu), maximum(iu))

end
