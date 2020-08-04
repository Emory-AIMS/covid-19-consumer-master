local cjson = require("cjson")
local utils = require("commons")

local httpFunc = {}

local function getBody()

    ngx.req.read_body()

    local args, err = ngx.req.get_post_args() -- decoded as key/value pairs
    if err == "truncated" or not args then
        ngx.status = ngx.HTTP_SERVICE_UNAVAILABLE
        if ngx.var.DEBUG then
            ngx.say('{"error": "', err, '"}')
        else
            ngx.say(utils:kindResponse());
        end
        error(ngx.exit(ngx.HTTP_SERVICE_UNAVAILABLE));
    end

    args = ngx.var.request_body  -- raw string
    return cjson.new().decode(args);

end

local function readTokenFromAuth()
    local h, err = ngx.req.get_headers();

    if err == "truncated" then
        ngx.say('{"error": "', err, '"}')
        error(ngx.exit(ngx.HTTP_BAD_REQUEST));
    end

    for k, v in pairs(h) do
        if (k:find("authorization") == 1) then
            return v:sub(8);
        end
    end

    ngx.say('{"error": "Invalid Token"}')
    error(ngx.exit(ngx.HTTP_UNAUTHORIZED));

end

function httpFunc:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

httpFunc.getRequestBody = getBody;
httpFunc.readTokenFromAuth = readTokenFromAuth;

return httpFunc
