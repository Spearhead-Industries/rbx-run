<div align="center">

# rbx-run

Running Roblox games in the terminal.
</div>

-----

## About

This tool provides a partial implementation of the Roblox API for running place files using [Lune](https://github.com/lune-org/lune).

-----

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

-----

## Limitations

At the moment, the following limitations apply;

- rbx-run can only run as in the Server RunContext.
- Most of the Roblox API is unimplemeneted.

These limitations will reduce as time goes on. This tool was adapted from the Terahertz Game Framework CLI, as such it only implements methods the base THz framework uses.

-----
