local roblox = require("@lune/roblox") :: {[any]:any};
local run_util = require("../run_util");

return function(info)
    roblox.implementMethod("LogService", "GetLogHistory", function() return info.logs end);
    roblox.implementProperty("LogService", "MessageOut", run_util.provider(info.con.LogOut));
end