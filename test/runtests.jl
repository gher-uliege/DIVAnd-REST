


include(joinpath("..","src","DIVAndREST.jl"))
sleep(1.0)

#include("test_bathymetry.jl")
include("test_analysis.jl")

# end server
put!(server.in, HTTP.Servers.KILL)


#@test String(req.body) == "Hi"


