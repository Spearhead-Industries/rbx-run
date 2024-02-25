local roblox = require("@lune/roblox") :: {[any]:any};
local run_util = require("../run_util");

return function(info)
    local bindings = {};
    
    roblox.implementMethod("RunService", "IsServer", function(instance)
        return info.context == "server";
    end);

    roblox.implementMethod("RunService", "IsClient", function(instance)
        return info.context == "client";
    end);

    roblox.implementMethod("RunService", "IsStudio", function(instance)
        return true;
    end);

    roblox.implementMethod("RunService", "IsEdit", function(instance)
        return false;
    end);

    roblox.implementMethod("RunService", "IsRunMode", function(instance)
        return true;
    end);

    roblox.implementMethod("RunService", "IsRunning", function(instance)
        return true;
    end);

    roblox.implementMethod("RunService", "BindToRenderStepped", function(instance, name, priority, f)
        local connection = info.con.Stepped:Connect(f);
        bindings[name] = connection;
        return;
    end);

    roblox.implementMethod("RunService", "UnbindFromRenderStep", function(instance, name, priority, f)
        if bindings[name] then
            bindings[name]:Disconnect();
        end
    end);

    roblox.implementProperty("RunService", "Heartbeat", run_util.provider(info.con.Stepped));
    roblox.implementProperty("RunService", "RenderStepped", run_util.provider(info.con.Stepped));
    roblox.implementProperty("RunService", "Stepped", run_util.provider(info.con.Stepped));
    roblox.implementProperty("RunService", "PostSimulation", run_util.provider(info.con.Stepped));
    roblox.implementProperty("RunService", "PreAnimation", run_util.provider(info.con.Stepped));
    roblox.implementProperty("RunService", "PreRender", run_util.provider(info.con.Stepped));
    roblox.implementProperty("RunService", "PreSimulation", run_util.provider(info.con.Stepped));
end