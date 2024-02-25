local Secret = {};
Secret.__index = Secret;
Secret.ClassName = "Secret";

function Secret.new(value: string)
    local self = setmetatable({}, Secret);

    self._value = value;
end

function Secret:AddPrefix(prefix: string)
    self._value = prefix .. self._value;
end

function Secret:AddSuffix(suffix: string)
    self._value = self._value .. suffix;
end

function Secret:GetValue(): string
    return self._value;
end

function Secret.get(secret)
    if typeof(secret) == "string" then
        return secret;
    else
        return secret._value;
    end
end

function Secret.headers(headers: {[string]: string})
    for i, v in pairs(headers) do
        headers[i] = Secret.get(v);
    end
    return headers;
end

return Secret;