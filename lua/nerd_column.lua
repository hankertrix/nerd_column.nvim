-- The plugin to automatically disable the colour column when it is not needed

-- Types

-- Type aliases

-- The type of the colour column
---@alias NerdColumn.ColourColumn string|string[]|integer|integer[]

-- The type of the colour column when resolved
---@alias NerdColumn.ResolvedColourColumn integer|integer[]

-- The type of the custom colour column
---@alias NerdColumn.CustomColourColumn (fun(
---	buffer: integer,
---	window: integer,
---	file_type: string,
---): NerdColumn.ColourColumn)|table<string, NerdColumn.ColourColumn>

-- The type of the function for the colour column function when resolved
---@alias NerdColumn.ResolvedColourColumnFunction fun(
---	buffer: integer,
---	window: integer,
---	file_type: string,
---): NerdColumn.ResolvedColourColumn

-- The type of the custom colour column when resolved
---@alias NerdColumn.ResolvedCustomColourColumn
--- |NerdColumn.ResolvedColourColumnFunction
---	|table<string, NerdColumn.ResolvedColourColumn>

-- Type definitions

-- The type of the configuration
---@class (exact) NerdColumn.Config
---@field colour_column string|string[]|integer|integer[] The colour column
---@field custom_colour_column NerdColumn.CustomColourColumn
---@field scope NerdColumn.Scope The scope to act on
---@field respect_editor_config boolean Whether to respect the editor config
---@field maximum_line_count integer The maximum number of lines to check
---@field enabled boolean Whether the plugin is enabled or not
---@field disabled_file_types string[] The list of disabled file types

-- The type of the resolved configuration
---@class (exact) NerdColumn.ResolvedConfig: NerdColumn.Config
---@field colour_column NerdColumn.ResolvedColourColumn
---@field custom_colour_column NerdColumn.ResolvedCustomColourColumn

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
---@type NerdColumn.ResolvedConfig
M.default_config = {
	colour_column = 80,

	---@type table<string, integer>
	custom_colour_column = {},
	scope = M.Scope.File,
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

-- The configuration table
---@type NerdColumn.ResolvedConfig
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
---@param colour_column NerdColumn.ResolvedColourColumn
---@return NerdColumn.ResolvedColourColumn colour_column
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
	if not config.enabled then return disable_colour_column(current_window) end

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
	---@type NerdColumn.ResolvedColourColumn
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
	config.enabled = true

	-- Call the on change function
	on_change()
end

-- The function to disable the plugin
M.disable = function()
	--

	-- Disable the plugin
	config.enabled = false

	-- Disable the colour column
	disable_colour_column(vim.api.nvim_get_current_win())
end

-- The function to toggle the plugin
M.toggle = function()
	--

	-- Toggle the plugin
	config.enabled = not config.enabled

	-- Call the on change function
	on_change()
end

-- The function to set up the plugin
M.setup = function(user_config)
	--

	-- Initialise the user configuration to an empty table
	-- if it isn't given
	user_config = user_config or {}

	-- Get the default colour column
	local default_colour_column = M.default_config.colour_column

	-- Get the user's colour column
	---@type NerdColumn.ColourColumn
	local user_colour_column = user_config.colour_column
		or M.default_config.colour_column

	-- If the colour column is a table
	if type(user_colour_column) == "table" then
		--

		-- Iterate over all the items in the table and
		-- convert it to an integer
		for index, item in ipairs(user_colour_column) do
			user_colour_column[index] = tonumber(item)
		end

	-- Otherwise, if it is a string, convert the colour column to an integer
	elseif type(user_colour_column) == "string" then
		user_colour_column = tonumber(user_colour_column)
			or default_colour_column
	end

	-- Get the user's custom colour column
	---@type NerdColumn.CustomColourColumn
	local user_custom_colour_column = user_config.custom_colour_column or {}

	-- If the custom colour column is a function
	if type(user_custom_colour_column) == "function" then
		--

		-- Save the user's custom colour column function
		local user_custom_colour_column_func = user_custom_colour_column

		-- Change the output of the function to an integer,
		-- defaulting to the user's configured colour column if it fails
		---@type NerdColumn.ResolvedCustomColourColumn
		user_custom_colour_column = function(window, buffer, file_type)
			return tonumber(
				user_custom_colour_column_func(window, buffer, file_type)
			) or user_colour_column
		end

	-- Otherwise, if the custom colour column is a table
	elseif type(user_custom_colour_column) == "table" then
		--

		-- Iterate over the file type and the colour columns in the table
		for file_type, colour_column in pairs(user_custom_colour_column) do
			--

			-- If the colour column is a table,
			-- convert all the values into an integer
			if type(colour_column) == "table" then
				for index, item in ipairs(colour_column) do
					colour_column[index] = tonumber(item)
				end

			-- Otherwise, convert the colour column into an integer,
			-- defaulting to the user's configured colour column if it fails
			else
				user_custom_colour_column[file_type] = tonumber(colour_column)
					or user_colour_column
			end
		end
	end

	-- Set the user configuration to the resolved ones
	user_config.colour_column = user_colour_column
	user_config.custom_colour_column = user_custom_colour_column

	-- Merge the user's configuration with the default configuration
	config = vim.tbl_extend("force", config, user_config)

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
