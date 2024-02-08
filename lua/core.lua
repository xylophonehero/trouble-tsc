-- Function to parse a single line of tsc output into a diagnostic
local function parseTscLine(line)
	local pattern = "(.-)%((%d+),(%d+)%)%:%s+error%s+(TS%d+)%:%s+(.*)"
	local file, lineNum, colNum, errorCode, message = line:match(pattern)
	if file and lineNum and colNum then
		return {
			bufnr = vim.fn.bufadd(file),
			lnum = tonumber(lineNum) - 1, -- Lua is 1-indexed, but lines in diagnostics are 0-indexed
			col = tonumber(colNum) - 1,
			message = message,
			severity = vim.diagnostic.severity.ERROR,
			source = errorCode,
		}
	end
end

-- Function to run tsc and get diagnostics for the entire project
local function getTscDiagnostics()
	local cmd = "tsc --noEmit --project tsconfig.json"
	local result = vim.fn.systemlist(cmd)

	-- if vim.v.shell_error > 0 then
	--   print("tsc command failed. Please check your TypeScript configuration.")
	--   return
	-- end

	local diagnostics = {}
	for _, line in ipairs(result) do
		local diag = parseTscLine(line)
		if diag then
			if not diagnostics[diag.bufnr] then
				diagnostics[diag.bufnr] = {}
			end
			table.insert(diagnostics[diag.bufnr], diag)
		end
	end

	return diagnostics
end

-- Function to set the parsed diagnostics in Neovim
local function setDiagnostics(diagnostics)
	local namespace = vim.api.nvim_create_namespace("troubleTsc")
	for bufnr, diags in pairs(diagnostics) do
		vim.diagnostic.set(namespace, bufnr, diags)
	end
end

-- Main execution function
local function runDiagnostics()
	local diagnostics = getTscDiagnostics()
	if diagnostics then
		setDiagnostics(diagnostics)
	end
end

return {
	run_diagnostics = runDiagnostics,
}
