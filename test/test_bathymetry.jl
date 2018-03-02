req = HTTP.request("GET",URL * "/bathymetry/"; query = Dict(
    "bbox" => encodebbox([-10,30,50,45]),
    "resolution" => encodelist([1,1]),
    "dataset" => "GEBCO"
))


ncfile = tempname()
open(ncfile,"w") do f
    write(f,req.body)
end

@test "bat" in Dataset(ncfile)
