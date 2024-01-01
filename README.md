# IntervalUnions.jl

Extend [IntervalSets.jl](https://github.com/JuliaMath/IntervalSets.jl) with _interval unions_ -- unions of disjoint intervals. Not all operations are type-stable for now, this is subject to further improvements.

## Examples

```julia
julia> iu = IntervalUnion((1..2., 3..4.))
1.0..2.0 ∪ 3.0..4.0

julia> iu ∪ (10..11.)
1.0..2.0 ∪ 3.0..4.0 ∪ 10.0..11.0

julia> setdiff(iu, 1.3..3)
1.0..1.3 (closed–open) ∪ 3.0..4.0 (open–closed)
```
