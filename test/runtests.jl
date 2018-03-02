    using Base.Test

import HTTP
import JSON
import divand
using NCDatasets


# Version of the REST API
const version = "v1"


const bathdatasets = Dict{String,Tuple{String,Bool}}(
    "GEBCO" => ("gebco_30sec_16.nc",true))


"""
   strbbox = encodebbox(bbox)
   minlon,minlat,maxlon,maxlat
"""
encodebbox(bbox) = join(bbox,",")
decodebbox(strbbox) = parse.(Float64,split(strbbox,","))

encodelist(list) = join(list,",")
decodelist(strlist) = parse.(Float64,split(strlist,","))


function savebathnc(filename,b,xy)
    x,y = xy
    ds = Dataset(filename,"c")
    # Dimensions

    ds.dim["lat"] = size(b,2)
    ds.dim["lon"] = size(b,1)

    # Declare variables

    nclat = defVar(ds,"lat", Float64, ("lat",))
    nclat.attrib["long_name"] = "Latitude"
    nclat.attrib["standard_name"] = "latitude"
    nclat.attrib["units"] = "degrees_north"

    nclon = defVar(ds,"lon", Float64, ("lon",))
    nclon.attrib["long_name"] = "Longitude"
    nclon.attrib["standard_name"] = "longitude"
    nclon.attrib["units"] = "degrees_east"

    ncbat = defVar(ds,"bat", Float32, ("lon", "lat"))
    ncbat.attrib["long_name"] = "elevation above sea level"
    ncbat.attrib["standard_name"] = "height"
    ncbat.attrib["units"] = "meters"

    # Global attributes

    #ds.attrib["title"] = "GEBCO"

    # Define variables

    nclat[:] = x
    nclon[:] = y
    ncbat[:] = b

    close(ds)
end

# minlon,minlat,maxlon,maxlat
bbox = [-180,-90,180,90]
@test decodebbox(encodebbox(bbox)) == bbox

list = [1,2]
@test decodelist(encodelist(list)) == list




router = HTTP.Router()

function sendfile(code,filename)
    f = open(filename)
    data = read(f)
    close(f)

    return HTTP.Response(code,data)
end

function bathymetry(req::HTTP.Request)
    params = HTTP.queryparams(HTTP.URI(req.target))
    @show params
    minlon,minlat,maxlon,maxlat = decodebbox(params["bbox"])
    reslon,reslat = decodelist(params["resolution"])
    dataset = params["dataset"]

    
    bathname,isglobal = bathdatasets[dataset]
    
    xi,yi,bath = divand.load_bath(bathname,isglobal,minlon:reslon:maxlon,minlat:reslat:maxlat)
    
    @show minlon,minlat,maxlon,maxlat
    @show reslon,reslat
    @show xi
    filename = tempname()
    #filename = "/tmp/tmp2.nc"
    #if isfile(filename)
    #    rm(filename)
    #end
    savebathnc(filename,bath,(xi,yi))

    return sendfile(200,filename) 
    #stream = HTTP.stream(open(filename))
    #HTTP.Response(200,"Hi")
    #return HTTP.Response(200,stream)
    #return HTTP.Stream(HTTP.Response(200),open("test.txt"))
end

function analysis(req::HTTP.Request)
    data = JSON.parse(HTTP.load(request))
    observations = data["observations"]
    return HTTP.Response(200,string(observations))
end

HTTP.register!(router, "GET", "/v1/bathymetry",HTTP.HandlerFunction(bathymetry))

HTTP.register!(router, "POST", "/v1/analysis",HTTP.HandlerFunction(analysis))

server = HTTP.Servers.Server(router)
task = @async HTTP.serve(server, ip"127.0.0.1", 8001; verbose=false)

sleep(1.0)

URL = "http://127.0.0.1:8001/v1"

req = HTTP.request("GET",URL * "/bathymetry/"; query = Dict(
    "bbox" => encodebbox([-10,30,50,45]),
    "resolution" => encodelist([1,1]),
    "dataset" => "GEBCO"
))


ncfile = tempname()
open(ncfile,"w") do f
    write(f,req.body)
end


req = HTTP.request("POST",URL * "/analysis/"; query = Dict(
    "observations" => ["/home/abarth/projects/Julia/divand-example-data/Provencal/WOD-Salinity.nc"],
    "resolution" => encodelist([1,1]),
    "dataset" => "GEBCO"
))

@show req

# end server
put!(server.in, HTTP.Servers.KILL)


#@test String(req.body) == "Hi"

@test "bat" in Dataset(ncfile)

