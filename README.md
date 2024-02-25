<div align="center">

# rbx-run

</div>

A CLI tool to run Roblox place files.

This tool provides a partial implementation of the Roblox API using [Lune](https://github.com/lune-org/lune)'s `roblox` builtin library. Run and test Roblox games for quick analysis or for use in CI/CD pipelines.

**Maintainer:** @plainenglishh

## Installation

### Aftman (Recommended)

You can install rbx-run with the [Aftman](https://github.com/LPGhatguy/aftman) toolchain manager:

```bash
# Project Only
aftman init
aftman add Spearhead-Industries/rbx-run
aftman install

# Globally
aftman add --global Spearhead-Industries/rbx-run
```

### From Source

You can install from source with the following steps (assumes you have aftman installed):

```bash
# Download and CD into the repo
git clone https://github.com/Spearhead-Industries/rbx-run.git
cd rbx-run

# Install the toolchain
aftman install

# Run the build script
lune run ./scripts/build.lua

# The executable should now be available in ./out/
```

## Usage

### Running

```bash
rbx-run run [PATH]
```

This will implement the Roblox API and execute the scripts in a Server run context.
You can disable the game loop (RenderStepped, Stepped, etc) by adding the `--noloop` flag.

### Tests

```bash
rbx-run test [PATH]
```

You can use rbx-run to perform rudimentary unit testing. When you call `rbx-run test`, an RBX_RUN_TEST function is injected into the global environment.

RBX_RUN_TEST accepts two arguments; (1) a string to identify the test, and (2) a function to run.

A test is deemed to pass if the function executes successfully, and is deemed to fail if it throws an error.

An example test is as follows:

```lua
RBX_RUN_TEST("test_that_fails", function()
    assert(false, "Epic Fail");
end);

RBX_RUN_TEST("test_that_succeeds", function()
    assert(true, "Epic Win");
end);
```

Running the `rbx-run test` command gives us:

```raw
[ FAIL ] test_that_fails - Epic Fail
[ PASS ] test_that_succeeds 
```

and exits with a code of 1 to indicate the failed tests.

> [!NOTE]  
> The test command does not initiate the game loop, RenderStepped, Stepped and Heartbeat will never fire in test mode.

## Limitations

At the moment, the following limitations apply;

- rbx-run can only run as in the Server RunContext.
- Most of the Roblox API is unimplemeneted.

These limitations will reduce as time goes on. This tool was adapted from the Terahertz Game Framework CLI, as such it only implements methods the base THz framework uses.

-----
