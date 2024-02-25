local roblox = require("@lune/roblox") :: {[any]:any};

return function(info)
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
        info.con.Stepped:Connect(f);
        return;
    end);

    roblox.implementProperty("RunService", "Heartbeat", info.con.Stepped);
    roblox.implementProperty("RunService", "RenderStepped", info.con.Stepped);
    roblox.implementProperty("RunService", "Stepped", info.con.Stepped);
end