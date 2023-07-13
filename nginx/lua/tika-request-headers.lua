-- use args to set headers
local args = ngx.req.get_uri_args()
local fetchKey = args["local_file_path"]

if fetchKey then
    ngx.log(ngx.STDERR, "Got fetchkey " .. fetchKey)
    ngx.req.set_header("fetcherName", "fsf")
    ngx.req.set_header("fetchKey", fetchKey)

    args.local_file_path = nil
    ngx.req.set_uri_args(args)
else
    ngx.log(ngx.STDERR, "No fetch key")
end
