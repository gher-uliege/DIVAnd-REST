using Base.Test

import HTTP
import JSON
import divand
using NCDatasets


# Version of the REST API
const version = "v1"

const basedir = "/$(version)"

const idlength = 24

const bathdatasets = Dict{String,Tuple{String,Bool}}(
    "GEBCO" => ("gebco_30sec_16.nc",true))


const workdir = "/tmp/"

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

analysisname(analysisid) = joinpath(workdir,analysisid * ".nc")


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
    path = HTTP.URI(req.target).path

    if req.method == "POST"
        data = JSON.parse(HTTP.payload(req,String))
        observations = data["observations"]
        
        @show path
        analysisid = randstring(idlength)
        analysisid = "12345"
                
        @async begin
            fname = analysisname(analysisid)
            if isfile(fname)
                rm(fname)
            end
            sleep(5.0)

            f = open(fname,"w")
            write(f,"lala123")
            close(f)
        end
        
        # analysis in progress
        return HTTP.Response(202,["Location" => "$(basedir)/queue/$(analysisid)"])
        #return HTTP.Response(202,["Location" => "$(basedir)/queue/"])
    else
        # analysis is done
        analysisid = split(path,"$(basedir)/analysis/")[2]
        fname = analysisname(analysisid)
        if isfile(fname)
            return sendfile(200,fname)
        else
            return HTTP.Response(404,"Not found")
        end
    end
end

function queue(req::HTTP.Request)
    path = HTTP.URI(req.target).path
    analysisid = split(path,"$(basedir)/queue/")[2]
    filename = analysisname(analysisid)
    const retry = 4    
    if isfile(filename)
        return HTTP.Response(
            307,
            ["Location" => "$(basedir)/analysis/$(analysisid)"];
            body = "lala"
        )
    else        
        return HTTP.Response(
            200,
            ["Cache-Control" => "max-age=$(retry)"];
            body = JSON.json(Dict(
               "status" => "pending")))
    end
end

function moveto(req::HTTP.Request)
    return HTTP.Response(200,"move")
end

HTTP.register!(router, "GET",  "$basedir/bathymetry",HTTP.HandlerFunction(bathymetry))
HTTP.register!(router, "POST", "$basedir/analysis",HTTP.HandlerFunction(analysis))
HTTP.register!(router, "GET",  "$basedir/analysis",HTTP.HandlerFunction(analysis))
HTTP.register!(router, "GET",  "$basedir/queue",HTTP.HandlerFunction(queue))
HTTP.register!(router, "POST", "$basedir/moveto",HTTP.HandlerFunction(moveto))

server = HTTP.Servers.Server(router)
task = @async HTTP.serve(server, ip"127.0.0.1", 8001; verbose=false)

URL = "http://127.0.0.1:8001" * basedir
