local utils = require("commons")
local cjson = require("cjson")
local http = require("resty.http")

local android_secret_captcha = "android_secret_captcha"
local ios_secret_captcha = "ios_secret_captcha"

local function _checkCaptcha(challenge, manufacturer)
    if utils.isEmpty(challenge) then
        ngx.status = ngx.HTTP_UNAUTHORIZED
        if ngx.var.DEBUG then
            ngx.say('{"error": "No challenge received."}')
        end
        error(ngx.exit(ngx.HTTP_UNAUTHORIZED))
    else

        local secret = android_secret_captcha;
        if string.lower(manufacturer) == "apple" then
            secret = ios_secret_captcha;
        end

        local httpc = http.new()
        local res, err = httpc:request_uri("https://www.google.com/recaptcha/api/siteverify", {
            method = "POST",
            body = "secret=" .. secret .. "&response=" .. challenge,
            headers = {
                ["Content-Type"] = "application/x-www-form-urlencoded",
            },
            keepalive = false,
            ssl_verify = false
        });

        if not res then
            ngx.status = ngx.HTTP_SERVICE_UNAVAILABLE
            if ngx.var.DEBUG then
                ngx.say('{"errorCaptcha": "' .. err .. '", "response": ' .. res.body .. '}')
            end
            error(ngx.exit(ngx.HTTP_SERVICE_UNAVAILABLE))
        end

        -- https://github.com/ledgetech/lua-resty-http
        -- https://developers.google.com/recaptcha/docs/verify

        -- curl -X POST \
        --  https://www.google.com/recaptcha/api/siteverify \
        --  -H ‘Content-Type: application/x-www-form-urlencoded’ \
        --  -d ‘secret=SECRET&response=CHALLENGE’

        --{
        --    "success": false,
        --    "error-codes": [
        --        "timeout-or-duplicate",
        --        "invalid-input-response",
        --        "invalid-input-secret"
        --    ]
        --}

        local result = cjson.decode(res.body)

        if not result.success then
            ngx.status = ngx.HTTP_UNAUTHORIZED
            if ngx.var.DEBUG then
                ngx.say('{"errorCaptcha": ' .. res.body .. '}')
            end
            error(ngx.exit(ngx.HTTP_UNAUTHORIZED))
        end

    end
end

local _service = {}
function _service:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end
_service.check = _checkCaptcha;
return _service;