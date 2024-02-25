local process = require("@lune/process");
local fs = require("@lune/fs");

if not fs.isDir("./out") then
    fs.writeDir("./out");
end

-- lune calling lune... it really makes you think.
process.spawn("lune", {"build", "./src/main.lua", "-o", "./out/rbx-run"..if process.os == "windows" then ".exe" else ""}, {
    stdio = "forward"
});

if process.os == "windows" then
    process.spawn("powershell", {"Compress-Archive", "./out/rbx-run.exe", `./out/rbx-run-{process.os}-{process.arch}.zip`, "-Force"}, {
        stdio = "forward"
    });
else
    process.spawn("zip", {"-r", "./out/rbx-run.exe", `./out/rbx-run-{process.os}-{process.arch}.zip`}, {    -- sudo apt-get install zip
        stdio = "forward"
    });
end

print(process.arch)