local roblox = require("@lune/roblox") :: {[any]:any};
local stdio = require("@lune/stdio");
local run_util = require("../run_util");

return function(info)
    roblox.implementMethod("LogService", "GetLogHistory", function() return info.logs end);
    roblox.implementProperty("LogService", "MessageOut", run_util.provider(info.con.LogOut));
    roblox.implementMethod("LogService", "ClearOutput", function()
        table.clear(info.logs);
        stdio.write("\u{001b}[2J");
    end);
end