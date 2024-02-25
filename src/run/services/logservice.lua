local roblox = require("@lune/roblox") :: {[any]:any};

return function(info)
    roblox.implementMethod("LogService", "GetLogHistory", function() return info.logs end);
    roblox.implementProperty("LogService", "MessageOut", info.con.LogOut);
end