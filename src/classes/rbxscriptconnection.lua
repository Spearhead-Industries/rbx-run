local RBXScriptConnection = {};
RBXScriptConnection.__index = RBXScriptConnection;

function RBXScriptConnection.new(callback: (...any)->(), signal)
    local self = setmetatable({}, RBXScriptConnection);

    self._callback = callback;
    self._signal = signal;
    self.Connected = true;

    return self;
end

function RBXScriptConnection:Disconnect()
    self.Connected = false;
    self._callback = nil;
    
    if self._signal then
        local i = table.find(self._signal._connections, self);
        if i then
            table.remove(self._signal._connections, i);
        end
    end
end

function RBXScriptConnection:Fire(...)
    self._callback(...);
end

return RBXScriptConnection;
