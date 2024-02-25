local roblox = require("@lune/roblox") :: {[any]:any};
local serde = require("@lune/serde");
local net = require("@lune/net");

return function(info)
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

    roblox.implementMethod("HttpService", "GetAsync", function(instance, url: string, nocache: boolean?, headers: {[string]: string}?)
        return net.request({
            url = url,
            method = "GET",
            headers = headers
        });
    end);

    roblox.implementMethod("HttpService", "PostAsync", function(instance, url: string, data: string, type, compress, headers: {[string]: string}?)
        return net.request({
            url = url,
            method = "POST",
            headers = headers,
            data = data
        });
    end);
end