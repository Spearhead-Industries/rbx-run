<div align="center">

# rbx-run

</div>

A CLI tool to run Roblox place files.

This tool provides a partial implementation of the Roblox API using [Lune](https://github.com/lune-org/lune)'s `roblox` builtin library. Run and test Roblox games for quick analysis or for use in CI/CD pipelines.

**Maintainer:** @plainenglishh

> [!WARNING]  
> If rbx-run builds the project on your behalf, such as if no path was provided, and the command doesn't run to completion a temporary rbxl file will linger at `<temp>/rbx-run/` `(win=%Temp%, unix=/tmp)`. Users with stringent security requirements should take note of this and either ensure the command runs to completion (--noloop) or delete this file manually. 

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
lpm build --mkarchive

# The executable should now be available in ./out/
```

## Usage

### Running

```bash
rbx-run run [PATH] <OPTIONS>
```

This will implement the Roblox API and execute the scripts in a Server run context.
You can disable the game loop (RenderStepped, Stepped, etc) by adding the `--noloop` flag.

If 'PATH' is absent, it will attempt to call `rojo build` in the current working directory to create a temporary file to run from.

### Tests

```bash
rbx-run test [PATH]
```

You can use rbx-run to perform rudimentary unit testing.

The test command generally has the same functionality as `run`, except;

- A test function is injected.
- The game loop is never started.

A function titled `RBX_RUN_TEST` is added to the global environment and accepts two arguments; (1) a string to identify the test, and (2) a function to run.

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

Running the `rbx-run test` command gives us

```raw
[ FAIL ] test_that_fails - Epic Fail
[ PASS ] test_that_succeeds 
```

and exits with a code of 1 to indicate the failed tests.

> [!NOTE]  
> The test command does not start the game loop, RenderStepped, Stepped and Heartbeat will never fire in test mode.

## Limitations

### Subject to change

- As of v1.1.0, rbx-run can only run as the server.
- Most of the Roblox API is unimplemented.
- Networking (RemoteFunction, RemoteEvent, Replication, etc) is currently not implemented.

### Non-goals

- Physics Simulation
- Complete 1:1 feature parity with Roblox APIs.

## Contributing

Pull requests for both bug-fixes and feature implementations are welcome.

## API Coverage

|Icon|Meaning|
|---|---|
|✅|Supported|
|⚠️|Supported, but with caveats|
|❌|Will not support|

### Complete

- HttpService
  - ✅ JSONEncode
  - ✅ JSONDecode
  - ✅ GenerateGUID
  - ⚠️ GetSecret - Checks the environment variables
  - ✅ UrlEncode
  - ⚠️ GetAsync - Cache is ignored.
  - ⚠️ PostAsync - Compress and Type are ignored for now, use Headers to set contenttype.
  - ⚠️ RequestAsync - Compress is ignored for now.
  - ⚠️ HttpEnabled - Assumed to be true.

- LogService
  - ✅ ClearOutput - Uses ANSI escape sequence to clear terminal.
  - ✅ GetLogHistory
  - ✅ MessageOut

- RunService
  - ✅ RenderStepped
  - ✅ Stepped - Same Loop as RenderStepped
  - ✅ Heartbeat - Same Loop as RenderStepped
  - ⚠️ BindToRenderStepped - Same Loop as RenderStepped, priority is ignored.
  - ✅ PostSimulation - Same Loop as RenderStepped
  - ✅ PreAnimation - Same Loop as RenderStepped
  - ✅ PreRender - Same Loop as RenderStepped
  - ✅ PreSimulation - Same Loop as RenderStepped
  - ✅ IsServer
  - ✅ IsClient
  - ✅ IsStudio - Always true
  - ✅ IsEdit
  - ⚠️ IsRunMode - Always true, will change when Client mode is added.
  - ✅ IsRunning
  - ✅ UnbindFromRenderStep

### In Progress

- Players
  - ⚠️ GetPlayers - Always empty, will change when Client mode is added.
  - ⚠️ PlayerAdded - Never Fires, will change when Client mode is added.
  
