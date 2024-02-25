local task = require("@lune/task");

local RBXScriptConnection = require("./rbxscriptconnection");

local RBXScriptSignal = {};
RBXScriptSignal.__index = RBXScriptSignal;

function RBXScriptSignal.new()
    local self = setmetatable({}, RBXScriptSignal);

    self._connections = {};

    return self;
end

function RBXScriptSignal:Connect(callback: (...any)->())
    local connection = RBXScriptConnection.new(callback, self);
    table.insert(self._connections, connection);
    return connection;
end

function RBXScriptSignal:Once(callback: (...any)->())
    local connection;
    connection = self:Connect(function(...)
        connection:Disconnect();
        callback(...);
    end);
end

function RBXScriptSignal:Wait()
    local waiting = true;

    self:Once(function()
        waiting = false;
    end);

    repeat task.wait() until not waiting;
end

function RBXScriptSignal:Fire(...)
    for _, connection in pairs(self._connections) do
        if connection.Connected then
            connection:Fire(...);
        end
    end
end

RBXScriptSignal.ConnectParallel = RBXScriptSignal.Connect;

return RBXScriptSignal;