--
-- Created by IntelliJ IDEA.
-- User: Hashashiyyin
-- Date: 07/03/2020
-- Time: 20:17
-- To change this template use File | Settings | File Templates.
--
local cjson = require("cjson")

local _M = {}

local function kindResponse()
    return '{"error": "Ooops, we got an error..."}';
end

local function isEmpty(s)
    if (type(s) == "table") then
        local count = 0
        for _ in pairs(s) do
            count = count + 1
        end
        return count == 0;
    end
    return s == nil or s == '' or s == 'null' or s == cjson.null
end

function _M:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

_M.isEmpty = isEmpty
_M.kindResponse = kindResponse

return _M