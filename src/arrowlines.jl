# Taken from MakieExtra.jl (JuliaAPlavin)
using Accessors: @modify, @set, If
using DataPipes: @p
import AccessorsExtra: RecursiveOfType
import Makie: documented_attributes

### https://github.com/MakieOrg/Makie.jl/pull/3915

# mimick Observables.jl map() signature to forward directly:
lift(f, arg::Makie.AbstractObservable, args...; kwargs...) = map(f, arg, args...; kwargs...)
# handle the general case:
function lift(f, args...; kwargs...)
    if !any(a -> isa(a, Makie.AbstractObservable), args)
        # there are no observables
        f(args...)
    else
        # there are observables, but not in the first position
        lift((_, as...) -> f(as...), Observable(nothing), args...; kwargs...)
    end
end


function liftT(f::Function, T::Type, args...)
    res = Observable{T}(f(to_value.(args)...))
    map!(f, res, args...)
    return res
end


"""
Returns a set of all sub-expressions in an expression that look like \$some_expression
"""
function find_observable_expressions(obj::Expr)
    observable_expressions = Set()
    if is_interpolated_observable(obj)
        push!(observable_expressions, obj)
    else
        for a in obj.args
            observable_expressions = union(observable_expressions, find_observable_expressions(a))
        end
    end
    return observable_expressions
end

# empty dict if x is not an Expr
find_observable_expressions(x) = Set()

is_interpolated_observable(x) = false
function is_interpolated_observable(e::Expr)
    e.head == Symbol(:$) && length(e.args) == 1
end

"""
Replaces every subexpression that looks like a observable expression with a substitute symbol stored in `exprdict`.
"""
function replace_observable_expressions(exp::Expr, exprdict)
    if is_interpolated_observable(exp)
        exprdict[exp]
    else
        Expr(exp.head, replace_observable_expressions.(exp.args, Ref(exprdict))...)
    end
end

replace_observable_expressions(x, exprdict) = x

"""
    @lift expr
    @lift expr::T

Similar to `Makie.@lift`, but:
- supports specifying the target observable type `T`;
- works without any observables at all, resulting in a no-op.
"""
macro lift(exp)
    exp = @modify(exp |> RecursiveOfType(Expr) |> If(e -> Base.isexpr(e, :macrocall) && e.args[1] == Symbol("@f_str"))) do e
        macroexpand(__module__, e; recursive=true)
    end

    observable_expr_set = find_observable_expressions(exp)

    # store expressions with their substitute symbols, gensym them manually to be
    # able to escape the expression later
    observable_expr_arg_dict = Dict(expr => gensym("arg$i") for (i, expr) in enumerate(observable_expr_set))

    exp = replace_observable_expressions(exp, observable_expr_arg_dict)

    # keep an array for ordering
    observable_expressions_array = collect(keys(observable_expr_arg_dict))
    observable_substitutes_array = [observable_expr_arg_dict[expr] for expr in observable_expressions_array]
    observable_expressions_without_dollar = [n.args[1] for n in observable_expressions_array]

    # the arguments to the lifted function
    argtuple = Expr(Symbol(:tuple), observable_substitutes_array...)

    # the lifted function itself
    function_expression = Expr(Symbol(:->), argtuple, exp)

    if Base.isexpr(exp, Symbol("::"))
        # the full expression
        T = exp.args[2]
        return Expr(
            Symbol(:call),
            Symbol(:liftT),
            esc(function_expression),
            esc(T),
            esc.(observable_expressions_without_dollar)...
        )
    else
        # the full expression
        return Expr(
            Symbol(:call),
            Symbol(:lift),
            esc(function_expression),
            esc.(observable_expressions_without_dollar)...
        )
    end
end

filter_keys(pred, d::Dict) = Dict(k => v for (k, v) in pairs(d) if pred(k))

"""    arrowlines(positions; arrowstyle="-|>", ...)

Like `lines()`, but with arrows at one or both ends of the line.
Supports all `lines()` and `scatter()` attributes.

Adds the `arrowstyle` attribute, a string with the following format:
`<left marker><line style><right marker>`
where `<left marker>` and `<right marker>` are one of `"", "<", "<|", ">", "|>"`, and `<line style>` is one of `"-", "--", ".."`.
"""
@recipe ArrowLines () begin
    arrowstyle = "-|>"
    documented_attributes(Lines)...
    @modify($(documented_attributes(Makie.Scatter)).d) do d
        filter_keys(∉(keys(documented_attributes(Lines).d)), d)
    end...
end

Makie.conversion_trait(::Type{<:ArrowLines}) = PointBased()

function Makie.plot!(p::ArrowLines)
    points = p[1]
    @assert length(points[]) ≥ 2
    
    scene = Makie.get_scene(p)
    markerangles = lift(scene.camera.projectionview, p.model, Makie.transform_func(p), scene.viewport, points) do _, _, tfunc, _, ps_all
        map([
            (ps_all[begin], ps_all[begin + 1]),
            (ps_all[end - 1], ps_all[end]),
        ]) do ps
            ps_t = Makie.apply_transform.(Ref(tfunc), ps)
            ps_pix = Makie.project.(Ref(scene), ps_t)
            atan(reverse(ps_pix[2] - ps_pix[1])...)
        end
    end

    ast = Makie.@lift parse_arrowstyle($(p.arrowstyle))

    attrs = @p let
        Makie.shared_attributes(p, Lines)
        @set __[:linestyle] = @lift $ast.linestyle
    end
    lines!(p, attrs, points)
    let
        s_points = @lift [first($points), last($points)]
        s_markers = @lift [$ast.lm, $ast.rm]
        s_rotations = @lift [$markerangles[1] + deg2rad(180), $markerangles[2]]
        attrs = @p let
            Makie.shared_attributes(p, Makie.Scatter)
            @set __[:marker] = s_markers
            @set __[:rotation] = s_rotations
        end
        scatter!(p, attrs, s_points)
    end
end

const marker_l_to_r = Dict(
    "" => "",
    "<" => ">",
    "<|" => "|>",
    ">" => "<",
    "|>" => "<|",
)

const marker_rs = Dict(
    "" => Makie.Polygon(Point2f[(0,0), (1e-10,1e-10)]),  # empty marker
    ">" => Makie.Polygon(Point2f[(0, 0), (-1, 0.5), (-0.5, 0), (-1, -0.5)]),
    "|>" => Makie.Polygon(Point2f[(0, 0), (-1, 0.5), (-1, -0.5)]),
    "<" => Makie.Polygon(Point2f[(-1, 0), (0, 0.5), (-0.5, 0), (0, -0.5)]),
    "<|" => Makie.Polygon(Point2f[(-1, 0), (0, 0.5), (0, -0.5)]),
)

function split_arrowstyle(s)
    lmks = filter(mk -> startswith(s, mk), keys(marker_l_to_r))
    rmks = filter(mk -> endswith(s, mk), keys(marker_rs))
    lmk = isempty(lmks) ? nothing : argmax(length, lmks)
    rmk = isempty(rmks) ? nothing : argmax(length, rmks)
    linek = @p s chopprefix(__, lmk) chopsuffix(__, rmk)
    (
        lmk=lmk,
        rmk=rmk,
        linek,
    )
end

function parse_arrowstyle(s::AbstractString)
    (;lmk, rmk, linek) = split_arrowstyle(s)
    (
        lm=marker_rs[marker_l_to_r[lmk]],
        rm=marker_rs[rmk],
        linestyle=Dict(
            "-" => nothing,
            "--" => :dash,
            ".." => :dot,
        )[linek],
    )
end

function Base.setindex(x::Attributes, value::Observable, key::Symbol)
    y = copy(x)
    y[key] = value
    return y
end
Base.setindex(x::Attributes, value, key::Symbol) = Base.setindex(x, Observable(value), key)

