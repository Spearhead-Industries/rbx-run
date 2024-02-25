local function provider(obj: any)
    return function()
        return obj;
    end
end

local function readonly()
    error("Readonly property.");
end

local function noop()

end

local function empty_connection(connections: {any}?)
    
end

local function empty_array()
    return {};
end

return {
    provider = provider,
    readonly = readonly,
    noop = noop,
    empty_connection = empty_connection,
    empty_array = empty_array
};