local roblox = require("@lune/roblox") :: {[any]:any};
local luau = require("@lune/luau");
local stdio = require("@lune/stdio");
local process = require("@lune/process");
local serde = require("@lune/serde");
local task = require("@lune/task");
local datetime = require("@lune/datetime");

local RBXScriptSignal = require("../classes/rbxscriptsignal");

local run_util = require("./run_util");


local function run(datamodel: DataModel, context: "server"|"client", test_enabled: boolean?, no_loop: boolean?)
    local new_env = table.clone(getfenv());

    new_env._G.RBX_RUN_TEST_ENABLED = test_enabled or false;

    new_env.game = datamodel;
    new_env.workspace = datamodel:GetService("Workspace");
    new_env.Workspace = new_env.workspace;

    new_env.NumberRange = roblox.NumberRange;
    new_env.Color3 = roblox.Color3;
    new_env.BrickColor = roblox.BrickColor;
    new_env.Vector2 = roblox.Vector2;
    new_env.Vector3 = roblox.Vector3;
    new_env.Vector2int16 = roblox.Vector2int16;
    new_env.Vector3int16 = roblox.Vector3int16;
    new_env.UDim = roblox.UDim;
    new_env.UDim2 = roblox.UDim2;
    new_env.Enum = roblox.Enum;
    new_env.task = task;
    new_env.Instance = roblox.Instance;

    local exit_code = 0;

    if test_enabled then
        new_env.print = function() end; -- suppress print.
        new_env.RBX_RUN_TEST = function(label: string, case: ()->())
            local success, err = pcall(case);

            if success then
                stdio.write(`[ {stdio.color("green")}PASS{stdio.color("reset")} ] `);
            else
                stdio.write(`[ {stdio.color("red")}FAIL{stdio.color("reset")} ] `);
                exit_code = 1;
            end

            stdio.write(label);

            err = tostring(err):match("%[string \".+\"%]:%d+: (.+)");

            if not success then
                stdio.write(" - "..err);
            end

            stdio.write("\n");
        end
    else
        new_env.RBX_RUN_TEST = run_util.noop;
    end

    new_env._G.RBX_RUN_TEST = new_env.RBX_RUN_TEST;

    local require_cache = {};

    new_env.require = function(obj: Script|LocalScript)
        if require_cache[obj] then
            return require_cache[obj];
        end

        local req_env = table.clone(new_env);
        req_env.script = obj;

        local func = luau.load(obj.Source);
        setfenv(func, req_env);

        local result = func();
        require_cache[obj] = result;

        return result;
    end

    local function datetime_wrapper(obj)
        return setmetatable({}, {
            __index = function(self, idx)
                if idx == "ToIsoDate" then
                    return function()
                        return obj:toIsoDate();
                    end
                else
                    return obj[idx];                        
                end
            end
        });
    end

    new_env.DateTime = {
        now = function()
            return datetime_wrapper(datetime.now());
        end,
        fromUnixTimestamp = function(t)
            return datetime_wrapper(datetime.fromUnixTimestamp(t))
        end
    };

    roblox.implementMethod("Instance", "WaitForChild",
        function(instance, a)
            if instance:FindFirstChild(a) then
                return instance:FindFirstChild(a);
            else
                print(`Infinite Yield Possible for '{a}'.`);
                task.wait(math.huge);
                return;
            end
        end
    );

    local logs = {};

    local info = {
        con = {
            Stepped = RBXScriptSignal.new(),
            LogOut = RBXScriptSignal.new()
        },
        context = context,
        logs = logs
    };

    new_env.print = function(...)
        local msg = "";
        for _, v in pairs({...}) do
            msg ..= tostring(v) .. " ";
        end

        info.con.LogOut:Fire(msg, roblox.Enum.MessageType.MessageOutput);
        
        print(...);
    end

    new_env.warn = function(...)
        local msg = "";
        for _, v in pairs({...}) do
            msg ..= tostring(v) .. " ";
        end

        info.con.LogOut:Fire(msg, roblox.Enum.MessageType.MessageWarning);
        
        warn(...);
    end

    info.con.LogOut:Connect(function(msg, msgtype)
        table.insert(logs, {
            message = msg,
            messageType = msgtype,
            timestamp = os.time()
        });
    end);

    --// Services //--

    (require("./services/runservice"))(info);

    (require("./services/players"))(info);
    
    (require("./services/httpservice"))(info);
    
    (require("./services/logservice"))(info);


    --// Start //--

    if context == "server" then
        for _, v in pairs(datamodel:GetDescendants()) do
            if v.ClassName == "Script" and (v.RunContext == roblox.Enum.RunContext.Server or v.RunContext == roblox.Enum.RunContext.Legacy) then
                new_env.require(v);
            end
        end
    else
        for _, v in pairs(datamodel:GetDescendants()) do
            if v.ClassName == "LocalScript" or (v.ClassName == "Script" and v.RunContext == roblox.Enum.RunContext.Client) then
                new_env.require(v);
            end
        end
    end


    --// Game Loop //--
    
    if not test_enabled and not no_loop then
        while task.wait(1/60) do
            info.con.Stepped:Fire();
        end
    end

    return exit_code;
end

return run;