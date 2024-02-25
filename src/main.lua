--------------------------------------------------------------------------------
-- 
--  main.lua - Spearhead-Industries/rbx-run
--
--  The entrypoint file.
--
--  plainenglish
--  Feburary 2024
--
--------------------------------------------------------------------------------

-- Why a single script? i dont wanna have to setup darklua to bundle it.
-- maybe ill do it later

local VERSION = "1.0.0";

type roblox = {[any]: any};

local process = require("@lune/process");
local stdio = require("@lune/stdio");
local fs = require("@lune/fs");
local roblox = require("@lune/roblox") :: roblox;


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
        local run = require("./run/init");

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