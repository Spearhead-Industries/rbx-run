local roblox = require("@lune/roblox") :: {[any]:any};
local run_util = require("../run_util");

return function(info)
    roblox.implementMethod("Players", "GetPlayers", run_util.empty_array);
    roblox.implementProperty("Players", "PlayerAdded", run_util.empty_connection());
end