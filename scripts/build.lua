local process = require("@lune/process");
local fs = require("@lune/fs");

if not fs.isDir("./out") then
    fs.writeDir("./out");
end

-- lune calling lune... it really makes you think.
process.spawn("lune", {"build", "./src/main.lua", "-o", "./out/rbx-run"..if process.os == "windows" then ".exe" else ""}, {
    stdio = "forward"
});