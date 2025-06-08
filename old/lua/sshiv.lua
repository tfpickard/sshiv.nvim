-- lua/sshiv.lua
local M = {}

-- Default configuration
local config = {
	-- Default SSH options
	ssh_options = {
		"-o",
		"ConnectTimeout=5",
		"-o",
		"StrictHostKeyChecking=no",
		"-o",
		"UserKnownHostsFile=/dev/null",
		"-o",
		"LogLevel=ERROR",
	},
	-- Default output position: 'cursor', 'end', 'beginning'
	output_position = "cursor",
	-- Whether to add a separator line before output
	add_separator = true,
	-- Separator text
	separator_text = "--- Sshiv Output ---",
	-- Timeout in milliseconds
	timeout = 30000,
	-- Default user (nil means use current user)
	default_user = nil,
	-- Whether to show command in output
	show_command = true,
	-- Command prefix format
	command_prefix_format = "$ %s@%s: %s",
}

-- Load presets from external file
local presets_module = require("sshiv-presets")

-- Store recent hosts for completion
local recent_hosts = {}
local recent_commands = {}

-- Preset-related functions
function M.get_preset(id)
	return presets_module.get_preset(id)
end

function M.list_presets()
	return presets_module.get_all_presets()
end

function M.get_presets_by_category(category)
	return presets_module.get_presets_by_category(category)
end

function M.get_categories()
	return presets_module.get_categories()
end

-- FZF integration for preset selection
function M.fzf_presets(host)
	if not host or host == "" then
		host = vim.fn.input("Sshiv Host: ", recent_hosts[1] or "")
		if host == "" then
			return
		end
	end

	-- Check if fzf is available
	if vim.fn.executable("fzf") == 0 then
		vim.notify("fzf not found. Please install fzf for preset selection.", vim.log.levels.ERROR)
		return
	end

	-- Prepare preset list for fzf
	local preset_lines = {}
	local all_presets = presets_module.get_all_presets()
	for _, preset in ipairs(all_presets) do
		local line = string.format("%04d | %-12s | %-50s | %s", preset.id, preset.category, preset.cmd, preset.desc)
		table.insert(preset_lines, line)
	end

	-- Create temporary file for fzf input
	local temp_file = vim.fn.tempname()
	local file = io.open(temp_file, "w")
	if not file then
		vim.notify("Could not create temporary file for fzf", vim.log.levels.ERROR)
		return
	end

	for _, line in ipairs(preset_lines) do
		file:write(line .. "\n")
	end
	file:close()

	-- Run fzf
	local fzf_cmd = string.format(
		"fzf --prompt='Sshiv Preset> ' --header='Select command preset for %s (250 available)' --delimiter='|' --preview='echo {4}' --preview-window=up:3 < %s",
		host,
		temp_file
	)

	local handle = io.popen(fzf_cmd)
	if not handle then
		vim.notify("Could not start fzf", vim.log.levels.ERROR)
		os.remove(temp_file)
		return
	end

	local result = handle:read("*a")
	handle:close()
	os.remove(temp_file)

	-- Process result
	if result and result ~= "" then
		result = result:gsub("%s+$", "") -- trim whitespace
		local preset_id = tonumber(result:match("^(%d+)"))
		if preset_id then
			local preset = M.get_preset(preset_id)
			if preset then
				M.exec(host, preset.cmd)
			else
				vim.notify("Invalid preset ID: " .. preset_id, vim.log.levels.ERROR)
			end
		end
	end
end

-- FZF for preset with stdin
function M.fzf_presets_stdin(host, content_source)
	if not host or host == "" then
		host = vim.fn.input("Sshiv Host: ", recent_hosts[1] or "")
		if host == "" then
			return
		end
	end

	local content = detect_content_source(content_source or "buffer")
	if content == "" then
		vim.notify("No content available for stdin", vim.log.levels.ERROR)
		return
	end

	-- Check if fzf is available
	if vim.fn.executable("fzf") == 0 then
		vim.notify("fzf not found. Please install fzf for preset selection.", vim.log.levels.ERROR)
		return
	end

	-- Prepare preset list for fzf (filter for commands that make sense with stdin)
	local preset_lines = {}
	local all_presets = presets_module.get_all_presets()
	local stdin_friendly_commands = {
		"tee",
		"cat",
		"grep",
		"sed",
		"awk",
		"sort",
		"uniq",
		"wc",
		"head",
		"tail",
		"base64",
		"openssl",
		"gpg",
		"ssh-keygen",
		"mysql",
		"psql",
		"redis-cli",
	}

	for _, preset in ipairs(all_presets) do
		local is_stdin_friendly = false
		for _, cmd_pattern in ipairs(stdin_friendly_commands) do
			if preset.cmd:find(cmd_pattern) then
				is_stdin_friendly = true
				break
			end
		end

		-- Always include user presets (ID >= 1000)
		if is_stdin_friendly or preset.id >= 1000 then
			local line = string.format("%04d | %-12s | %-50s | %s", preset.id, preset.category, preset.cmd, preset.desc)
			table.insert(preset_lines, line)
		end
	end

	if #preset_lines == 0 then
		vim.notify("No stdin-compatible presets found", vim.log.levels.WARN)
		return
	end

	-- Create temporary file for fzf input
	local temp_file = vim.fn.tempname()
	local file = io.open(temp_file, "w")
	if not file then
		vim.notify("Could not create temporary file for fzf", vim.log.levels.ERROR)
		return
	end

	for _, line in ipairs(preset_lines) do
		file:write(line .. "\n")
	end
	file:close()

	-- Run fzf
	local content_preview = content:sub(1, 200):gsub("\n", "\\n")
	local fzf_cmd = string.format(
		"fzf --prompt='Sshiv Stdin> ' --header='Select preset for %s (stdin: %s...)' --delimiter='|' --preview='echo {4}' --preview-window=up:3 < %s",
		host,
		content_preview,
		temp_file
	)

	local handle = io.popen(fzf_cmd)
	if not handle then
		vim.notify("Could not start fzf", vim.log.levels.ERROR)
		os.remove(temp_file)
		return
	end

	local result = handle:read("*a")
	handle:close()
	os.remove(temp_file)

	-- Process result
	if result and result ~= "" then
		result = result:gsub("%s+$", "") -- trim whitespace
		local preset_id = tonumber(result:match("^(%d+)"))
		if preset_id then
			local preset = M.get_preset(preset_id)
			if preset then
				M.exec_with_stdin(host, preset.cmd, content)
			else
				vim.notify("Invalid preset ID: " .. preset_id, vim.log.levels.ERROR)
			end
		end
	end
end

-- Execute preset by number
function M.exec_preset(host, preset_id)
	if not host or host == "" then
		vim.notify("Host is required", vim.log.levels.ERROR)
		return
	end

	local preset = M.get_preset(preset_id)
	if not preset then
		vim.notify("Invalid preset ID: " .. preset_id, vim.log.levels.ERROR)
		return
	end

	M.exec(host, preset.cmd)
end

-- Show preset list
function M.show_presets()
	local lines = { "Sshiv Command Presets (250 total):", "" }

	local all_presets = presets_module.get_all_presets()
	local current_category = ""
	for _, preset in ipairs(all_presets) do
		if preset.category ~= current_category then
			current_category = preset.category
			table.insert(lines, "=== " .. current_category .. " ===")
		end
		table.insert(lines, string.format("%4d. %-50s - %s", preset.id, preset.cmd, preset.desc))
	end

	table.insert(lines, "")
	table.insert(lines, "Usage:")
	table.insert(lines, "  :SshivPreset <host> <id>         - Execute preset by number")
	table.insert(lines, "  :SshivPresetFzf [host]           - Select preset with fzf")
	table.insert(lines, "  :SshivStdin <host> <cmd>         - Execute with buffer as stdin")
	table.insert(lines, "  :SshivStdinFzf [host]            - Select stdin preset with fzf")
	table.insert(lines, "  :SshivPresetList                 - Show this list")
	table.insert(lines, "")
	table.insert(lines, "User presets start at ID 1000")

	-- Create a new buffer with the preset list
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	vim.api.nvim_buf_set_option(buf, "filetype", "text")

	-- Open in a new window
	vim.cmd("split")
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, buf)
	vim.api.nvim_buf_set_name(buf, "Sshiv Command Presets")
end

-- Setup function
function M.setup(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})

	-- Add user presets if provided
	if opts and opts.user_presets then
		presets_module.add_user_presets(opts.user_presets)
	end

	-- Create user commands
	vim.api.nvim_create_user_command("Sshiv", function(args)
		M.exec_interactive(args.args)
	end, {
		nargs = "*",
		desc = "Execute Sshiv command interactively",
		complete = function(arglead, cmdline, cursorpos)
			return M.complete_hosts(arglead)
		end,
	})

	vim.api.nvim_create_user_command("SshivHost", function(args)
		local parts = vim.split(args.args, " ", { plain = true })
		if #parts < 2 then
			vim.notify("Usage: SshivHost <host> <command>", vim.log.levels.ERROR)
			return
		end
		local host = parts[1]
		local command = table.concat(vim.list_slice(parts, 2), " ")
		M.exec(host, command)
	end, {
		nargs = "+",
		desc = "Execute Sshiv command on specific host",
		complete = function(arglead, cmdline, cursorpos)
			local parts = vim.split(cmdline, " ", { plain = true })
			if #parts <= 2 then
				return M.complete_hosts(arglead)
			else
				return M.complete_commands(arglead)
			end
		end,
	})

	vim.api.nvim_create_user_command("SshivLast", function()
		M.exec_last()
	end, {
		desc = "Re-execute last Sshiv command",
	})

	-- Stdin commands
	vim.api.nvim_create_user_command("SshivStdin", function(args)
		M.exec_stdin_interactive(args.args)
	end, {
		nargs = "*",
		desc = "Execute Sshiv command with stdin (interactive)",
		complete = function(arglead, cmdline, cursorpos)
			local parts = vim.split(cmdline, " ", { plain = true })
			if #parts <= 2 then
				return M.complete_hosts(arglead)
			else
				return M.complete_commands(arglead)
			end
		end,
	})

	vim.api.nvim_create_user_command("SshivStdinBuffer", function(args)
		local parts = vim.split(args.args, " ", { plain = true })
		if #parts < 2 then
			vim.notify("Usage: SshivStdinBuffer <host> <command>", vim.log.levels.ERROR)
			return
		end
		local host = parts[1]
		local command = table.concat(vim.list_slice(parts, 2), " ")
		local content = get_buffer_content()
		M.exec_with_stdin(host, command, content)
	end, {
		nargs = "+",
		desc = "Execute Sshiv command with current buffer as stdin",
		complete = function(arglead, cmdline, cursorpos)
			local parts = vim.split(cmdline, " ", { plain = true })
			if #parts <= 2 then
				return M.complete_hosts(arglead)
			else
				return M.complete_commands(arglead)
			end
		end,
	})

	vim.api.nvim_create_user_command("SshivStdinVisual", function(args)
		local parts = vim.split(args.args, " ", { plain = true })
		if #parts < 2 then
			vim.notify("Usage: SshivStdinVisual <host> <command>", vim.log.levels.ERROR)
			return
		end
		local host = parts[1]
		local command = table.concat(vim.list_slice(parts, 2), " ")
		local content = get_visual_selection()
		M.exec_with_stdin(host, command, content)
	end, {
		nargs = "+",
		desc = "Execute Sshiv command with visual selection as stdin",
		range = true,
		complete = function(arglead, cmdline, cursorpos)
			local parts = vim.split(cmdline, " ", { plain = true })
			if #parts <= 2 then
				return M.complete_hosts(arglead)
			else
				return M.complete_commands(arglead)
			end
		end,
	})

	vim.api.nvim_create_user_command("SshivStdinFzf", function(args)
		M.fzf_presets_stdin(args.args, "buffer")
	end, {
		nargs = "?",
		desc = "Select Sshiv stdin preset with fzf (uses buffer content)",
		complete = function(arglead, cmdline, cursorpos)
			return M.complete_hosts(arglead)
		end,
	})

	-- Preset commands
	vim.api.nvim_create_user_command("SshivPreset", function(args)
		local parts = vim.split(args.args, " ", { plain = true })
		if #parts < 2 then
			vim.notify("Usage: SshivPreset <host> <preset_id>", vim.log.levels.ERROR)
			return
		end
		local host = parts[1]
		local preset_id = tonumber(parts[2])
		if not preset_id then
			vim.notify("Preset ID must be a number", vim.log.levels.ERROR)
			return
		end
		M.exec_preset(host, preset_id)
	end, {
		nargs = "+",
		desc = "Execute Sshiv preset command",
		complete = function(arglead, cmdline, cursorpos)
			local parts = vim.split(cmdline, " ", { plain = true })
			if #parts <= 2 then
				return M.complete_hosts(arglead)
			else
				-- Complete preset IDs
				local matches = {}
				local all_presets = presets_module.get_all_presets()
				for _, preset in ipairs(all_presets) do
					local id_str = tostring(preset.id)
					if id_str:match("^" .. vim.pesc(arglead)) then
						table.insert(matches, id_str .. " # " .. preset.desc)
					end
				end
				return matches
			end
		end,
	})

	vim.api.nvim_create_user_command("SshivPresetFzf", function(args)
		M.fzf_presets(args.args)
	end, {
		nargs = "?",
		desc = "Select Sshiv preset with fzf",
		complete = function(arglead, cmdline, cursorpos)
			return M.complete_hosts(arglead)
		end,
	})

	vim.api.nvim_create_user_command("SshivPresetList", function()
		M.show_presets()
	end, {
		desc = "Show list of Sshiv command presets",
	})
end

-- Text extraction functions for stdin support
local function get_buffer_content()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	return table.concat(lines, "\n")
end

local function get_visual_selection()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")

	local start_line = start_pos[2] - 1
	local start_col = start_pos[3] - 1
	local end_line = end_pos[2] - 1
	local end_col = end_pos[3]

	local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line + 1, false)

	if #lines == 0 then
		return ""
	elseif #lines == 1 then
		return string.sub(lines[1], start_col + 1, end_col)
	else
		lines[1] = string.sub(lines[1], start_col + 1)
		lines[#lines] = string.sub(lines[#lines], 1, end_col)
		return table.concat(lines, "\n")
	end
end

local function get_text_object(obj)
	-- Save current position
	local saved_pos = vim.fn.getpos(".")

	-- Execute the text object selection
	vim.cmd("normal! v" .. obj)

	-- Get the selection
	local content = get_visual_selection()

	-- Restore position
	vim.fn.setpos(".", saved_pos)

	return content
end

-- Content source type detection
local function detect_content_source(source)
	if source == "buffer" then
		return get_buffer_content()
	elseif source == "visual" then
		return get_visual_selection()
	elseif source:match("^textobj:") then
		local obj = source:gsub("^textobj:", "")
		return get_text_object(obj)
	else
		return source -- Treat as literal text
	end
end
local function add_recent_host(host)
	-- Remove if already exists
	for i, h in ipairs(recent_hosts) do
		if h == host then
			table.remove(recent_hosts, i)
			break
		end
	end
	-- Add to beginning
	table.insert(recent_hosts, 1, host)
	-- Keep only last 10
	if #recent_hosts > 10 then
		table.remove(recent_hosts)
	end
end

-- Add command to recent list
local function add_recent_command(command)
	-- Remove if already exists
	for i, cmd in ipairs(recent_commands) do
		if cmd == command then
			table.remove(recent_commands, i)
			break
		end
	end
	-- Add to beginning
	table.insert(recent_commands, 1, command)
	-- Keep only last 20
	if #recent_commands > 20 then
		table.remove(recent_commands)
	end
end

-- Completion function for hosts
function M.complete_hosts(arglead)
	local matches = {}

	-- Add recent hosts
	for _, host in ipairs(recent_hosts) do
		if host:match("^" .. vim.pesc(arglead)) then
			table.insert(matches, host)
		end
	end

	-- Add common patterns
	local patterns = {
		"localhost",
		"127.0.0.1",
		"192.168.1.",
		"10.0.0.",
	}

	for _, pattern in ipairs(patterns) do
		if pattern:match("^" .. vim.pesc(arglead)) then
			table.insert(matches, pattern)
		end
	end

	return matches
end

-- Completion function for commands
function M.complete_commands(arglead)
	local matches = {}

	-- Add recent commands
	for _, cmd in ipairs(recent_commands) do
		if cmd:match("^" .. vim.pesc(arglead)) then
			table.insert(matches, cmd)
		end
	end

	-- Add preset commands
	local all_presets = presets_module.get_all_presets()
	for _, preset in ipairs(all_presets) do
		if preset.cmd:match("^" .. vim.pesc(arglead)) then
			table.insert(matches, preset.cmd .. " # " .. preset.desc)
		end
	end

	-- Add common commands
	local common = {
		"ls -la",
		"pwd",
		"whoami",
		"uptime",
		"df -h",
		"free -h",
		"ps aux",
		"systemctl status",
		"docker ps",
		"git status",
		"cat",
		"tail -f",
		"grep -r",
	}

	for _, cmd in ipairs(common) do
		if cmd:match("^" .. vim.pesc(arglead)) then
			table.insert(matches, cmd)
		end
	end

	return matches
end

-- Get output position in buffer
local function get_output_position()
	local pos = config.output_position
	local line, col

	if pos == "cursor" then
		local cursor = vim.api.nvim_win_get_cursor(0)
		line = cursor[1]
		col = cursor[2]
	elseif pos == "end" then
		line = vim.api.nvim_buf_line_count(0)
		col = 0
	elseif pos == "beginning" then
		line = 1
		col = 0
	else
		-- Default to cursor
		local cursor = vim.api.nvim_win_get_cursor(0)
		line = cursor[1]
		col = cursor[2]
	end

	return line, col
end

-- Insert output into buffer
local function insert_output(output, host, command)
	local lines = {}

	-- Add separator if configured
	if config.add_separator then
		table.insert(lines, config.separator_text)
	end

	-- Add command info if configured
	if config.show_command then
		local user = config.default_user or vim.fn.system("whoami"):gsub("%s+", "")
		local cmd_line = string.format(config.command_prefix_format, user, host, command)
		table.insert(lines, cmd_line)
	end

	-- Add output lines
	for line in output:gmatch("[^\r\n]+") do
		table.insert(lines, line)
	end

	-- Add empty line at end
	table.insert(lines, "")

	-- Get position and insert
	local line_num, col = get_output_position()

	-- Insert lines
	vim.api.nvim_buf_set_lines(0, line_num, line_num, false, lines)

	-- Move cursor to end of inserted content
	vim.api.nvim_win_set_cursor(0, { line_num + #lines, 0 })
end

-- Build SSH command
local function build_ssh_command(host, command)
	local ssh_cmd = { "ssh" }

	-- Add SSH options
	for _, opt in ipairs(config.ssh_options) do
		table.insert(ssh_cmd, opt)
	end

	-- Add user@host if user specified
	if config.default_user then
		table.insert(ssh_cmd, config.default_user .. "@" .. host)
	else
		table.insert(ssh_cmd, host)
	end

	-- Add command
	table.insert(ssh_cmd, command)

	return ssh_cmd
end

-- Store last command for re-execution
local last_host = nil
local last_command = nil

-- Execute SSH command with stdin support
function M.exec_with_stdin(host, command, stdin_content)
	if not host or host == "" then
		vim.notify("Host is required", vim.log.levels.ERROR)
		return
	end

	if not command or command == "" then
		vim.notify("Command is required", vim.log.levels.ERROR)
		return
	end

	if not stdin_content or stdin_content == "" then
		vim.notify("Stdin content is required", vim.log.levels.ERROR)
		return
	end

	-- Store for last command
	last_host = host
	last_command = command

	-- Add to recent lists
	add_recent_host(host)
	add_recent_command(command)

	-- Build SSH command
	local ssh_cmd = build_ssh_command(host, command)

	-- Show what we're executing
	local stdin_preview = stdin_content:sub(1, 100)
	if #stdin_content > 100 then
		stdin_preview = stdin_preview .. "..."
	end
	vim.notify(string.format("Executing with stdin: %s", table.concat(ssh_cmd, " ")), vim.log.levels.INFO)
	vim.notify(string.format("Stdin content: %s", stdin_preview), vim.log.levels.INFO)

	-- Execute command with stdin
	local job = vim.system(ssh_cmd, {
		timeout = config.timeout,
		text = true,
		stdin = stdin_content,
	}, function(result)
		vim.schedule(function()
			if result.code == 0 then
				local output = result.stdout or ""
				insert_output(output, host, command .. " (with stdin)")
				vim.notify(string.format("Sshiv command with stdin completed on %s", host), vim.log.levels.INFO)
			else
				local error_msg = result.stderr or "Unknown error"
				vim.notify(string.format("Sshiv command with stdin failed: %s", error_msg), vim.log.levels.ERROR)

				-- Still insert error output if available
				if result.stderr then
					insert_output("ERROR: " .. result.stderr, host, command .. " (with stdin)")
				end
			end
		end)
	end)

	return job
end

-- Interactive stdin execution
function M.exec_stdin_interactive(args)
	local parts = args and vim.split(args, " ", { plain = true }) or {}
	local host = parts[1]
	local command = table.concat(vim.list_slice(parts, 2), " ")

	-- Get host if not provided
	if not host or host == "" then
		host = vim.fn.input("Sshiv Host: ", recent_hosts[1] or "")
		if host == "" then
			return
		end
	end

	-- Get command if not provided
	if not command or command == "" then
		command = vim.fn.input("Command: ", recent_commands[1] or "")
		if command == "" then
			return
		end
	end

	-- Ask for content source
	local source_options = {
		"1. Current buffer",
		"2. Visual selection",
		"3. Text object (specify)",
		"4. Type content manually",
	}

	vim.ui.select(source_options, {
		prompt = "Select stdin content source:",
	}, function(choice)
		if not choice then
			return
		end

		local content = ""

		if choice:match("^1%.") then
			content = get_buffer_content()
		elseif choice:match("^2%.") then
			content = get_visual_selection()
		elseif choice:match("^3%.") then
			local obj = vim.fn.input("Text object (e.g., 'ip' for inner paragraph): ")
			if obj ~= "" then
				content = get_text_object(obj)
			end
		elseif choice:match("^4%.") then
			content = vim.fn.input("Enter content: ")
		end

		if content ~= "" then
			M.exec_with_stdin(host, command, content)
		end
	end)
end

-- Execute preset with stdin
function M.exec_preset_with_stdin(host, preset_id, stdin_content)
	local preset = presets_module.get_preset(preset_id)
	if not preset then
		vim.notify("Invalid preset ID: " .. preset_id, vim.log.levels.ERROR)
		return
	end

	M.exec_with_stdin(host, preset.cmd, stdin_content)
end
function M.exec(host, command)
	if not host or host == "" then
		vim.notify("Host is required", vim.log.levels.ERROR)
		return
	end

	if not command or command == "" then
		vim.notify("Command is required", vim.log.levels.ERROR)
		return
	end

	-- Store for last command
	last_host = host
	last_command = command

	-- Add to recent lists
	add_recent_host(host)
	add_recent_command(command)

	-- Build SSH command
	local ssh_cmd = build_ssh_command(host, command)

	-- Show what we're executing
	vim.notify(string.format("Executing: %s", table.concat(ssh_cmd, " ")), vim.log.levels.INFO)

	-- Execute command
	local job = vim.system(ssh_cmd, {
		timeout = config.timeout,
		text = true,
	}, function(result)
		vim.schedule(function()
			if result.code == 0 then
				local output = result.stdout or ""
				insert_output(output, host, command)
				vim.notify(string.format("Sshiv command completed on %s", host), vim.log.levels.INFO)
			else
				local error_msg = result.stderr or "Unknown error"
				vim.notify(string.format("Sshiv command failed: %s", error_msg), vim.log.levels.ERROR)

				-- Still insert error output if available
				if result.stderr then
					insert_output("ERROR: " .. result.stderr, host, command)
				end
			end
		end)
	end)

	return job
end

-- Interactive execution with input prompts
function M.exec_interactive(args)
	local host, command

	if args and args ~= "" then
		local parts = vim.split(args, " ", { plain = true })
		if #parts >= 1 then
			host = parts[1]
			if #parts >= 2 then
				command = table.concat(vim.list_slice(parts, 2), " ")
			end
		end
	end

	-- Get host if not provided
	if not host then
		host = vim.fn.input("Sshiv Host: ", recent_hosts[1] or "")
		if host == "" then
			return
		end
	end

	-- Get command if not provided
	if not command then
		command = vim.fn.input("Command: ", recent_commands[1] or "")
		if command == "" then
			return
		end
	end

	M.exec(host, command)
end

-- Re-execute last command
function M.exec_last()
	if not last_host or not last_command then
		vim.notify("No previous Sshiv command to repeat", vim.log.levels.WARN)
		return
	end

	M.exec(last_host, last_command)
end

-- Execute command and return result (for API use)
function M.exec_sync(host, command, timeout)
	if not host or host == "" then
		return nil, "Host is required"
	end

	if not command or command == "" then
		return nil, "Command is required"
	end

	local ssh_cmd = build_ssh_command(host, command)
	local result = vim.system(ssh_cmd, {
		timeout = timeout or config.timeout,
		text = true,
	}):wait()

	if result.code == 0 then
		return result.stdout, nil
	else
		return nil, result.stderr or "Unknown error"
	end
end

-- Get configuration
function M.get_config()
	return vim.deepcopy(config)
end

-- Update configuration
function M.update_config(new_config)
	config = vim.tbl_deep_extend("force", config, new_config)
end

return M
