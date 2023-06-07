module Test

include("../src/RxMQTT.jl")
using .RxMQTT
using Random
using Test
using Rocket

# import Base: read, write, close

include("smoke.jl")
# include("mocksocket.jl")
# include("packet.jl")
# include("unittests.jl")

end # module