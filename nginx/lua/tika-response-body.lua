--[[
Copyright Elasticsearch B.V. and/or licensed to Elasticsearch B.V. under one
or more contributor license agreements. Licensed under the Elastic License 2.0;
you may not use this file except in compliance with the Elastic License 2.0.
]]

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
    local response = {
        _meta = {
            ["X-ELASTIC:service"] = "tika"
        }
    }

    if ngx.status == 200 then
        local body = cjson.decode(whole)

        if not body["X-TIKA:content"] then
            for k, v in pairs(body) do
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
                    ngx.log(ngx.STDERR, response["error"])
                    break
                end
            end

            if not response["error"] then
                -- if no exceptions are returned, content was extracted but it was likely a blank document
                response["extracted_text"] = ""
            end
        else
            response["extracted_text"] = body["X-TIKA:content"]
            response["_meta"]["X-ELASTIC:TIKA:parsed_by"] = body["X-TIKA:Parsed-By"]
        end
    elseif ngx.status == 422 then
        response["error"] = "Unprocessable Entity"
        response["message"] = "Tikaserver could not process file. File may be corrupt or encrypted."
        ngx.log(ngx.STDERR, response["error"])
    else
        response["error"] = "Unexpected Extraction Failure"
        response["message"] = "Tikaserver could not extract the file content."
        ngx.log(ngx.STDERR, response["error"])
    end

    ngx.arg[1] = cjson.encode(response)
end
