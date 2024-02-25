--------------------------------------------------------------------------------
-- 
--  main.lua - Spearhead-Industries/rbx-run
--
--  Entrypoint
--
--  plainenglish
--  Feburary 2024
--
--------------------------------------------------------------------------------

local VERSION = "1.0.0";

type roblox = {[any]: any};

local process = require("@lune/process");
local stdio = require("@lune/stdio");
local fs = require("@lune/fs");
local roblox = require("@lune/roblox") :: roblox;
local luau = require("@lune/luau");
local serde = require("@lune/serde");
local task = require("@lune/task");
local datetime = require("@lune/datetime");

local function empty_connection(connections: {any}?)
    return function()
        return {
            Connect = function(self, cb)
                if connections then
                    table.insert(connections, cb);
                end

                return {
                    Disconnect = function()
                        if connections then
                            table.remove(connections, table.find(connections, cb));
                        end
                    end
                }
            end
        }
    end
end

local function empty_array()
    return {};
end


--------------------------------------------------------------------------------
-- 
--  run
-- 
--------------------------------------------------------------------------------
local function run
    (datamodel: DataModel,
    context: "server"|"client",
    test_enabled: boolean?,
    no_loop: boolean?
)
    local new_env = table.clone(getfenv());

    setmetatable(new_env, {
        __index = function(self, idx: string) -- Resolve dynamic globals, i.e script.
            if idx == "script" then
                -- TODO: Resolve script. 
            end
        end
    });

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
        new_env.RBX_RUN_TEST = function() end
    end

    new_env._G.RBX_RUN_TEST = new_env.RBX_RUN_TEST;

    local require_cache = {};

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

    -- Why not use luau.load(obj.Source) you ask... because its a lot slower.
    new_env.require = function(obj: Script|LocalScript)
        --[[if typeof(obj) == "string" then
            return require(obj);
        elseif typeof(obj) == "Instance" then
            local path = env.instance_to_path(sourcemap, obj);

            if path then
                if path:sub(-5) == ".json" then
                    return serde.decode("json", fs.readFile(path));
                elseif path:sub(-5) == ".toml" then
                    return serde.decode("toml", fs.readFile(path));
                elseif path:sub(-4) == ".yml" or path:sub(-5) == ".yaml" then
                    return serde.decode("yaml", fs.readFile(path));
                else
                    return require(path);
                end 
            else
                return nil;
            end
        else
            error(`Cannot require type {typeof(obj)}.`);
        end]]

        if require_cache[obj] then
            return require_cache[obj];
        end

        local req_env = table.clone(new_env);
        req_env.script = obj;

        local f = luau.load(obj.Source);
        setfenv(f, req_env);
        local r = f();
        require_cache[obj] = r;
        return r;
    end

    local heartbeat_connections = {};

    do --// RunService //--
        roblox.implementMethod("RunService", "IsServer", function(instance)
            return context == "server";
        end);

        roblox.implementMethod("RunService", "IsClient", function(instance)
            return context == "client";
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
            table.insert(heartbeat_connections, f);
            return;
        end);

        roblox.implementProperty("RunService", "Heartbeat", empty_connection(heartbeat_connections));
        roblox.implementProperty("RunService", "RenderStepped", empty_connection(heartbeat_connections));
        roblox.implementProperty("RunService", "Stepped", empty_connection(heartbeat_connections));
    end

    do --// Misc //--
        local log_connections = {};

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

        roblox.implementMethod("LogService", "GetLogHistory", empty_array);
        roblox.implementProperty("LogService", "MessageOut", empty_connection(log_connections));
        roblox.implementMethod("Players", "GetPlayers", empty_array);
        roblox.implementProperty("Players", "PlayerAdded", empty_connection());
    
        roblox.implementMethod("HttpService", "JSONEncode",
            function(instance, tbl)
                return serde.encode("json", tbl);
            end
        );

        roblox.implementMethod("HttpService", "JSONDecode",
            function(instance, str)
                return serde.decode("json", str);
            end
        );

        roblox.implementMethod("HttpService", "GenerateGUID",
            function(instance, wrap_brackets)
                -- https://uuidgenerator.dev/uuid-in-lua
                local template = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
                return string.gsub(template, "[x]", function(c)
                    local v = math.random(0, 0xf);
                    return string.format("%x", v);
                end);
            end
        );
    end

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

    if not test_enabled and not no_loop then
        while task.wait(1/60) do
            for _, cb in pairs(heartbeat_connections) do
                cb();
            end
        end
    end

    process.exit(exit_code);
end


--------------------------------------------------------------------------------
-- 
--  main
-- 
--  Entrypoint function.
-- 
--------------------------------------------------------------------------------
function main(argc: number, argv: {string}): number
    local subcommand = argv[1];

    if subcommand == "run" or subcommand == "test" then
        local place = argv[2];
        if not place then
            stdio.write("Please specify a place file.");
            return 1;
        end

        if not fs.isFile(place) then
            stdio.write(`Place '{place}' does not exist.`);
            return 1;
        end

        local datamodel = roblox.deserializePlace(fs.readFile(place));
        
        run(
            datamodel,
            "server",
            subcommand == "test",
            table.find(argv, "--noloop") ~= nil
        );

    elseif subcommand == "version" or subcommand == "-v" then
        stdio.write(`Spearhead-Industries/rbx-run v{VERSION}`);

    elseif argc == 0 or subcommand == "help" then
        stdio.write(`{stdio.color("blue")}Spearhead-Industries{stdio.color("reset")}/{stdio.color("yellow")}rbx-run{stdio.color("reset")} v{VERSION}\n`);
        stdio.write(`Run Roblox games in the terminal.\n\n`);

        stdio.write(`@plainenglish {stdio.style("dim")}<plainenglish@spearhead.industries>{stdio.style("reset")}\n\n`);
   
        stdio.write(`{stdio.color("yellow")}USAGE:{stdio.color("reset")}\n`);
        stdio.write(`    rbx-run <SUBCOMMAND> [ARGUMENTS]\n\n`)
        
        stdio.write(`{stdio.color("yellow")}SUBCOMMANDS:{stdio.color("reset")}\n`);
        stdio.write(`    {stdio.color("green")}run    {stdio.color("reset")}Run the project.\n`);
        stdio.write(`    {stdio.color("green")}test   {stdio.color("reset")}Run the project with the test api.\n`);
        stdio.write(`    {stdio.color("green")}help   {stdio.color("reset")}Print this text.\n`);
    end
    
    return 0;
end

process.exit(main(#process.args, process.args));