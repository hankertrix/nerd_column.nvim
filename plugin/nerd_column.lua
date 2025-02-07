-- The commands for the plugin

-- The command to enable the plugin
vim.api.nvim_create_user_command(
	"NerdColumnEnable",
	function() require("nerd_column").enable() end,
	{}
)

-- The command to disable the plugin
vim.api.nvim_create_user_command(
	"NerdColumnDisable",
	function() require("nerd_column").disable() end,
	{}
)

-- The command to toggle the plugin
vim.api.nvim_create_user_command(
	"NerdColumnToggle",
	function() require("nerd_column").toggle() end,
	{}
)
