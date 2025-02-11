-- The plugin to automatically disable the colour column when it is not needed

-- Types

-- Type aliases

-- The type of the colour column
---@alias NerdColumn.ColourColumn integer|integer[]

-- The type of the function for the colour column function
---@alias NerdColumn.ColourColumnFunction fun(
---	buffer: integer,
---	window: integer,
---	file_type: string,
---): NerdColumn.ColourColumn

-- The type of the custom colour column
---@alias NerdColumn.CustomColourColumn
--- |NerdColumn.ColourColumnFunction
---	|table<string, NerdColumn.ColourColumn>

-- The type of the transform colour column function
---@alias NerdColumn.TransformColourColumn fun(
---	colour_column: NerdColumn.ColourColumn,
---): NerdColumn.ColourColumn

-- Type definitions

-- The type of the configuration
---@class (exact) NerdColumn.Config
---@field colour_column NerdColumn.ColourColumn The colour column
---@field custom_colour_column NerdColumn.CustomColourColumn
---@field scope NerdColumn.Scope The scope to act on
---@field respect_editor_config boolean Whether to respect the editor config
---@field enabled boolean Whether the plugin is enabled or not
---@field maximum_line_count integer The maximum number of lines to check
---@field transform_colour_column NerdColumn.TransformColourColumn
---@field disabled_file_types string[] The list of disabled file types

-- The module table
---@class NerdColumn
local M = {}

-- The enum for the scope
---@enum NerdColumn.Scope
M.Scope = {
	File = "file",
	Window = "window",
	Line = "line",
}

-- The default configuration
M.default_config = {
	colour_column = 80,

	---@type table<string, integer>
	custom_colour_column = {},
	scope = M.Scope.File,
	respect_editor_config = true,
	enabled = true,
	maximum_line_count = 40000,
	transform_colour_column = function(colour_column) return colour_column end,
	disabled_file_types = {
		"help",
		"checkhealth",
		"netrw",
		"qf",

		-- Plugin specific file types
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
		"snacks_terminal",
		"Tybr",
		"TybrStats",
		"Trouble",
		"NvimTree",
		"WhichKey",
		"Telescope*",
		"Neogit*",
	},
}

-- The configuration table
---@type NerdColumn.Config
local config = M.default_config

-- The function to check whether the lines in the scope
-- has exceeded the colour columns
---@param window integer The ID of the window in the buffer
---@param buffer integer The ID of the buffer to check
---@return boolean exceeded Whether the colour column has been exceeded
local function has_exceeded_colour_column(buffer, window, minimum_colour_column)
	--

	-- Initialise the scope
	local scope = config.scope

	-- Get the line count of the buffer
	local line_count = vim.api.nvim_buf_line_count(buffer)

	-- If the line count of the buffer exceeds the maximum line count,
	-- and the scope is the file scope,
	-- set the scope to the window scope
	if line_count > config.maximum_line_count and scope == M.Scope.File then
		scope = M.Scope.Window
	end

	-- The list of lines
	---@type string[]
	local lines

	-- Get the line if the scope is a line
	if scope == "line" then
		--

		-- Get the current line
		local current_line = vim.fn.line(".", window)

		-- Get the line range for the current line
		lines = vim.api.nvim_buf_get_lines(
			buffer,
			current_line - 1,
			current_line,
			true
		)

	-- Otherwise, if the scope is the window
	elseif scope == "window" then
		--

		-- Get the line range for the current window
		-- being shown to the user
		lines = vim.api.nvim_buf_get_lines(
			buffer,
			vim.fn.line("w0", window) - 1,
			vim.fn.line("w$", window),
			true
		)

	-- Otherwise, the scope is a file,
	-- so get all the lines in the file
	else
		lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, true)
	end

	-- Iterate over the lines
	for _, line in ipairs(lines) do
		--

		-- Get the display width of the line
		local display_width = vim.fn.strdisplaywidth(line, 0)

		-- If the display width exceeds the minimum colour column,
		-- return true
		if display_width > minimum_colour_column then return true end
	end

	-- Otherwise, return false
	return false
end

-- Function to get the colour column from the editor config file
---@param buffer integer The ID of the buffer to get the editor config for
---@param colour_column NerdColumn.ColourColumn
---@return NerdColumn.ColourColumn colour_column
local function get_editor_config_colour_column(buffer, colour_column)
	return vim.b[buffer].editorconfig
			and vim.b[buffer].editorconfig.max_line_length ~= "off"
			and tonumber(vim.b[buffer].editorconfig.max_line_length)
		or colour_column
end

-- Function to match the file type
---@param given_file_type string The file type to match
---@param list_of_file_types string[] The list of file types to check against
---@return boolean matched Whether the file type is in the list of file types
local function match_file_type(given_file_type, list_of_file_types)
	--

	-- Iterate over the list of file types
	for _, file_type in ipairs(list_of_file_types) do
		--

		-- Create the Lua pattern to match the file type
		local pattern = string.format(
			"^%s%s",
			file_type,
			file_type:sub(-1) == "*" and "" or "$"
		)

		-- If the given file type matches the pattern,
		-- then return true
		if given_file_type:match(pattern) then return true end

		-- Otherwise, continue the loop
	end

	-- Return false if nothing matches
	return false
end

-- The function to get whether the plugin is enabled or not
---@return boolean nerd_column_is_enabled Whether the plugin is enabled or not
local function nerd_column_is_enabled()
	--

	-- Get the value of buffer local variable for
	-- whether the plugin is enabled
	local plugin_enabled = vim.b.nerd_column_enabled

	-- If the buffer local variable isn't set,
	-- then get the value of the global variable
	if plugin_enabled == nil then plugin_enabled = vim.g.nerd_column_enabled end

	-- Return whether the plugin is enabled or not
	return plugin_enabled
end

-- The function to set the plugin state
---@param state boolean
---@return nil
local function set_nerd_column_state(state)
	--

	-- Set the plugin state in both the global variable
	-- and the buffer local variable
	vim.g.nerd_column_enabled = state
	vim.b.nerd_column_enabled = state
end

-- The function to disable the colour column
---@param window integer The ID of the window in the buffer
---@return nil
local function disable_colour_column(window) vim.wo[window].colorcolumn = "" end

-- The function to call every time the buffer is updated
local function on_change()
	--

	-- Get the current window
	local current_window = vim.api.nvim_get_current_win()

	-- If the plugin is disabled, disable the colour column
	-- and exit the function
	if not nerd_column_is_enabled() then
		return disable_colour_column(current_window)
	end

	-- Get the current buffer
	local current_buffer = vim.api.nvim_win_get_buf(current_window)

	-- Get the file type of the buffer
	local file_type = vim.api.nvim_get_option_value("filetype", {
		buf = current_buffer,
	})

	-- If the file type of the buffer is empty,
	-- or is in the disabled file types,
	-- disable the colour column and exit the function
	if
		file_type == ""
		or match_file_type(file_type, config.disabled_file_types)
	then
		return disable_colour_column(current_window)
	end

	-- Initialise the colour columns
	---@type NerdColumn.ColourColumn
	local colour_columns

	-- If the custom colour column is a function,
	-- call it to get the colour column
	if type(config.custom_colour_column) == "function" then
		colour_columns = config.custom_colour_column(
			current_buffer,
			current_window,
			file_type
		)

	-- Otherwise, the custom colour column is a table
	else
		colour_columns = config.custom_colour_column[file_type]
			or config.colour_column
	end

	-- If reading from the editor config file is wanted,
	-- set the colour column to the one from the editor config file
	if config.respect_editor_config then
		colour_columns =
			get_editor_config_colour_column(current_buffer, colour_columns)
	end

	-- Initialise the minimum colour column
	local minimum_colour_column

	-- If the colour columns is a table
	if type(colour_columns) == "table" then
		--

		-- Initialise the minimum colour column to the first
		-- item in the table
		minimum_colour_column = colour_columns[1]

		-- Iterate over the colour columns in the table
		for _, colour_column in ipairs(colour_columns) do
			--

			-- Get the minimum of the current minimum colour column
			-- and the current colour column
			minimum_colour_column =
				math.min(minimum_colour_column, colour_column)
		end

	-- Otherwise, set the minimum colour column
	-- to the colour column obtained
	else
		minimum_colour_column = colour_columns
	end

	-- Get whether the line length has exceeded the colour column
	local exceeded = has_exceeded_colour_column(
		current_buffer,
		current_window,
		minimum_colour_column
	)

	-- If the line length has exceeded the colour column
	if exceeded then
		--

		-- Transform the colour columns with the function to transform them
		colour_columns = config.transform_colour_column(colour_columns)

		-- If the colour column is a table,
		-- iterate over all the columns,
		-- convert them to a string
		-- and join them with a comma,
		-- and set the colour column to the result
		if type(colour_columns) == "table" then
			vim.wo[current_window].colorcolumn = table.concat(
				vim.tbl_map(
					function(column) return tostring(column) end,
					colour_columns
				),
				","
			)

		-- Otherwise, set the colour column to given colour column as a string
		else
			vim.wo[current_window].colorcolumn = tostring(colour_columns)
		end

	-- Otherwise, set the colour column to an empty string
	else
		vim.wo[current_window].colorcolumn = ""
	end
end

-- The function to enable the plugin
---@type fun(): nil
M.enable = function()
	--

	-- Enable the plugin
	set_nerd_column_state(true)

	-- Call the on change function
	on_change()
end

-- The function to disable the plugin
M.disable = function()
	--

	-- Disable the plugin
	set_nerd_column_state(false)

	-- Disable the colour column
	disable_colour_column(vim.api.nvim_get_current_win())
end

-- The function to toggle the plugin
M.toggle = function()
	--

	-- Get the current state of the plugin
	local is_enabled = nerd_column_is_enabled()

	-- Toggle the plugin
	set_nerd_column_state(not is_enabled)

	-- Call the on change function
	on_change()
end

-- The function to set up the plugin
M.setup = function(user_config)
	--

	-- Initialise the user configuration to an empty table
	-- if it isn't given
	user_config = user_config or {}

	-- Merge the user's configuration with the default configuration
	config = vim.tbl_extend("force", config, user_config)

	-- If the plugin is enabled, set the vim global option
	-- for the plugin to enabled
	if config.enabled then vim.g.nerd_column_enabled = true end

	-- Create the auto command to set the colour column
	vim.api.nvim_create_autocmd(
		{ "BufEnter", "CursorMoved", "CursorMovedI", "WinScrolled" },
		{
			group = vim.api.nvim_create_augroup("NerdColumn", { clear = true }),
			callback = on_change,
		}
	)
end

-- Return the module table
return M
