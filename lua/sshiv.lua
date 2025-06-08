-- lua/plugins/sshiv.lua
return {
    "tfpickard/sshiv.nvim",
    config = function()
        require("sshiv").setup({
            -- SSH connection options
            ssh_options = {
                "-o", "ConnectTimeout=10",
                "-o", "StrictHostKeyChecking=no",
                "-o", "UserKnownHostsFile=/dev/null",
                "-o", "LogLevel=ERROR",
                "-o", "ServerAliveInterval=30"
            },
            
            -- Where to insert output: 'cursor', 'end', 'beginning'
            output_position = 'cursor',
            
            -- Visual formatting
            add_separator = true,
            separator_text = "=== Sshiv Output ===",
            
            -- Command execution settings
            timeout = 30000, -- 30 seconds
            default_user = nil, -- nil = use current user
            
            -- Output formatting
            show_command = true,
            command_prefix_format = "$ %s@%s: %s",
            
            -- User-defined presets (starting at ID 1000)
            user_presets = {
                {
                    category = "Custom",
                    cmd = "cat ~/.ssh/authorized_keys | grep -v '^#'",
                    desc = "Active SSH keys only"
                },
                {
                    category = "Custom", 
                    cmd = "docker logs --tail=50 $(docker ps -q | head -1)",
                    desc = "Latest container logs"
                },
                {
                    category = "Custom",
                    cmd = "tee -a ~/.ssh/authorized_keys",
                    desc = "Append to authorized_keys"
                },
                {
                    category = "Custom",
                    cmd = "sudo tee /etc/nginx/sites-available/default",
                    desc = "Update nginx default site"
                },
                {
                    category = "Custom",
                    cmd = "kubectl apply -f -",
                    desc = "Apply Kubernetes manifest"
                },
                {
                    category = "Custom",
                    cmd = "mysql -u root -p < /dev/stdin",
                    desc = "Execute SQL commands"
                },
                {
                    category = "Custom",
                    cmd = "base64 -d | tar -xzf -",
                    desc = "Decode and extract archive"
                },
                {
                    category = "Custom",
                    cmd = "gpg --import",
                    desc = "Import GPG key"
                },
            },
        })
    end,
    
    keys = {
        -- Quick Sshiv execution
        {
            "<leader>ss",
            function()
                require("sshiv").exec_interactive()
            end,
            desc = "Sshiv Execute (interactive)"
        },
        
        -- Repeat last Sshiv command
        {
            "<leader>sr",
            function()
                require("sshiv").exec_last()
            end,
            desc = "Sshiv Execute (repeat last)"
        },
        
        -- Sshiv to localhost (useful for testing)
        {
            "<leader>sl",
            function()
                local cmd = vim.fn.input("Local command: ", "")
                if cmd ~= "" then
                    require("sshiv").exec("localhost", cmd)
                end
            end,
            desc = "Sshiv Execute (localhost)"
        },
        
        -- Preset commands with fzf
        {
            "<leader>sp",
            function()
                require("sshiv").fzf_presets()
            end,
            desc = "Sshiv Presets (fzf)"
        },
        
        -- Quick preset for specific host
        {
            "<leader>sP",
            function()
                local host = vim.fn.input("Sshiv Host: ", "")
                if host ~= "" then
                    require("sshiv").fzf_presets(host)
                end
            end,
            desc = "Sshiv Presets for host (fzf)"
        },
        
        -- Show preset list
        {
            "<leader>s?",
            function()
                require("sshiv").show_presets()
            end,
            desc = "Show Sshiv presets"
        },
        
        -- STDIN COMMANDS
        
        -- Send buffer content via stdin
        {
            "<leader>sb",
            function()
                local host = vim.fn.input("Sshiv Host: ", "")
                local cmd = vim.fn.input("Command: ", "tee /tmp/buffer_content")
                if host ~= "" and cmd ~= "" then
                    local sshiv = require("sshiv")
                    local content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                    sshiv.exec_with_stdin(host, cmd, table.concat(content, '\n'))
                end
            end,
            desc = "Sshiv Send buffer as stdin"
        },
        
        -- Send visual selection via stdin
        {
            "<leader>sv",
            function()
                local host = vim.fn.input("Sshiv Host: ", "")
                local cmd = vim.fn.input("Command: ", "tee /tmp/selection")
                if host ~= "" and cmd ~= "" then
                    local sshiv = require("sshiv")
                    -- Get visual selection
                    local start_pos = vim.fn.getpos("'<")
                    local end_pos = vim.fn.getpos("'>")
                    local lines = vim.api.nvim_buf_get_lines(0, start_pos[2]-1, end_pos[2], false)
                    if #lines > 0 then
                        if #lines == 1 then
                            lines[1] = string.sub(lines[1], start_pos[3], end_pos[3])
                        else
                            lines[1] = string.sub(lines[1], start_pos[3])
                            lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
                        end
                    end
                    sshiv.exec_with_stdin(host, cmd, table.concat(lines, '\n'))
                end
            end,
            mode = "v",
            desc = "Sshiv Send selection as stdin"
        },
        
        -- Stdin presets with fzf
        {
            "<leader>sB",
            function()
                require("sshiv").fzf_presets_stdin()
            end,
            desc = "Sshiv Stdin presets (buffer, fzf)"
        },
        
        -- Quick authorized_keys append
        {
            "<leader>sk",
            function()
                local host = vim.fn.input("Sshiv Host: ", "")
                if host ~= "" then
                    require("sshiv").exec_preset_with_stdin(host, 1002, 
                        vim.api.nvim_buf_get_lines(0, 0, -1, false)[1] or "")
                end
            end,
            desc = "Append first line to authorized_keys"
        },
        
        -- Quick system info preset
        {
            "<leader>si",
            function()
                local host = vim.fn.input("Sshiv Host: ", "")
                if host ~= "" then
                    require("sshiv").exec_preset(host, 85) -- uptime (reordered)
                end
            end,
            desc = "Sshiv System info (uptime)"
        },
        
        -- Quick process check  
        {
            "<leader>sT",
            function()
                local host = vim.fn.input("Sshiv Host: ", "")
                if host ~= "" then
                    require("sshiv").exec_preset(host, 176) -- top processes
                end
            end,
            desc = "Sshiv Top processes"
        },
    },
    
    cmd = {
        "Sshiv",
        "SshivHost", 
        "SshivLast",
        "SshivStdin",
        "SshivStdinBuffer", 
        "SshivStdinVisual",
        "SshivStdinFzf",
        "SshivPreset",
        "SshivPresetFzf",
        "SshivPresetList"
    },
    }
}
