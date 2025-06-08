return {
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
