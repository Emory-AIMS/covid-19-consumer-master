local httpFunc = require("http_functions")
local Mysql = require("database")
local jwt_handler = require("jwt_handler")

local auth_status, auth_jwt = pcall( jwt_handler.checkAuthorization );
if not auth_status then
    return auth_jwt;
end

local status, json_request = pcall( httpFunc.getRequestBody );
if not status then
    return json_request;
end

if json_request.id and json_request.id == auth_jwt.id then

    local mysql = Mysql:new();
    local db, conn_err, conn_err_code, connect_sqlstate = mysql:connect();

    if not db then
        return mysql:mysqlError(conn_err, conn_err_code, connect_sqlstate);
    end

    local id = ngx.quote_sql_str(json_request.id);
    local push_id = ngx.quote_sql_str(json_request.push_id);

    local query = "UPDATE devices_hs_id SET notification_id = " .. push_id .. " WHERE id = " .. id ;
   

    local res, err, err_code, sqlstate = db:query(query);
    if not res or err then
        return mysql:mysqlError(err, err_code, sqlstate);
    end

    db:close();
    
    if ngx.var.DEBUG then
        ngx.say('{"result": ', res.affected_rows, '}');
    end
else
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.say('{"error": "Invalid Token."}');
    return ngx.exit(ngx.HTTP_UNAUTHORIZED);
end