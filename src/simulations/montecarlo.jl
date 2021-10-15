struct MonteCarlo <: AbstractMonteCarlo
    n::Integer
    MonteCarlo(n) = n > 0 ? new(n) : error("n must be greater than zero")
end

struct SobolSampling <: AbstractQuasiMonteCarlo
    n::Integer
    SobolSampling(n) = n > 0 ? new(n) : error("n must be greater than zero")
end

struct HaltonSampling <: AbstractQuasiMonteCarlo
    n::Integer
    HaltonSampling(n) = n > 0 ? new(n) : error("n must be greater than zero")
end

struct LatinHypercubeSampling <: AbstractQuasiMonteCarlo
    n::Integer
    LatinHypercubeSampling(n) = n > 0 ? new(n) : error("n must be greater than zero")
end

function sample(inputs::Array{<:UQInput}, sim::MonteCarlo)
    sample(inputs, sim.n)
end

function sample(inputs::Array{<:UQInput}, sim::AbstractQuasiMonteCarlo)
    random_inputs = filter(i -> isa(i, RandomUQInput), inputs)
    deterministic_inputs = filter(i -> isa(i, DeterministicUQInput), inputs)

    n_rv = count_rvs(random_inputs)

    u = qmc_samples(sim, n_rv)

    samples = quantile.(Normal(), u)
    samples = DataFrame(names(random_inputs) .=> eachcol(samples))

    if !isempty(deterministic_inputs)
        samples = hcat(samples, sample(deterministic_inputs, sim.n))
    end

    to_physical_space!(inputs, samples)

    return samples
end

function qmc_samples(sim::SobolSampling, rvs::Integer)
    return QuasiMonteCarlo.sample(sim.n, zeros(rvs), ones(rvs), SobolSample()) |> transpose
end

function qmc_samples(sim::HaltonSampling, rvs::Integer)
    h = HaltonPoint(rvs, length = sim.n)

    u = zeros(sim.n, rvs)

    for (i, hp) ∈ enumerate(h)
        u[i, :] = hp
    end

    return u
end

function qmc_samples(sim::LatinHypercubeSampling, rvs::Integer)
    return QuasiMonteCarlo.sample(sim.n, zeros(rvs), ones(rvs), LatinHypercubeSample()) |>
           transpose
end
