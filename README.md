# Nerd Column

A rewrite of [smartcolumn.nvim] with
performance improvements, saner defaults, and more features.

It is a plugin to automatically disable the colour column
when it is not needed.

## Table of contents

- [Video Demonstration](#video-demonstration)
- [Requirements](#requirements)
- [Installation](#installation)
- [Configuration](#configuration)
- [Commands](#commands)

## Video demonstration

Below is a video demonstration of the plugin in action.

[video-demo]

## Requirements

- Neovim v0.10+

## Installation

### [lazy.nvim]

```lua
{
    "hankertrix/nerd_column.nvim",
    event = { "BufEnter" },
    opts = {}
}
```

### [pckr.nvim]

```lua
{
    "hankertrix/nerd_column.nvim",
    config = function() require("nerd_column").setup() end
}
```

### [packer.nvim]

```lua
use "hankertrix/nerd_column.nvim"
```

### [vim-plug]

```lua
Plug "hankertrix/nerd_column.nvim"
```

## Setup

Set up the plugin in your `init.lua`. This is not needed with [lazy.nvim]
and [pckr.nvim] if following the installation instructions above.

```lua
require("nerd_column").setup()
```

## Configuration

### `colour_column`

The `colour_column` can be an integer, a list of integers, a string,
or a list of strings.

For example:

```lua
---@type NerdColumn.ColourColumn
colour_column = 80
colour_column = "120"
colour_column = { 80, 120 }
colour_column = { "100", "140" }
```

### `custom_colour_column`

The `custom_colour_column` can either be table of file types mapped to
an integer, a string, a list of integers, or a list of strings.
It can also be a function that takes an integer representing the buffer ID,
an integer representing the window ID, and a string representing the file type,
and returns an integer or a string.

For example:

```lua
---@type NerdColumn.CustomColourColumn
custom_colour_column = {
    lua = { 80, 120 },
    markdown = "100",
}

custom_colour_column = function(buffer, window, file_type)
    return "120"
end
```

### `scope`

The `scope` option refers to the scope within which to check whether
the lines have exceeded the colour column configuration.
It can be either be `file`, `window`, or `line`.

- `file` refers to the entire file.
- `window` refers to the visible part of the current window.
- `line` refers to the current line.

For example:

```lua
---@type NerdColumn.Scope
scope = "window"
```

### `respect_editor_config`

The `respect_editor_config` option tells the plugin whether it should respect
the `max_line_length` configuration in the `.editorconfig` file.
It can be either `true` or `false`.

For example:

```lua
---@type boolean
respect_editor_config = true
```

Note that this option overrides the `custom_colour_column` configuration.

### `enabled`

The `enabled` option enables the plugin.

For example:

```lua
---@type boolean
enabled = true
```

### `maximum_line_count`

The `maximum_line_count` option sets the maximum number of lines the plugin
will check. When a file has more lines than the `maximum_line_count`, the
plugin will automatically change to scope to `window` so that Neovim doesn't
become unbearably slow and laggy to use.

For example:

```lua
---@type integer
maximum_line_count = 40000
```

### `disabled_file_types`

The `disabled_file_types` are the file types to disable the plugin for.
You can use `*` at the end of a file type to match a file type prefix,
like `Neogit*`.

For example:

```lua
---@type string[]
disabled_file_types = { "help", "checkhealth", "netrw", "qf" }
```

### Default configuration

The default configuration for the plugin is as follows:

```lua
---@type NerdColumn.ResolvedConfig
local default_config = {
    colour_column = 80,
    custom_colour_column = {},
    scope = "file",
    respect_editor_config = true,
    enabled = true,
    maximum_line_count = 40000,
    disabled_file_types = {
        "help",
        "checkhealth",
        "netrw",
        "qf",

        -- Plugin specific filetypes
        "packer",
        "dirvish",
        "dirbuf",
        "diff",
        "mason",
        "lazy",
        "lspinfo",
        "null-ls-info",
        "fugitive",
        "undotree",
        "aerial",
        "harpoon",
        "minifiles",
        "trouble",
        "spectre_panel",
        "noice",
        "fish",
        "zsh",
        "typr",
        "typrstats",
        "Trouble",
        "NvimTree",
        "WhichKey",
        "Telescope*",
        "Neogit*",
    },
}
```

You don't have to pass the configuration above to the `setup` function
if you want to use the default configuration.

If you would like to make use of the default configuration options
in your own configuration, like the `disabled_file_types` for example,
you can use the following snippet to access it.

```lua
require("nerd_column").default_config
```

## Commands

Nerd Column provides 3 commands:

- `NerdColumnEnable` to enable the plugin.
  It can also be accessed from Lua by using:

  ```lua
  require("nerd_column").enable()
  ```

- `NerdColumnDisable` to disable the plugin.
  It can also be accessed from Lua be using:

  ```lua
  require("nerd_column").disable()
  ```

- `NerdColumnToggle` to toggle the plugin.
  It can also be accessed from Lua be using:

  ```lua
  require("nerd_column").toggle()
  ```

## [Licence]

This plugin is licenced under the [GNU AGPL v3 licence][Licence].

[video-demo]: https://github.com/user-attachments/assets/65141c11-eee6-482b-8e09-b139cf48c831
[smartcolumn.nvim]: https://github.com/m4xshen/smartcolumn.nvim
[lazy.nvim]: https://github.com/folke/lazy.nvim
[packer.nvim]: https://github.com/wbthomason/packer.nvim
[pckr.nvim]: https://github.com/lewis6991/pckr.nvim
[vim-plug]: https://github.com/junegunn/vim-plug
[Licence]: LICENCE.txt
