module UncertaintyQuantification

using LinearAlgebra, DataFrames, Reexport

@reexport using Distributions

import Base: rand

abstract type UQtypes end
abstract type AbstractInput <: UQtypes end
abstract type AbstractModel <: UQtypes end

export
    # inputs
    Parameter,
    RandomVariable,
    RandomVariableSet,

    Model,

    MonteCarlo,

    # methods
    copularand,
    evaluate,
    rand,
    sample,

    probabilityOfFailure

include("inputs/parameter.jl")
include("inputs/randomvariable.jl")
include("inputs/randomvariableset.jl")
include("inputs/sample.jl")

include("models/model.jl")

include("simulations/montecarlo.jl")

include("reliability/probabilityoffailure.jl")

include("util/copula.jl")

end
