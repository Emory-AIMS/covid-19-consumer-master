local driver = require("resty.mysql")
local utils = require("commons")
local db;
local _Mysql = {}

local mysql_dsn = "mysql"
local mysql_user = "root"
local mysql_password = "example"

local function connect()

    db = driver:new()
    db:set_timeout(1000) -- 1 sec

    local ok, err, err_code, sqlstate = db:connect {
        host = mysql_dsn,
        port = 3306,
        database = "api_coronaviruscheck",
        user = mysql_user,
        password = mysql_password,
        charset = "utf8",
        max_packet_size = 1024 * 1024,
    }

    if not ok then
        return ok, err, err_code, sqlstate;
    end

    return db ;
end

local function mysqlError( err, errcode, sqlstate )
    if err or errcode then
        ngx.status = ngx.HTTP_SERVICE_UNAVAILABLE
        if ngx.var.DEBUG then
            ngx.say('{"Mysql error": "',  err, ": ", errcode, " ", sqlstate , '"}')
        else
            ngx.say( utils:kindResponse() );
        end
        return ngx.exit( ngx.HTTP_SERVICE_UNAVAILABLE );
    end
end

function _Mysql:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

_Mysql.connect = connect;
_Mysql.mysqlError = mysqlError;

return _Mysql;