import HTTP
import JSON
using DataStructures

URL = "http://127.0.0.1:8001/v1"

filename = joinpath(dirname(@__FILE__),"test_analysis2.json")

data = JSON.parsefile(filename;
                      dicttype=DataStructures.OrderedDict)

resp = HTTP.request("POST",URL * "/analysis/", [], JSON.json(data))

@show resp

# redirects to queue
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

#@show resp

open("/tmp/output.nc","w") do f
    write(f,resp.body)
end
