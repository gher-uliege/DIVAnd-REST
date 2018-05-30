#module webdav
import HTTP

"""
    server = WebDAV(url,username,password)

`url` is for example https://server/remote.php/webdav for an NextCloud instance
"""
immutable WebDAV
   url
   username
   password
end


function upload(s::WebDAV,stream::IO,remotepath::AbstractString)
    userinfo = s.username * ":" * s.password;
    r = HTTP.request(
        "PUT", s.url * "/" * remotepath,
        [("Authorization", "Basic $(base64encode(userinfo))")], stream);
end

function upload(s::WebDAV,localpath::AbstractString,remotepath::AbstractString)
    open(localpath) do stream
        upload(s,stream,remotepath)
    end
end
        
#end
