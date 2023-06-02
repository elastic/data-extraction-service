local chunk, eof = ngx.arg[1], ngx.arg[2]
local buffered = ngx.ctx.buffered
if not buffered then
    buffered = {}
    ngx.ctx.buffered = buffered
end
if chunk ~= "" then
    buffered[#buffered + 1] = chunk
    ngx.arg[1] = nil
end
if eof then
    local whole = table.concat(buffered)
    ngx.ctx.buffered = nil
    -- TODO parse json here
    local cjson = require "cjson"
    local body = cjson.decode(whole)
    local response = cjson.encode({
        extracted_text = body["X-TIKA:content"]
    })
    ngx.arg[1] = response
end