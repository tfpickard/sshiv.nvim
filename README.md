# Sshiv.nvim - SSH IV for Neovim

**Inject SSH directly into your veins if buffers were veins.** 💉
... aka _SSH In Vim_

A Neovim plugin for executing SSH commands and capturing output directly into your buffer. Like an IV drip for SSH commands - if files were veins.

## Why "Sshiv"?

- **SSH IV** - Like an intravenous injection of SSH commands directly into file
- **SSH in Vim** - Because that's exactly what it does
- **Fast & Direct** - No context switching, just pur

## Quick Start

Install with lazy.nvim:
lua{
"tfpickard/sshiv.nvim",
config = function()
require("sshiv").setup({})
end,
}

Restart Neovim and run :Lazy sync
Test the installation:
vim:Sshiv localhost whoami

Explore presets:
vim:SshivPresetList

Use fzf for quick access:
vim<leader>spe SSH goodness flowing straight into your workflow

## Features

**🔌 Core SSH Functionality:**

- Execute arbitrary SSH commands from within Neovim
- Capture output directly into your current buffer
- Support for both interactive and direct command execution
- Smart completion for hosts and commands with history

**💉 Stdin Support:**

- Send buffer content as stdin to remote commands
- Send visual selections as stdin
- Text object support for precise content selection
- Perfect for configuration management and data transfer

**⚡ 250 Command Presets:**

- Ordered by likelihood of needing output in buffer: configs, keys, logs, security audits
- User presets starting at ID 1000
- FZF integration for fuzzy searching

**🎯 Advanced Features:**

- Synchronous and asynchronous execution
- Configurable SSH options and timeouts
- Error handling with stderr capture
- Lua API for programmatic use

## Configuration

The plugin can be configured in your `setup()` call:

```lua
require("sshiv").setup({
    -- SSH connection options (passed to ssh command)
    ssh_options = {
        "-o", "ConnectTimeout=10",
        "-o", "StrictHostKeyChecking=no",
        "-o", "UserKnownHostsFile=/dev/null",
        "-o", "LogLevel=ERROR"
    },

    -- Where to insert output
    output_position = 'cursor', -- 'cursor', 'end', 'beginning'

    -- Visual separator
    add_separator = true,
    separator_text = "=== SSH Output ===",

    -- Command execution
    timeout = 30000, -- milliseconds
    default_user = nil, -- nil = current user, or specify username

    -- Output formatting
    show_command = true,
    command_prefix_format = "$ %s@%s: %s", -- user@host: command
})
```

## Usage

### Core Commands

- `:Sshiv` - Interactive execution (prompts for host and command)
- `:Sshiv <host>` - Prompts for command on specified host
- `:Sshiv <host> <command>` - Execute command on host immediately
- `:SshivHost <host> <command>` - Direct execution (alternative syntax)
- `:SshivLast` - Re-execute the last command

### Stdin Commands (NEW!)

- `:SshivStdin` - Interactive stdin execution (prompts for everything)
- `:SshivStdinBuffer <host> <cmd>` - Send current buffer as stdin
- `:SshivStdinVisual <host> <cmd>` - Send visual selection as stdin
- `:SshivStdinFzf [host]` - Select stdin-compatible preset with fzf

### Preset Commands

- `:SshivPresetList` - Show all 250 available command presets
- `:SshivPreset <host> <id>` - Execute preset by number (1-250, 1000+)
- `:SshivPresetFzf [host]` - Select preset using fzf (fuzzy finder)

### Key Mappings (from config)

**Basic Commands:**

- `<leader>ss` - Interactive execution
- `<leader>sr` - Repeat last command
- `<leader>sl` - Execute command on localhost
- `<leader>sp` - Select preset with fzf (prompts for host)
- `<leader>sP` - Select preset with fzf for specific host
- `<leader>s?` - Show preset list

**Stdin Commands:**

- `<leader>sb` - Send buffer as stdin (interactive)
- `<leader>sv` - Send visual selection as stdin (visual mode)
- `<leader>sB` - Select stdin preset with fzf (uses buffer)
- `<leader>sk` - Quick append to authorized_keys

**Quick Presets:**

- `<leader>si` - System info (uptime)
- `<leader>sT` - Top processes

### Examples

```vim
" Interactive - prompts for host and command
:Sshiv

" Specify host, prompt for command
:Sshiv myserver

" Execute specific command
:Sshiv myserver ls -la /var/log

" Direct syntax
:SshivHost web01 docker ps

" Repeat last command
:SshivLast

" Execute preset #1 (SSH authorized keys) on server
:SshivPreset myserver 1

" Use fzf to select preset
:SshivPresetFzf myserver

" Send buffer content to remote file
:SshivStdinBuffer myserver "tee /tmp/config.txt"

" Send visual selection to remote command
:'<,'>SshivStdinVisual myserver "base64 -d > /tmp/decoded"

" Show all presets
:SshivPresetList
```

## Command Presets

The plugin includes **250 carefully curated command presets** ordered by likelihood of needing output in a buffer. Perfect for DevSecOps workflows where you need to edit or reference command output.

### Most Likely Used (1-25) - Configuration & Keys

- `1`: `cat ~/.ssh/authorized_keys` - SSH authorized keys (most likely to edit)
- `2`: `cat ~/.ssh/config` - SSH client config
- `3`: `cat /etc/ssh/sshd_config` - SSH daemon config
- `10`: `cat /etc/hosts` - Hosts file
- `13`: `git config --list` - All git configuration
- `17`: `crontab -l` - User crontab

### High Likelihood (26-75) - Security & Application Configs

- `26`: `openssl x509 -in /etc/ssl/certs/*.pem -text` - SSL certificate details
- `30`: `docker inspect $(docker ps -q)` - All container details
- `40`: `git log --oneline -20` - Recent commit history
- `47`: `cat /etc/NetworkManager/system-connections/*` - Network connections

### Medium-High (76-125) - System Information

- `76`: `uname -a` - System information
- `83`: `df -h` - Disk usage
- `86`: `ip addr show` - Network interfaces
- `96`: `docker ps -a` - All containers

### Medium (126-175) - Development & Tools

- `126`: `which python python3 pip` - Python paths
- `135`: `cat .gitlab-ci.yml` - GitLab CI config
- `150`: `cat /etc/mongod.conf` - MongoDB config

### Lower Priority (176-250) - Monitoring & Status

- `176`: `top -b -n 1 | head -20` - Current processes
- `182`: `ping -c 4 8.8.8.8` - Internet connectivity
- `200`: `rkhunter --check` - Rootkit hunter

### User Presets (1000+)

Your custom presets start at ID 1000 and can be defined in the plugin configuration.

## Stdin Functionality

Sshiv's stdin support lets you send buffer content, visual selections, or text objects as input to remote commands - perfect for configuration management!

### Content Sources

1. **Buffer Content** - Send entire current buffer
2. **Visual Selection** - Send only selected text
3. **Text Objects** - Send specific text objects (paragraphs, etc.)
4. **Manual Input** - Type content directly

### Common Stdin Use Cases

```vim
" Append SSH key to authorized_keys
:SshivStdinBuffer server1 "tee -a ~/.ssh/authorized_keys"

" Apply Kubernetes manifest
:SshivStdinBuffer k8s-master "kubectl apply -f -"

" Update nginx configuration
:SshivStdinVisual web01 "sudo tee /etc/nginx/sites-available/default"

" Execute SQL commands
:SshivStdinBuffer db01 "mysql -u root -p mydb"

" Import GPG key
:SshivStdinBuffer server1 "gpg --import"

" Decode and extract archive
:SshivStdinBuffer server1 "base64 -d | tar -xzf -"
```

### Stdin-Compatible Presets

Use `:SshivStdinFzf` to see only presets that work well with stdin:

- `1002`: `tee -a ~/.ssh/authorized_keys` - Append to authorized_keys
- `1004`: `kubectl apply -f -` - Apply Kubernetes manifest
- `1005`: `mysql -u root -p < /dev/stdin` - Execute SQL
- `1007`: `gpg --import` - Import GPG key

## Features

### Smart Completion

- **Host completion**: Remembers recently used hosts
- **Command completion**: Suggests recent commands and common patterns
- **Tab completion**: Works with both hosts and commands

### Output Management

- **Flexible positioning**: Insert at cursor, end of buffer, or beginning
- **Command history**: Shows what command was executed
- **Error handling**: Displays stderr output on command failure
- **Separators**: Visual separation between outputs

### Recent History

The plugin maintains:

- Last 10 SSH hosts used
- Last 20 commands executed
- Last executed command for quick repeat

## Advanced Usage

### Lua API

You can also use the plugin programmatically:

```lua
local sshiv = require("sshiv")

-- Execute and insert into buffer
sshiv.exec("myserver", "uptime")

-- Execute with stdin
sshiv.exec_with_stdin("myserver", "tee /tmp/config", "config content here")

-- Execute preset by number
sshiv.exec_preset("myserver", 1) -- SSH authorized keys

-- Execute preset with stdin
sshiv.exec_preset_with_stdin("myserver", 1002, "ssh-rsa AAAAB3...")

-- Get preset information
local preset = sshiv.get_preset(1)
print(preset.cmd, preset.desc)

-- List all presets
local presets = sshiv.list_presets()

-- Get presets by category
local config_presets = sshiv.get_presets_by_category("Config")

-- Synchronous execution (returns result)
local output, error = sshiv.exec_sync("myserver", "whoami", 5000)
if output then
    print("User:", vim.trim(output))
else
    print("Error:", error)
end

-- Update configuration
sshiv.update_config({
    output_position = 'end',
    timeout = 60000
})
```

### FZF Integration

The plugin provides powerful fzf integration for preset selection:

```vim
" Open fzf to select preset (will prompt for host)
:SshivPresetFzf

" Open fzf for specific host
:SshivPresetFzf myserver

" Open fzf for stdin-compatible presets
:SshivStdinFzf myserver

" Use keymapping for quick access
<leader>sp     " Select preset with fzf (prompts for host)
<leader>sP     " Select preset with fzf for specific host
<leader>sB     " Select stdin preset with fzf (uses buffer)
```

The fzf interface shows:

- Preset number for quick reference
- Category for organization
- Full command
- Description
- Preview of the description

### Preset Categories

All 250 presets are organized into logical categories:

1. **Config** (1-25) - Configuration files and environment setup
2. **Security** (20-29) - Authentication, certificates, permissions
3. **Docker** (30-39) - Container management and inspection
4. **Kubernetes** (35-42) - K8s resources and configs
5. **Git** (40-50) - Version control and repositories
6. **Network** (45-55) - Network configuration and diagnostics
7. **Database** (50-60) - Database connections and queries
8. **Logs** (54-65) - Log files and analysis
9. **System** (76-90) - System information and hardware
10. **Performance** (176-200) - Monitoring and diagnostics

### Quick Preset Access

For frequently used commands, you can access presets directly by number:

```vim
" Configuration management workflow
:SshivPreset web01 1     " SSH authorized keys
:SshivPreset web01 3     " SSH daemon config
:SshivPreset web01 10    " hosts file
:SshivPreset web01 12    " git config

" Container management workflow
:SshivPreset docker01 30  " container details
:SshivPreset docker01 31  " docker daemon config
:SshivPreset docker01 33  " docker-compose file

" Security audit workflow
:SshivPreset server 20    " user accounts
:SshivPreset server 23    " auth log
:SshivPreset server 26    " SSL certificates
:SshivPreset server 106   " sudo permissions
```

### Custom Key Mappings

You can add custom keybindings directly in your lazy.nvim configuration:

```lua
{
    "tfpickard/sshiv.nvim",
    config = function()
        require("sshiv").setup({
            -- Your configuration here
        })
    end,

    keys = {
        -- Quick server health check
        {
            "<leader>sh",
            function()
                local host = vim.fn.input("Server: ", "")
                if host ~= "" then
                    local sshiv = require("sshiv")
                    sshiv.exec_preset(host, 85)   -- uptime
                    sshiv.exec_preset(host, 84)   -- memory
                    sshiv.exec_preset(host, 83)   -- disk space
                    sshiv.exec_preset(host, 176)  -- top processes
                end
            end,
            desc = "Server health check"
        },

        -- Configuration deployment workflow
        {
            "<leader>sC",
            function()
                local host = vim.fn.input("Target server: ", "")
                if host ~= "" then
                    local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
                    local sshiv = require("sshiv")
                    sshiv.exec_with_stdin(host, "sudo tee /etc/nginx/sites-available/default", content)
                    sshiv.exec(host, "sudo nginx -t") -- test config
                    sshiv.exec(host, "sudo systemctl reload nginx") -- reload if valid
                end
            end,
            desc = "Deploy nginx config"
        },

        -- SSH key management
        {
            "<leader>sK",
            function()
                local host = vim.fn.input("Server: ", "")
                if host ~= "" then
                    local sshiv = require("sshiv")
                    sshiv.exec_preset(host, 1) -- Show current authorized keys
                    local choice = vim.fn.confirm("Add current buffer as SSH key?", "&Yes\n&No", 2)
                    if choice == 1 then
                        local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
                        sshiv.exec_preset_with_stdin(host, 1002, content)
                    end
                end
            end,
            desc = "SSH key management"
        },

        -- Docker status on multiple servers
        {
            "<leader>sD",
            function()
                local servers = {"web01", "web02", "db01"}
                local sshiv = require("sshiv")
                for _, server in ipairs(servers) do
                    sshiv.exec_preset(server, 96) -- all containers
                end
            end,
            desc = "Docker status on all servers"
        },

        -- Security audit workflow
        {
            "<leader>sS",
            function()
                local host = vim.fn.input("Server: ", "")
                if host ~= "" then
                    local sshiv = require("sshiv")
                    sshiv.exec_preset(host, 20)  -- user accounts
                    sshiv.exec_preset(host, 23)  -- auth log
                    sshiv.exec_preset(host, 109) -- logged in users
                    sshiv.exec_preset(host, 106) -- sudo permissions
                    sshiv.exec_preset(host, 153) -- firewall status
                end
            end,
            desc = "Security audit"
        },

        -- Kubernetes workflow
        {
            "<leader>sQ",
            function()
                local host = vim.fn.input("K8s master: ", "")
                if host ~= "" then
                    local choice = vim.fn.confirm("Apply current buffer as K8s manifest?", "&Yes\n&Show only", 2)
                    local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
                    local sshiv = require("sshiv")
                    if choice == 1 then
                        sshiv.exec_preset_with_stdin(host, 1004, content) -- kubectl apply
                    else
                        sshiv.exec_with_stdin(host, "kubectl apply --dry-run=client -f -", content)
                    end
                end
            end,
            desc = "Kubernetes deployment"
        },
    },
}
```

### Creating Preset Workflows

You can create reusable workflow functions in your configuration:

```lua
{
    "tfpickard/sshiv.nvim",
    config = function()
        require("sshiv").setup({
            -- Your setup configuration
        })

        -- Define custom workflow functions
        local sshiv = require("sshiv")

        -- Infrastructure health check
        _G.sshiv_health_check = function(host)
            local checks = {
                {85, "System uptime"},
                {84, "Memory usage"},
                {83, "Disk usage"},
                {88, "Network ports"},
                {116, "Service status"},
                {176, "Process overview"}
            }

            for _, check in ipairs(checks) do
                print("Running:", check[2])
                sshiv.exec_preset(host, check[1])
            end
        end

        -- Application deployment check
        _G.sshiv_deployment_check = function(host)
            sshiv.exec_preset(host, 96)   -- docker containers
            sshiv.exec_preset(host, 40)   -- git status
            sshiv.exec_preset(host, 56)   -- recent logs
            sshiv.exec_preset(host, 116)  -- failed services
        end

        -- Configuration backup
        _G.sshiv_backup_configs = function(host)
            local configs = {1, 2, 3, 4, 5, 10, 11, 12} -- Important config presets
            for _, preset_id in ipairs(configs) do
                sshiv.exec_preset(host, preset_id)
            end
        end
    end,

    keys = {
        -- Use the workflow functions
        {
            "<leader>shc",
            function()
                local host = vim.fn.input("Server: ", "")
                if host ~= "" then
                    _G.sshiv_health_check(host)
                end
            end,
            desc = "Full health check workflow"
        },

        {
            "<leader>sdc",
            function()
                local host = vim.fn.input("Server: ", "")
                if host ~= "" then
                    _G.sshiv_deployment_check(host)
                end
            end,
            desc = "Deployment check workflow"
        },

        {
            "<leader>sbc",
            function()
                local host = vim.fn.input("Server: ", "")
                if host ~= "" then
                    _G.sshiv_backup_configs(host)
                end
            end,
            desc = "Backup configurations workflow"
        },
    },
}
```

### Customizing Presets

While the plugin comes with 100 presets, you can extend or modify them:

```lua
-- In your plugin config, after setup
local ssh = require("sshiv")

-- Add custom presets (this would require modifying the plugin)
-- Or create your own preset functions
local function my_presets(host, id)
    local custom_commands = {
        [101] = "kubectl get pods",
        [102] = "terraform plan",
        [103] = "ansible-playbook site.yml --check"
    }

    local cmd = custom_commands[id]
    if cmd then
        ssh.exec(host, cmd)
    else
        ssh.exec_preset(host, id) -- fallback to built-in
    end
end
```

## Security Considerations

- **Key-based authentication**: Plugin assumes you have SSH keys set up
- **Known hosts**: Plugin disables strict host checking by default (adjust in config)
- **No password prompts**: Commands will fail if key auth isn't available
- **Timeouts**: Commands timeout after 30 seconds by default

## Common Use Cases

### System Administration

```vim
:SshExec server01 systemctl status nginx
:SshExec server01 tail -f /var/log/nginx/error.log
:SshExec server01 df -h
```

### Development

```vim
:SshExec devserver git pull origin main
:SshExec devserver docker-compose up -d
:SshExec devserver npm test
```

### Log Analysis

```vim
:SshExec logserver grep ERROR /var/log/app.log | tail -20
:SshExec logserver journalctl -u myservice -f
```

## Troubleshooting

### Connection Issues

1. **Connection timeout**: Increase timeout in config
2. **Host key verification**: Plugin disables by default, adjust `ssh_options`
3. **Authentication**: Ensure SSH key authentication is working

### Command Issues

1. **Long-running commands**: Increase timeout or use commands that exit
2. **Interactive commands**: Avoid commands that require input
3. **Environment**: Commands run in non-interactive shell environment

### Test Your Setup

```vim
" Test localhost connection
:Sshiv localhost whoami

" Test with a simple command
:Sshiv yourserver echo "Hello from Sshiv"

" Test preset functionality
:SshivPreset yourserver 85
```

## Getting Help

- Use `:SshivPresetList` to see all 250 available presets
- Use `:h sshiv` for help (if available)
- Check the [GitHub repository](https://github.com/tfpickard/sshiv.nvim) for issues and updates

## Configuration Examples

### Minimal Setup

```lua
require("sshiv").setup({
    output_position = 'end',
    show_command = false,
    add_separator = false
})
```

### Power User Setup

```lua
require("sshiv").setup({
    ssh_options = {
        "-o", "ConnectTimeout=5",
        "-o", "StrictHostKeyChecking=no",
        "-o", "UserKnownHostsFile=/dev/null",
        "-o", "LogLevel=ERROR",
        "-o", "ServerAliveInterval=30",
        "-o", "ServerAliveCountMax=3"
    },
    timeout = 60000, -- 1 minute
    default_user = "admin",
    separator_text = "────── SSH OUTPUT ──────",
    command_prefix_format = "[%s@%s] %s"
})
```

This plugin is designed to integrate seamlessly with your console-heavy workflow, making it easy to execute remote commands without leaving your editor.
