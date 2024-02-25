local roblox = require("@lune/roblox") :: {[any]:any};
local serde = require("@lune/serde");
local net = require("@lune/net");
local process = require("@lune/process");

local run_util = require("../run_util");

local Secret = require("../../classes/secret");

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

    roblox.implementMethod("HttpService", "UrlEncode", function(instance, str)
        return net.urlEncode(str);
    end);

    roblox.implementMethod("HttpService", "GetSecret", function(self, key: string)
        local value = process.env[key];
        return Secret.new(value);
    end);

    roblox.implementMethod("HttpService", "GenerateGUID",
        function(instance, wrap_brackets)
            -- https://uuidgenerator.dev/uuid-in-lua
            local template = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
            local start = if wrap_brackets then "{" else "";
            local stop = if wrap_brackets then "}" else "";
            return start .. string.gsub(template, "[x]", function(c)
                local v = math.random(0, 0xf);
                return string.format("%x", v);
            end) .. stop;
        end
    );

    roblox.implementMethod("HttpService", "GetAsync", function(instance, url: string, nocache: boolean?, headers: {[string]: string}?)
        return net.request({
            url = Secret.get(url),
            method = "GET",
            headers = headers
        });
    end);

    roblox.implementMethod("HttpService", "PostAsync", function(instance, url: string, data: string, type, compress, headers: {[string]: string}?)
        return net.request({
            url = Secret.get(url),
            method = "POST",
            headers = Secret.headers(headers or {}),
            data = data
        });
    end);

    roblox.implementMethod("HttpService", "RequestAsync", function(instance, data)
        return net.request({
            url = Secret.get(data.Url),
            method = data.Method,
            headers = Secret.headers(data.Headers or {}),
            data = data.Body
        });
    end);

    roblox.implementProperty("HttpService", "HttpEnabled", run_util.provider(true));
end