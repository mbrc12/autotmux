# Autotmux

A simple [fish](https://fishshell.com) script to automatically setup tmux sessions with windows and panes, 
using a setup.json configuration file.

## Installation

Simply:

* Copy the `autotmux.fish` file to the directory where you wish to run the commands from (like your project root
directory)
* Install `jq`, `tmux` and a terminal emulator of your choice
* Author a `setup.json` file in the same directory
with the desired configuration (see below, or the sample configuration file `setup.json`).
* Run `./autotmux.fish` if you had set it to executable (using `chmod +x`), or
use `fish autotmux.fish`.

## Configuration

Configuration file format:
```json
{
    "term": "<your term command, with %s as placeholder for the command to run, like `kitty %`>",
    "name": "<session name>",
    "windows": [
        {
            "name": "<window name>",
            "panes": [
                "<command to run in pane 1>",
                "<command to run in pane 2>",
                ...
            ],
            "focus": "<optional, index of the pane to focus, 0-indexed. Default is 0>"
        },
        ...
    ]
}
```
