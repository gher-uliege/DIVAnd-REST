using Base.Test

import HTTP
import JSON

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
ds = Dataset("filename.nc","c")
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

function testfun(req::HTTP.Request)
  params = HTTP.queryparams(HTTP.URI(req.target))
  @show params
  minlon,minlat,maxlon,maxlat = decodebbox(params["bbox"])
  reslon,reslat = decodelist(params["resolution"])
  
  bathname = "gebco_30sec_16.nc"
  isglobal = true
  
  xi,yi,bath = divand.load_bath(bathname,isglobal,minlon:reslon:maxlon,minlat:reslat:maxlat)
  
  @show minlon,minlat,maxlon,maxlat
  @show reslon,reslat
  @show xi

  #filename = tempname()
  #savebathnc(filename,bath,(xi,yi))
  #stream = HTTP.stream(open(filename))
  HTTP.Response(200,"Hi")
  #return HTTP.Response(200,stream)
  #return HTTP.Stream(HTTP.Response(200),open("test.txt"))
end


HTTP.register!(router, "GET", "/testfun",HTTP.HandlerFunction(testfun))
	
server = HTTP.Servers.Server(router)
task = @async HTTP.serve(server, ip"127.0.0.1", 8000; verbose=false)

sleep(1.0)


req = HTTP.request("GET","http://127.0.0.1:8000/testfun/"; query = Dict(
   "bbox" => encodebbox([-10,30,50,45]),
   "resolution" => encodebbox([1,1])
   )
   )


# end server
put!(server.in, HTTP.Servers.KILL)

@test String(req.body) == "Hi"
