-- init.lua
local core = require("my_ts_diagnostics.core")

local function setup_commands()
	-- User command to run the tsc and load into Trouble
	vim.api.nvim_create_user_command("TroubleTsc", function()
		core.run_diagnostics()
	end, { desc = "Run tsc and display diagnostics in Trouble" })

	-- Autocmd which removes the tsc namespace when a buffer is opened
	vim.api.nvim_create_autocmd({ "BufWinEnter", "BufReadPost" }, {
		pattern = "*",
		callback = function(args)
			local bufnr = args.buf
			local namespace = vim.api.nvim_create_namespace("troubleTsc")
			vim.diagnostic.reset(namespace, bufnr)
		end,
	})
end

return {
	setup = setup_commands,
}
