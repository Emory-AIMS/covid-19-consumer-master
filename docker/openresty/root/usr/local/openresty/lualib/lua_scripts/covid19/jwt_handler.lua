local jwt = require("resty.jwt")
local os = require('os')
local httpFunc = require("http_functions")
local cjson = require("cjson")
local _M = {}

local jwt_secret = "my_secret_key";

local function generateToken(context)
    context["iat"] = os.time();
    context["exp"] = os.time() + (60 * 10);
    return jwt:sign(
            jwt_secret,
            {
                header = { typ = "JWT", alg = "HS256" },
                payload = context
            }
    )
end

local function verify(jwt_token)
    local jwt_obj = jwt:verify(jwt_secret, jwt_token)
    if not jwt_obj.verified then
        ngx.status = ngx.HTTP_UNAUTHORIZED
        ngx.say('{"error": "Invalid Token. ' .. jwt_obj.reason .. '"}');
        error(ngx.exit(ngx.HTTP_UNAUTHORIZED));
    end
    return jwt_obj.payload;
    --{
    --    "signature": "QKC_3PCFP0-w3QeV_AEVkq-FYpXgryukcmNoVZult54",
    --    "reason": "'exp' claim expired at Sat, 21 Mar 2020 15:52:37 GMT",
    --    "valid": true,
    --    "raw_header": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9",
    --    "payload": {
    --        "iat": 1584805357,
    --        "exp": 1584805957,
    --        "id": "2"
    --    },
    --    "header": {
    --        "alg": "HS256",
    --        "typ": "JWT"
    --    },
    --    "verified": false,
    --    "raw_payload": "eyJleHAiOjE1ODQ4MDU5NTcsImlkIjoiMiIsImlhdCI6MTU4NDgwNTM1N30"
    --}
end

local function checkAuthorization()

    local auth_ok, auth_jwt = pcall(httpFunc.readTokenFromAuth);
    local jwt_obj;

    if not auth_ok then
        error(auth_jwt);
    else
        jwt_obj = verify(auth_jwt)
    end

    return jwt_obj;
end

function _M:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

_M.checkAuthorization = checkAuthorization;
_M.generateToken = generateToken;
_M.verifyToken = verify;

return _M;