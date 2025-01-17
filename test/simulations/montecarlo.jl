@testset "MonteCarlo" begin
    mc = MonteCarlo(1000)

    @test isa(mc, MonteCarlo)
    @test mc.n == 1000
end

@testset "QuasiMonteCarlo" begin

    # Make sure that all QMC Types implement qmc_samples
    for qmc in subtypes(AbstractQuasiMonteCarlo)
        @test hasmethod(qmc_samples, (qmc, Integer))
    end

    @testset "SobolSampling" begin
        sobol = SobolSampling(1000)

        @test isa(sobol, SobolSampling)
        @test sobol.n == 1000

        @testset "sample" begin
            inputs = [RandomVariable.(Uniform(), [:a, :b]); Parameter(1, :c)]

            samples = sample(inputs, SobolSampling(4))

            @test isapprox(samples.a, [0.375, 0.875, 0.625, 0.125])
            @test isapprox(samples.b, [0.375, 0.875, 0.125, 0.625])
            @test samples.c == [1.0, 1.0, 1.0, 1.0]
        end
    end

    @testset "HaltonSampling" begin
        halton = HaltonSampling(1000)

        @test isa(halton, HaltonSampling)
        @test halton.n == 1000

        @testset "sample" begin
            inputs = [RandomVariable.(Uniform(), [:a, :b]); Parameter(1, :c)]

            samples = sample(inputs, HaltonSampling(4))

            @test isapprox(samples.a, [0.5, 0.25, 0.75, 0.125])
            @test isapprox(samples.b, [1 / 3, 2 / 3, 1 / 9, 4 / 9])
            @test samples.c == [1.0, 1.0, 1.0, 1.0]
        end
    end
end

@testset "LatticeRuleSampling" begin
    lattice = LatticeRuleSampling(1000)
    @test isa(lattice, LatticeRuleSampling)
    @test lattice.n == 1000
    @testset "sample" begin
        inputs = [RandomVariable.(Uniform(), [:a, :b]); Parameter(1, :c)]

        Random.seed!(1)
        s = QuasiMonteCarlo.sample(4, [0, 0], [1, 1], LatticeRuleSample())
        Random.seed!(1)
        samples = sample(inputs, LatticeRuleSampling(4))
        Random.seed!()

        @test isapprox(samples.a, s[1, :])
        @test isapprox(samples.b, s[2, :])
        @test samples.c == [1.0, 1.0, 1.0, 1.0]
    end
end
