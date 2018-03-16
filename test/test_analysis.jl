import HTTP
import JSON

URL = "http://127.0.0.1:8001/v1"
resp = HTTP.request("POST",URL * "/analysis/", [], JSON.json(Dict(
    "observations" => ["/home/abarth/projects/Julia/divand-example-data/Provencal/WOD-Salinity.nc"],
    "bbox" => encodebbox([-10,30,50,45]),
    "len" => encodelist([100e3,100e3]),
    "epsilon2" => 1.,
    "resolution" => encodelist([1,1]),
    "dataset" => "GEBCO"
)))

@show resp

URL2 = "http://127.0.0.1:8001" * Dict(resp.headers)["Location"]


while true
    resp = HTTP.request("GET",URL2; redirect = false)
    headers = Dict(resp.headers)
    @show URL2

    if haskey(headers,"Location")
        URL3 = "http://127.0.0.1:8001" * headers["Location"]
        resp = HTTP.request("GET",URL3)
        break
    else
        maxage,seconds = split(headers["Cache-Control"],"=")
        println("retry in $(seconds) seconds")
        sleep(parse(Float64,seconds))
    end
end

@show resp
