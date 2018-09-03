using Test
import HTTP
using Random
using Base64

url = "https://b2drop.eudat.eu/remote.php/webdav"
username = "a.barth@ulg.ac.be";
password =
    if haskey(ENV,"WEBDAV_PASSWORD")
        ENV["WEBDAV_PASSWORD"]
    else
        read(expanduser("~/.b2drop_password"),String)
    end

userinfo = username * ":" * password;

f = open("mytest","r"); r = HTTP.request("PUT", "https://b2drop.eudat.eu/remote.php/webdav/mytest_julia5", [("Authorization", "Basic $(base64encode(userinfo))")], f);


s = WebDAV(url,username,password);
r = upload(s, "mytest", "mytest_julia6.txt")

r = download(s, "mytest_julia6.txt")


download(s, "mytest_julia6.txt","/tmp/mytest")

open(s, "mytest_julia6.txt","r") do io
    @show read(io,String)
end


open(s, "mytest_julia7.txt","w") do io
    write(io,"blabla")
end

open(s, "mytest_julia7.txt","r")

@test read(open(s, "mytest_julia7.txt"),String) == "blabla"

@show readdir(s,"/")

if isdir(s,"test-dir-julia")
    rm(s,"test-dir-julia")
end
@test isdir(s,"test-dir-julia") == false

mkdir(s,"test-dir-julia")

@test isdir(s,"test-dir-julia")
@test isdir(s,"mytest_julia6.txt") == false

@test isfile(s,"test-dir-julia") == false
@test isfile(s,"mytest_julia6.txt")
