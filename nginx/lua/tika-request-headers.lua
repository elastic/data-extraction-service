-- use args to set headers
local args = ngx.req.get_uri_args()

if args["local_file_path"] then
    ngx.req.set_header("fetcherName", "fsf")
    ngx.req.set_header("fetchKey", args["local_file_path"])

    -- remove args
    ngx.req.set_uri_args({local_file_path=nil})
end
