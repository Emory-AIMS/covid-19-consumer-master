local jwt_handler = require("jwt_handler")

local auth_status, auth_jwt = pcall( jwt_handler.checkAuthorization );
if not auth_status then
    return auth_jwt;
end

