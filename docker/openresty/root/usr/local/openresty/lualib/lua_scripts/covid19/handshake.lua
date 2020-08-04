local utils = require("commons")
local Mysql = require("database")
local _cache = require("cache")
local httpFunc = require("http_functions")
local jwt_handler = require("jwt_handler")
local reCaptcha = require("re-captcha")


local status, json_request = pcall(httpFunc.getRequestBody);
if not status then
    return json_request;
end

local Redis = _cache:new();
local redis_conn_status, errCode = pcall(Redis.connect)
if not redis_conn_status then
    return errCode;
end

if json_request.id then

    local redisGetStatus, cacheResponse = pcall(Redis.get, "device_sha_id:" .. json_request.id)
    if not redisGetStatus then
        return cacheResponse;
    end

    if utils.isEmpty(cacheResponse) then

        local mysql = Mysql:new();
        local db, conn_err, conn_err_code, connect_sqlstate = mysql:connect();

        if not db then
            return mysql:mysqlError(conn_err, conn_err_code, connect_sqlstate);
        end

        local id = ngx.quote_sql_str(json_request.id);
        local os_name = ngx.quote_sql_str(json_request.os.name);
        local os_version = ngx.quote_sql_str(json_request.os.version);
        local device_manufacturer = ngx.quote_sql_str(json_request.device.manufacturer);
        local device_model = ngx.quote_sql_str(json_request.device.model);

        local res, query_err, err_code, query_sqlstate = db:query(
                "SELECT id FROM devices_hs_id WHERE hs_id = " .. id
        );

        -- Mysql exception
        if not res then
            return mysql:mysqlError(query_err, err_code, query_sqlstate);
        end

        if utils.isEmpty(res) then

            -- ngx.log(ngx.STDERR, json_request.challenge)
            -- disabling recaptcha testing
            -- local rc = reCaptcha:new()
            -- local response, challengeError = pcall(rc.check, json_request.challenge, json_request.device.manufacturer);
            -- if not response then
            --     return challengeError;
            -- end

            local query = "INSERT INTO devices_hs_id (hs_id,os_name,os_version,device_manufacturer,device_model) "
                    .. "VALUES (" .. id .. "," .. os_name
                    .. "," .. os_version .. "," .. device_manufacturer
                    .. "," .. device_model .. ")";

            res, err, errcode, sqlstate = db:query(query);
            if not res or err then
                return mysql:mysqlError(err, errcode, sqlstate);
            end

            db:close();

            local jwt = jwt_handler.generateToken({ id = tonumber(res.insert_id) });

            -- create redis record
            Redis.set("device_sha_id:" .. json_request.id, res.insert_id);
            ngx.say('{"cache":false,"id": ' .. res.insert_id .. ', "token": "' .. jwt .. '"}');

        else
            local jwt = jwt_handler.generateToken({ id = tonumber(res[1].id) });

            -- we lost redis record, set it again
            Redis.set("device_sha_id:" .. json_request.id, res[1].id);
            ngx.say('{"cache":false,"id": ' .. res[1].id .. ', "token": "' .. jwt .. '"}');
        end

    else
        local jwt = jwt_handler.generateToken({ id = tonumber(cacheResponse) });
        -- cache hit
        ngx.say('{"cache": true,"id": ' .. tonumber(cacheResponse) .. ', "token": "' .. jwt .. '"}')
    end

end

Redis:close();