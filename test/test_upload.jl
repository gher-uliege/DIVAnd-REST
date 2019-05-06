#!/usr/bin/env julia
import JSON
import HTTP
using DataStructures

fname = expanduser("~/.b2drop_credentials")

if haskey(ENV,"WEBDAV_PASSWORD")
    username,password,url = ENV["WEBDAV_USERNAME"],ENV["WEBDAV_PASSWORD"],ENV["WEBDAV_URL"]
else
    if isfile(fname)
        webdav_username,webdav_password,webdav_url = split(read(fname,String))
    else
        @info "no file $(fname)"
        return
    end
end

data = OrderedDict(
  "url" => "https://postman-echo.com/get",
  "webdav_url" => webdav_url,
  "webdav_filepath" => "upload_data.json",
  "webdav_username" => webdav_username,
  "webdav_password" => webdav_password
)

baseurl = "http://localhost:8002"
URL = baseurl * "/v1"

resp = HTTP.request("POST",URL * "/upload/", [], JSON.json(data))

@show resp

# analysis_wrapper(data,filename)

