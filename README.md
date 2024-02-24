<div align="center">

# rbx-run

Running Roblox games in the terminal.
</div>

-----

## About

This tool provides a partial implementation of the Roblox API for running place files using [Lune](https://github.com/lune-org/lune).

-----

## Usage

To run a Roblox place file, simply use the following command;

```bash
rbx-run run [PATH]
```

This will implement the Roblox API and execute the scripts in a Server run context.

-----

## Limitations

At the moment, the following limitations apply;

- rbx-run can only run as in the Server RunContext.
- Most of the Roblox API is unimplemeneted.

These limitations will reduce as time goes on. This tool was adapted from the Terahertz Game Framework CLI, as such it only implements methods the base THz framework uses.

-----
