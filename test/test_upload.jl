import JSON
import HTTP
using DataStructures


password =
    if haskey(ENV,"WEBDAV_PASSWORD")
        ENV["WEBDAV_PASSWORD"]
    else
        read(expanduser("~/.b2drop_password"),String)
    end

data = OrderedDict(
  "url" => "http://127.0.0.1/DIVAnd/v1/bathymetry/?bbox=-10,30,50,45&resolution=0.02,0.02&dataset=GEBCO",
  "webdav" => "https://b2drop.eudat.eu/remote.php/webdav",
  "webdav_path" => "DIVAnd_upload.nc",
  "username" => "a.barth@ulg.ac.be",
  "password" => password
)



baseurl = "http://127.0.0.1:8002"
URL = baseurl * "/v1"

resp = HTTP.request("POST",URL * "/upload/", [], JSON.json(data))

@show resp

# analysis_wrapper(data,filename)

