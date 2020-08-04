local redis = require("resty.redis")
local utils = require("commons")
local connection;
local _Redis = {}

local redis_dsn = "redis"

local function connect()

    connection = redis:new()
    connection:set_timeout(1000)

    local ok, err = connection:connect(redis_dsn, 6379)
    if not ok then
        ngx.status = ngx.HTTP_SERVICE_UNAVAILABLE
        if ngx.var.DEBUG then
            ngx.say('{"error": "', err, '"}')
        else
            ngx.say(utils:kindResponse());
        end
        error( ngx.exit(ngx.HTTP_SERVICE_UNAVAILABLE) )
    end

    return connection;

end

local function set(key, value)
    connection:set(key, value)
end

local function get(key)
    local redisResponse, err = connection:get(key)
    if err then
        ngx.status = ngx.HTTP_SERVICE_UNAVAILABLE;
        if ngx.var.DEBUG then
            ngx.say('{"error": "', err, '"}')
        else
            ngx.say(utils:kindResponse());
        end
        error( ngx.exit(ngx.HTTP_SERVICE_UNAVAILABLE) );
    end
    return redisResponse;
end

local function close()
    connection:close()
end

function _Redis:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

_Redis.connect = connect;
_Redis.get = get;
_Redis.set = set;
_Redis.close = close;

return _Redis;