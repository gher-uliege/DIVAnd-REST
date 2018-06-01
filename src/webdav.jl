#module webdav
import HTTP
using EzXML
using Base.Filesystem: readdir, mkdir, isdir, isfile
using Base: open

namespace = Dict("d" => "DAV:")

immutable WebDAV
    url
    headers
end

"""
    server = WebDAV(url,username,password)

`url` is for example https://server/remote.php/webdav for an NextCloud instance
"""
function WebDAV(url::AbstractString,username::AbstractString,password::AbstractString)
    userinfo = username * ":" * password
    headers = [("Authorization", "Basic $(base64encode(userinfo))")]
    return WebDAV(url,headers)
end

function upload(s::WebDAV,stream::IO,remotepath::AbstractString)
    r = HTTP.request("PUT", s.url * "/" * remotepath,s.headers, stream);
end

function upload(s::WebDAV,localpath::AbstractString,remotepath::AbstractString)
    open(localpath) do stream
        upload(s,stream,remotepath)
    end
end

function download(s::WebDAV,remotepath::AbstractString,localpath::AbstractString)
    open(localpath,"w") do file
        open(s,remotepath,"r") do stream
            while !eof(stream)
                write(file,readavailable(stream))
            end
        end
    end
end

function download(s::WebDAV,remotepath::AbstractString)
    localpath = tempname()
    download(s,remotepath,localpath)
    return localpath
end

# Filesystem-like API


function Base.open(s::WebDAV,remotepath::AbstractString,
                   mode::AbstractString = "r")

    if mode == "r"
        io = Base.BufferStream()        
        r = HTTP.request("GET", s.url * "/" * remotepath,s.headers,response_stream = io)
        return io
    else
        error("unsupported mode $(mode)")
    end

    return nothing
end

function Base.open(f::Function,s::WebDAV,remotepath::AbstractString,
                   mode::AbstractString = "r")

    if mode == "r"
        r = HTTP.open("GET", s.url * "/" * remotepath,s.headers) do io
            f(io)
        end
    elseif mode == "w"
        r = HTTP.open("PUT", s.url * "/" * remotepath,s.headers) do io
            f(io)
        end        
    else
        error("unsupported mode $(mode)")
    end

    return nothing
end

function properties(s,dir)
    r = HTTP.request("PROPFIND", s.url * "/" * dir, s.headers; status_exception = false);
    return EzXML.parsexml(String(r.body)),r.status
end

function Base.Filesystem.readdir(s,dir::AbstractString=".")
    doc,status = properties(s,dir)
    if status == 404
        error("directory $(dir) not found on server $(s.url)")
    end

    path = HTTP.URI(s.url).path
    response = find(root(doc),"d:response",namespace)
    list = Vector{String}(length(response))
    for i = 1:length(response)
        url = nodecontent(findfirst(response[i],"d:href"))
        
        if startswith(url,path)
            list[i] = url[length(path)+1:end]
        else
            list[i] = url
        end
    end

    return list
end

function Base.Filesystem.mkdir(s,dir::AbstractString)
    r = HTTP.request("MKCOL", s.url * "/" * dir, s.headers);
    return nothing
end

function Base.Filesystem.rm(s,dir::AbstractString)
    r = HTTP.request("DELETE", s.url * "/" * dir, s.headers);
    return nothing
end

function Base.Filesystem.isdir(s,dir::AbstractString)
    doc,status = properties(s,dir)

    # not found
    if status == 404
        return false
    end
    
    resourcetype = find(root(doc),"d:response[1]/d:propstat/d:prop/d:resourcetype/*",namespace)

    return "collection" in nodename.(resourcetype)
end


function Base.Filesystem.isfile(s,dir::AbstractString)
    doc,status = properties(s,dir)

    # not found
    if status == 404
        return false
    end
    
    resourcetype = find(root(doc),"d:response[1]/d:propstat/d:prop/d:resourcetype/*",namespace)

    return !("collection" in nodename.(resourcetype))
end

#end
