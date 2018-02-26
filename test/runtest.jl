using Base.Test

import HTTP
import JSON

router = HTTP.Router()

function testfun(r)
  HTTP.Response(200,"Hi")
end


HTTP.register!(router, "GET", "/testfun",HTTP.HandlerFunction(testfun))
	
server = HTTP.Servers.Server(router)
task = @async HTTP.serve(server, ip"127.0.0.1", 8000; verbose=false)

sleep(1.0)

req = HTTP.request("GET","http://127.0.0.1:8000/testfun/")


# end server
put!(server.in, HTTP.Servers.KILL)

@test String(req.body) == "Hi"
