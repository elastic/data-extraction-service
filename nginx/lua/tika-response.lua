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

    local cjson = require "cjson"
    local body = cjson.decode(whole)

    local response = {}

    if not body[1] then
        response["error"] = "Internal Server Error"
        response["message"] = "Unexpected response format from Tika server."
    elseif not body[1]["X-TIKA:content"] then

        for k, v in pairs(body[1]) do
            if string.find(k, "X-TIKA:EXCEPTION") then
                local i = string.find(v, "\n")
                local message = ""
                if not i then
                    message = v
                else
                    -- Tika errors are often massive Java stack traces.
                    -- We can see these in full in the tikaserver.log so only send first line back.
                    message = string.sub(v, 1, i - 1)
                end
                response["error"] = "Content Extraction Error"
                response["message"] = k .. " - " .. message
                break
            end
        end

        if not response["error"] then
            -- if no exceptions are returned, content was extracted but it was likely a blank document
            response["extracted_text"] = ""
        end
    else
        response["extracted_text"] = body[1]["X-TIKA:content"]
    end

    ngx.arg[1] = cjson.encode(response)
end
