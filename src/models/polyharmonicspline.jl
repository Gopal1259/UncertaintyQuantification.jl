struct PolyharmonicSpline <: UQModel
    w::Array{Float64}
    v::Array{Float64}
    c::Array{Float64,2}
    k::Int64
    n::Array{Symbol}
    output::Symbol

    function PolyharmonicSpline(data::DataFrame, k::Int64, output::Symbol)
        f = data[:, output]

        centers = select(data, Not(output))
        n = propertynames(centers)
        centers = Matrix{Float64}(centers)

        dim = size(centers, 1)

        A = zeros(dim, dim)
        for i in 1:dim, j in 1:dim
            if i == j
                continue
            end
            r = sqrt(sum((centers[i, :] - centers[j, :]) .^ 2))
            A[i, j] = ϕ(r, k)
        end

        B = [ones(dim, 1) centers]

        M = [A B; transpose(B) zeros(size(B, 2), size(B, 2))]
        F = [f; zeros(size(B, 2), 1)]

        wv = M \ F

        w = wv[1:dim, :]
        v = wv[(dim + 1):size(wv, 1), :]

        return new(w, v, centers, k, n, output)
    end
end

function ϕ(r::Float64, k::Int64)
    if k % 2 != 0
        return r^k
    elseif r < 1
        return r^(k - 1) * log(r^r)
    else
        return r^k * log(r)
    end
end

function calc(ps::PolyharmonicSpline, x::Array{Float64,1})
    r = sqrt.(sum((ps.c .- transpose(x)) .^ 2; dims=2))
    f = sum(ϕ.(r, ps.k) .* ps.w)
    return f += (transpose(ps.v) * [1; x])[1]
end

function evaluate!(ps::PolyharmonicSpline, df::DataFrame)
    x = Matrix{Float64}(df[:, ps.n]) # convert to matrix and order variables by ps.n

    out = map(row -> calc(ps, convert(Array, row)), eachrow(x))
    return df[!, ps.output] = out
end
