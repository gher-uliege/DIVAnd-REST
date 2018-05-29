import HTTP
import JSON
using DataStructures


baseurl = "http://127.0.0.1:8002"
URL = baseurl * "/v1"

filename = joinpath(dirname(@__FILE__),"test_analysis2.json")

data = JSON.parsefile(filename;
                      dicttype=DataStructures.OrderedDict)

resp = HTTP.request("POST",URL * "/analysis/", [], JSON.json(data))

@show resp

# redirects to queue
URL2 = baseurl * Dict(resp.headers)["Location"]

# wait until finished
while true
    resp = HTTP.request("GET",URL2)
    headers = Dict(resp.headers)
    @show URL2
    @show headers
    data = JSON.parse(String(resp.body))
    
    if get(data,"status","undefined") == "done"
        URL_analysis = baseurl * data["url"]
        resp = HTTP.request("GET",URL_analysis)
        break
    end
        

    seconds = 
        if haskey(headers,"Cache-Control")
            maxage,strseconds = split(headers["Cache-Control"],"=")
            parse(Float64,strseconds)
        else
            1
        end
    
    println("retry in $(seconds) seconds")
    sleep(seconds)
end

#@show resp

open("/tmp/output.nc","w") do f
    write(f,resp.body)
end
