-- lua/sshiv-presets.lua
-- Sshiv Command Presets - Ordered by likelihood of needing output in buffer
-- Focus on DevSecOps workflows where you'd want to edit/reference the output

local M = {}

-- Command presets ordered by likelihood of use (1 = most likely to need in buffer)
M.presets = {
	-- MOST LIKELY - Configuration files, keys, secrets (1-25)
	{ id = 1, category = "Config", cmd = "cat ~/.ssh/authorized_keys", desc = "SSH authorized keys" },
	{ id = 2, category = "Config", cmd = "cat ~/.ssh/config", desc = "SSH client config" },
	{ id = 3, category = "Config", cmd = "cat /etc/ssh/sshd_config", desc = "SSH daemon config" },
	{ id = 4, category = "Config", cmd = "cat /etc/nginx/nginx.conf", desc = "Nginx main config" },
	{ id = 5, category = "Config", cmd = "cat /etc/apache2/apache2.conf", desc = "Apache main config" },
	{ id = 6, category = "Config", cmd = "printenv | sort", desc = "All environment variables" },
	{ id = 7, category = "Config", cmd = "echo $PATH | tr ':' '\\n'", desc = "PATH components" },
	{ id = 8, category = "Config", cmd = "cat ~/.bashrc", desc = "Bash configuration" },
	{ id = 9, category = "Config", cmd = "cat ~/.zshrc", desc = "Zsh configuration" },
	{ id = 10, category = "Config", cmd = "cat /etc/hosts", desc = "Hosts file" },
	{ id = 11, category = "Config", cmd = "cat /etc/resolv.conf", desc = "DNS resolver config" },
	{ id = 12, category = "Config", cmd = "cat ~/.gitconfig", desc = "Git global config" },
	{ id = 13, category = "Config", cmd = "git config --list", desc = "All git configuration" },
	{ id = 14, category = "Config", cmd = "cat /etc/sudoers", desc = "Sudo configuration" },
	{ id = 15, category = "Config", cmd = "cat ~/.tmux.conf", desc = "Tmux configuration" },
	{ id = 16, category = "Config", cmd = "cat ~/.vimrc", desc = "Vim configuration" },
	{ id = 17, category = "Config", cmd = "crontab -l", desc = "User crontab" },
	{ id = 18, category = "Config", cmd = "cat /etc/crontab", desc = "System crontab" },
	{ id = 19, category = "Config", cmd = "ls -la /etc/cron.d/", desc = "Cron jobs directory" },
	{ id = 20, category = "Security", cmd = "cat /etc/passwd", desc = "User accounts" },
	{ id = 21, category = "Security", cmd = "cat /etc/group", desc = "System groups" },
	{ id = 22, category = "Security", cmd = "cat /etc/shadow", desc = "Password hashes" },
	{ id = 23, category = "Security", cmd = "sudo cat /var/log/auth.log | tail -50", desc = "Authentication log" },
	{ id = 24, category = "Security", cmd = "sudo cat /var/log/secure | tail -50", desc = "Security log (RHEL)" },
	{ id = 25, category = "Security", cmd = "last -50", desc = "Recent user logins" },

	-- HIGH LIKELIHOOD - Certificates, keys, app configs (26-75)
	{
		id = 26,
		category = "Security",
		cmd = "openssl x509 -in /etc/ssl/certs/ssl-cert-snakeoil.pem -text",
		desc = "SSL certificate details",
	},
	{
		id = 27,
		category = "Security",
		cmd = "openssl x509 -in /etc/letsencrypt/live/*/cert.pem -text",
		desc = "Let's Encrypt certificate",
	},
	{ id = 28, category = "Security", cmd = "gpg --list-keys", desc = "GPG public keys" },
	{ id = 29, category = "Security", cmd = "gpg --list-secret-keys", desc = "GPG private keys" },
	{ id = 30, category = "Docker", cmd = "docker inspect $(docker ps -q)", desc = "All container details" },
	{ id = 31, category = "Docker", cmd = "cat /etc/docker/daemon.json", desc = "Docker daemon config" },
	{ id = 32, category = "Docker", cmd = "docker-compose config", desc = "Docker compose resolved config" },
	{ id = 33, category = "Docker", cmd = "cat docker-compose.yml", desc = "Docker compose file" },
	{ id = 34, category = "Docker", cmd = "cat Dockerfile", desc = "Dockerfile content" },
	{ id = 35, category = "Kubernetes", cmd = "kubectl get pods -o yaml", desc = "Pod configurations" },
	{ id = 36, category = "Kubernetes", cmd = "kubectl get services -o yaml", desc = "Service configurations" },
	{ id = 37, category = "Kubernetes", cmd = "kubectl get configmap -o yaml", desc = "ConfigMap details" },
	{ id = 38, category = "Kubernetes", cmd = "kubectl get secrets -o yaml", desc = "Secret details" },
	{ id = 39, category = "Kubernetes", cmd = "cat ~/.kube/config", desc = "Kubernetes config" },
	{ id = 40, category = "Git", cmd = "git log --oneline -20", desc = "Recent commit history" },
	{ id = 41, category = "Git", cmd = "git remote -v", desc = "Git remotes" },
	{ id = 42, category = "Git", cmd = "git branch -a", desc = "All git branches" },
	{ id = 43, category = "Git", cmd = "git status --porcelain", desc = "Git status (parseable)" },
	{ id = 44, category = "Git", cmd = "git diff --name-only", desc = "Changed files" },
	{ id = 45, category = "Network", cmd = "nmcli con show", desc = "NetworkManager connections" },
	{ id = 46, category = "Network", cmd = "cat /etc/netplan/*.yaml", desc = "Netplan configuration" },
	{
		id = 47,
		category = "Network",
		cmd = "sudo cat /etc/NetworkManager/system-connections/\\*",
		desc = "NetworkManager connection definitions (requires passwordless sudo)",
	},
	{ id = 48, category = "Network", cmd = "iptables-save", desc = "Current iptables rules" },
	{ id = 49, category = "Network", cmd = "ip route show table all", desc = "All routing tables" },
	{ id = 50, category = "Database", cmd = "mysql -e 'SHOW DATABASES;'", desc = "MySQL databases" },
	{ id = 51, category = "Database", cmd = "psql -l", desc = "PostgreSQL databases" },
	{
		id = 52,
		category = "Database",
		cmd = "mongo --eval 'db.adminCommand(\"listDatabases\")'",
		desc = "MongoDB databases",
	},
	{ id = 53, category = "Database", cmd = "redis-cli info", desc = "Redis server info" },
	{ id = 54, category = "Logs", cmd = "cat /var/log/nginx/error.log | tail -50", desc = "Nginx error log" },
	{ id = 55, category = "Logs", cmd = "cat /var/log/apache2/error.log | tail -50", desc = "Apache error log" },
	{ id = 56, category = "Logs", cmd = "journalctl -u nginx --no-pager -n 50", desc = "Nginx systemd logs" },
	{ id = 57, category = "Logs", cmd = "journalctl -u docker --no-pager -n 50", desc = "Docker systemd logs" },
	{ id = 58, category = "Logs", cmd = "cat /var/log/syslog | grep -i error | tail -20", desc = "System errors" },
	{ id = 59, category = "Config", cmd = "cat /etc/systemd/system/*.service", desc = "Custom systemd services" },
	{ id = 60, category = "Config", cmd = "systemctl list-unit-files --type=service", desc = "All service files" },
	{ id = 61, category = "AWS", cmd = "aws configure list", desc = "AWS configuration" },
	{ id = 62, category = "AWS", cmd = "cat ~/.aws/credentials", desc = "AWS credentials" },
	{ id = 63, category = "AWS", cmd = "cat ~/.aws/config", desc = "AWS config file" },
	{ id = 64, category = "Cloud", cmd = "gcloud config list", desc = "Google Cloud config" },
	{ id = 65, category = "Cloud", cmd = "az account show", desc = "Azure account info" },
	{ id = 66, category = "Package", cmd = "pip list --format=freeze", desc = "Python packages (pip)" },
	{ id = 67, category = "Package", cmd = "npm list -g --depth=0", desc = "Global npm packages" },
	{ id = 68, category = "Package", cmd = "gem list", desc = "Ruby gems" },
	{ id = 69, category = "Package", cmd = "cargo install --list", desc = "Rust packages" },
	{ id = 70, category = "Package", cmd = "go list -m all", desc = "Go modules" },
	{ id = 71, category = "Config", cmd = "cat package.json", desc = "Node.js package config" },
	{ id = 72, category = "Config", cmd = "cat requirements.txt", desc = "Python requirements" },
	{ id = 73, category = "Config", cmd = "cat Cargo.toml", desc = "Rust project config" },
	{ id = 74, category = "Config", cmd = "cat go.mod", desc = "Go module file" },
	{ id = 75, category = "Config", cmd = "cat Makefile", desc = "Make configuration" },

	-- MEDIUM-HIGH LIKELIHOOD - System info for reference (76-125)
	{ id = 76, category = "System", cmd = "uname -a", desc = "System information" },
	{ id = 77, category = "System", cmd = "cat /etc/os-release", desc = "OS version details" },
	{ id = 78, category = "System", cmd = "lscpu", desc = "CPU information" },
	{ id = 79, category = "System", cmd = "cat /proc/meminfo", desc = "Memory details" },
	{ id = 80, category = "System", cmd = "cat /proc/cpuinfo", desc = "Detailed CPU info" },
	{ id = 81, category = "System", cmd = "lsblk -f", desc = "Block devices with filesystems" },
	{ id = 82, category = "System", cmd = "mount | column -t", desc = "Mounted filesystems" },
	{ id = 83, category = "System", cmd = "df -h", desc = "Disk usage" },
	{ id = 84, category = "System", cmd = "free -h", desc = "Memory usage" },
	{ id = 85, category = "System", cmd = "uptime", desc = "System uptime" },
	{ id = 86, category = "Network", cmd = "ip addr show", desc = "Network interfaces" },
	{ id = 87, category = "Network", cmd = "ip route show", desc = "Routing table" },
	{ id = 88, category = "Network", cmd = "netstat -tuln", desc = "Listening ports" },
	{ id = 89, category = "Network", cmd = "ss -tuln", desc = "Socket statistics" },
	{ id = 90, category = "Network", cmd = "arp -a", desc = "ARP table" },
	{ id = 91, category = "Process", cmd = "ps aux --sort=-%cpu | head -20", desc = "Top CPU processes" },
	{ id = 92, category = "Process", cmd = "ps aux --sort=-%mem | head -20", desc = "Top memory processes" },
	{ id = 93, category = "Process", cmd = "pstree", desc = "Process tree" },
	{ id = 94, category = "Process", cmd = "lsof -i", desc = "Network connections" },
	{ id = 95, category = "Process", cmd = "lsof -p $(pgrep -d, nginx)", desc = "Nginx file handles" },
	{ id = 96, category = "Docker", cmd = "docker ps -a", desc = "All containers" },
	{ id = 97, category = "Docker", cmd = "docker images", desc = "Docker images" },
	{ id = 98, category = "Docker", cmd = "docker network ls", desc = "Docker networks" },
	{ id = 99, category = "Docker", cmd = "docker volume ls", desc = "Docker volumes" },
	{ id = 100, category = "Docker", cmd = "docker system df", desc = "Docker disk usage" },
	{ id = 101, category = "Kubernetes", cmd = "kubectl get nodes -o wide", desc = "Kubernetes nodes" },
	{ id = 102, category = "Kubernetes", cmd = "kubectl get pods -o wide", desc = "Pod details" },
	{ id = 103, category = "Kubernetes", cmd = "kubectl get services", desc = "Kubernetes services" },
	{ id = 104, category = "Kubernetes", cmd = "kubectl get ingress", desc = "Ingress resources" },
	{ id = 105, category = "Kubernetes", cmd = "kubectl get pv,pvc", desc = "Persistent volumes" },
	{ id = 106, category = "Security", cmd = "sudo -l", desc = "Sudo permissions" },
	{ id = 107, category = "Security", cmd = "groups", desc = "User groups" },
	{ id = 108, category = "Security", cmd = "id", desc = "User and group IDs" },
	{ id = 109, category = "Security", cmd = "w", desc = "Logged in users" },
	{ id = 110, category = "Security", cmd = "who", desc = "Current users" },
	{ id = 111, category = "Files", cmd = "ls -la", desc = "Detailed file listing" },
	{ id = 112, category = "Files", cmd = "find . -type f -name '*.conf' | head -20", desc = "Configuration files" },
	{ id = 113, category = "Files", cmd = "find . -type f -name '*.log' | head -20", desc = "Log files" },
	{ id = 114, category = "Files", cmd = "find . -type f -size +100M | head -10", desc = "Large files" },
	{ id = 115, category = "Files", cmd = "du -sh * | sort -hr | head -20", desc = "Directory sizes" },
	{ id = 116, category = "Service", cmd = "systemctl list-units --failed", desc = "Failed services" },
	{ id = 117, category = "Service", cmd = "systemctl status", desc = "System status" },
	{ id = 118, category = "Service", cmd = "systemctl list-timers", desc = "Systemd timers" },
	{ id = 119, category = "Web", cmd = "curl -I localhost", desc = "Local web server headers" },
	{ id = 120, category = "Web", cmd = "curl -s localhost/health | jq .", desc = "Health endpoint JSON" },
	{
		id = 121,
		category = "Package",
		cmd = "dpkg -l | grep -E '(docker|nginx|apache)'",
		desc = "Installed packages (deb)",
	},
	{
		id = 122,
		category = "Package",
		cmd = "rpm -qa | grep -E '(docker|nginx|apache)'",
		desc = "Installed packages (rpm)",
	},
	{ id = 123, category = "Package", cmd = "apt list --upgradable", desc = "Available updates (apt)" },
	{ id = 124, category = "Package", cmd = "yum check-update", desc = "Available updates (yum)" },
	{ id = 125, category = "Hardware", cmd = "lshw -short", desc = "Hardware summary" },

	-- MEDIUM LIKELIHOOD - Development tools and environment (126-175)
	{ id = 126, category = "Dev", cmd = "which python python3 pip", desc = "Python installation paths" },
	{ id = 127, category = "Dev", cmd = "python --version", desc = "Python version" },
	{ id = 128, category = "Dev", cmd = "node --version", desc = "Node.js version" },
	{ id = 129, category = "Dev", cmd = "go version", desc = "Go version" },
	{ id = 130, category = "Dev", cmd = "java -version", desc = "Java version" },
	{ id = 131, category = "Dev", cmd = "docker --version", desc = "Docker version" },
	{ id = 132, category = "Dev", cmd = "kubectl version --client", desc = "Kubectl version" },
	{ id = 133, category = "Dev", cmd = "terraform version", desc = "Terraform version" },
	{ id = 134, category = "Dev", cmd = "ansible --version", desc = "Ansible version" },
	{ id = 135, category = "CI", cmd = "cat .gitlab-ci.yml", desc = "GitLab CI config" },
	{ id = 136, category = "CI", cmd = "cat .github/workflows/*.yml", desc = "GitHub Actions" },
	{ id = 137, category = "CI", cmd = "cat Jenkinsfile", desc = "Jenkins pipeline" },
	{ id = 138, category = "CI", cmd = "cat .circleci/config.yml", desc = "CircleCI config" },
	{ id = 139, category = "Monitoring", cmd = "cat /etc/prometheus/prometheus.yml", desc = "Prometheus config" },
	{ id = 140, category = "Monitoring", cmd = "cat /etc/grafana/grafana.ini", desc = "Grafana config" },
	{ id = 141, category = "Monitoring", cmd = "cat /etc/collectd/collectd.conf", desc = "Collectd config" },
	{ id = 142, category = "Backup", cmd = "cat /etc/cron.d/backup", desc = "Backup cron jobs" },
	{ id = 143, category = "Backup", cmd = "ls -la /backup/ /var/backup/", desc = "Backup directories" },
	{ id = 144, category = "Backup", cmd = "rsync --dry-run -av /home/ /backup/", desc = "Backup dry run" },
	{ id = 145, category = "Load Balancer", cmd = "cat /etc/haproxy/haproxy.cfg", desc = "HAProxy config" },
	{ id = 146, category = "Cache", cmd = "cat /etc/redis/redis.conf", desc = "Redis config" },
	{ id = 147, category = "Cache", cmd = "cat /etc/memcached.conf", desc = "Memcached config" },
	{ id = 148, category = "Database", cmd = "cat /etc/mysql/mysql.conf.d/mysqld.cnf", desc = "MySQL config" },
	{ id = 149, category = "Database", cmd = "cat /etc/postgresql/*/main/postgresql.conf", desc = "PostgreSQL config" },
	{ id = 150, category = "Database", cmd = "cat /etc/mongod.conf", desc = "MongoDB config" },
	{
		id = 151,
		category = "SSL",
		cmd = "openssl s_client -connect localhost:443 -servername localhost",
		desc = "SSL connection test",
	},
	{ id = 152, category = "SSL", cmd = "certbot certificates", desc = "Let's Encrypt certificates" },
	{ id = 153, category = "Firewall", cmd = "ufw status verbose", desc = "UFW firewall status" },
	{ id = 154, category = "Firewall", cmd = "firewall-cmd --list-all", desc = "FirewallD status" },
	{ id = 155, category = "SELinux", cmd = "getenforce", desc = "SELinux status" },
	{ id = 156, category = "SELinux", cmd = "sestatus", desc = "SELinux detailed status" },
	{ id = 157, category = "Virtualization", cmd = "virsh list --all", desc = "Virtual machines" },
	{ id = 158, category = "Virtualization", cmd = "vboxmanage list vms", desc = "VirtualBox VMs" },
	{ id = 159, category = "Storage", cmd = "pvdisplay", desc = "LVM physical volumes" },
	{ id = 160, category = "Storage", cmd = "vgdisplay", desc = "LVM volume groups" },
	{ id = 161, category = "Storage", cmd = "lvdisplay", desc = "LVM logical volumes" },
	{ id = 162, category = "Storage", cmd = "cat /proc/mdstat", desc = "Software RAID status" },
	{ id = 163, category = "Storage", cmd = "smartctl -a /dev/sda", desc = "Disk health (SMART)" },
	{ id = 164, category = "Network", cmd = "cat /etc/hosts.allow", desc = "TCP wrappers allow" },
	{ id = 165, category = "Network", cmd = "cat /etc/hosts.deny", desc = "TCP wrappers deny" },
	{ id = 166, category = "DNS", cmd = "cat /etc/bind/named.conf", desc = "BIND DNS config" },
	{ id = 167, category = "DNS", cmd = "dig @localhost axfr example.com", desc = "DNS zone transfer" },
	{ id = 168, category = "DHCP", cmd = "cat /etc/dhcp/dhcpd.conf", desc = "DHCP server config" },
	{ id = 169, category = "NFS", cmd = "cat /etc/exports", desc = "NFS exports" },
	{ id = 170, category = "Samba", cmd = "cat /etc/samba/smb.conf", desc = "Samba config" },
	{ id = 171, category = "VPN", cmd = "cat /etc/openvpn/server.conf", desc = "OpenVPN server config" },
	{ id = 172, category = "Proxy", cmd = "cat /etc/squid/squid.conf", desc = "Squid proxy config" },
	{ id = 173, category = "Mail", cmd = "cat /etc/postfix/main.cf", desc = "Postfix config" },
	{ id = 174, category = "Mail", cmd = "cat /etc/dovecot/dovecot.conf", desc = "Dovecot config" },
	{ id = 175, category = "Time", cmd = "cat /etc/ntp.conf", desc = "NTP configuration" },

	-- LOWER LIKELIHOOD - Basic monitoring and status (176-250)
	{ id = 176, category = "Monitor", cmd = "top -b -n 1 | head -20", desc = "Current processes" },
	{ id = 177, category = "Monitor", cmd = "htop -d 5", desc = "Interactive process monitor" },
	{ id = 178, category = "Monitor", cmd = "vmstat 1 5", desc = "Virtual memory stats" },
	{ id = 179, category = "Monitor", cmd = "iostat -x 1 5", desc = "I/O statistics" },
	{ id = 180, category = "Monitor", cmd = "sar -u 1 5", desc = "CPU utilization" },
	{ id = 181, category = "Monitor", cmd = "sar -r 1 5", desc = "Memory utilization" },
	{ id = 182, category = "Network", cmd = "ping -c 4 8.8.8.8", desc = "Internet connectivity" },
	{ id = 183, category = "Network", cmd = "traceroute 8.8.8.8", desc = "Network path to Google" },
	{ id = 184, category = "Network", cmd = "nslookup google.com", desc = "DNS lookup" },
	{ id = 185, category = "Network", cmd = "dig google.com", desc = "DNS query" },
	{ id = 186, category = "Network", cmd = "curl -I https://google.com", desc = "HTTP headers" },
	{ id = 187, category = "Hardware", cmd = "sensors", desc = "Temperature sensors" },
	{ id = 188, category = "Hardware", cmd = "lspci", desc = "PCI devices" },
	{ id = 189, category = "Hardware", cmd = "lsusb", desc = "USB devices" },
	{ id = 190, category = "Hardware", cmd = "dmidecode -t system", desc = "System information" },
	{ id = 191, category = "Hardware", cmd = "hdparm -I /dev/sda", desc = "Hard drive info" },
	{ id = 192, category = "Hardware", cmd = "cat /proc/interrupts", desc = "Interrupt statistics" },
	{ id = 193, category = "Hardware", cmd = "cat /proc/modules", desc = "Loaded kernel modules" },
	{ id = 194, category = "Performance", cmd = "dmesg | tail -20", desc = "Recent kernel messages" },
	{ id = 195, category = "Performance", cmd = "journalctl -b --no-pager | tail -20", desc = "Boot messages" },
	{ id = 196, category = "Users", cmd = "finger", desc = "User information" },
	{ id = 197, category = "Users", cmd = "lastlog", desc = "Last login times" },
	{ id = 198, category = "Security", cmd = "fail2ban-client status", desc = "Fail2ban status" },
	{ id = 199, category = "Security", cmd = "chkrootkit", desc = "Rootkit check" },
	{ id = 200, category = "Security", cmd = "rkhunter --check --skip-keypress", desc = "Rootkit hunter" },
	{ id = 201, category = "Logs", cmd = "tail -50 /var/log/messages", desc = "System messages" },
	{ id = 202, category = "Logs", cmd = "tail -50 /var/log/kern.log", desc = "Kernel log" },
	{ id = 203, category = "Logs", cmd = "tail -50 /var/log/daemon.log", desc = "Daemon log" },
	{ id = 204, category = "Logs", cmd = "tail -50 /var/log/mail.log", desc = "Mail log" },
	{ id = 205, category = "Logs", cmd = "tail -50 /var/log/cron.log", desc = "Cron log" },
	{ id = 206, category = "Files", cmd = "locate nginx.conf", desc = "Find nginx config" },
	{ id = 207, category = "Files", cmd = "which nginx apache2 httpd", desc = "Web server binaries" },
	{ id = 208, category = "Files", cmd = "file /usr/bin/python*", desc = "Python binary types" },
	{ id = 209, category = "Files", cmd = "stat /etc/passwd", desc = "File statistics" },
	{ id = 210, category = "Files", cmd = "find /tmp -type f -mtime +7", desc = "Old temp files" },
	{ id = 211, category = "Files", cmd = "find /var/log -name '*.gz' | head -10", desc = "Compressed log files" },
	{ id = 212, category = "Files", cmd = "find / -perm -4000 2>/dev/null | head -20", desc = "SUID files" },
	{ id = 213, category = "Files", cmd = "find / -perm -2000 2>/dev/null | head -20", desc = "SGID files" },
	{ id = 214, category = "Service", cmd = "service --status-all", desc = "All service status" },
	{ id = 215, category = "Service", cmd = "chkconfig --list", desc = "Service startup config" },
	{ id = 216, category = "Service", cmd = "systemctl list-unit-files --type=service", desc = "Service unit files" },
	{ id = 217, category = "Kernel", cmd = "cat /proc/version", desc = "Kernel version" },
	{ id = 218, category = "Kernel", cmd = "uname -r", desc = "Kernel release" },
	{ id = 219, category = "Kernel", cmd = "cat /proc/cmdline", desc = "Kernel boot parameters" },
	{ id = 220, category = "Kernel", cmd = "sysctl -a | grep vm", desc = "Virtual memory settings" },
	{ id = 221, category = "Kernel", cmd = "cat /proc/sys/kernel/hostname", desc = "System hostname" },
	{ id = 222, category = "Boot", cmd = "cat /proc/uptime", desc = "System uptime seconds" },
	{ id = 223, category = "Boot", cmd = "systemd-analyze blame", desc = "Boot time analysis" },
	{ id = 224, category = "Boot", cmd = "systemd-analyze critical-chain", desc = "Boot critical path" },
	{ id = 225, category = "Locale", cmd = "locale", desc = "Current locale settings" },
	{ id = 226, category = "Locale", cmd = "timedatectl", desc = "Time and date settings" },
	{ id = 227, category = "Locale", cmd = "localectl status", desc = "Locale status" },
	{ id = 228, category = "Env", cmd = "env | grep -E '(TERM|LANG|LC_)'", desc = "Terminal environment" },
	{ id = 229, category = "Env", cmd = "echo $SHELL", desc = "Current shell" },
	{ id = 230, category = "Env", cmd = "history | tail -20", desc = "Command history" },
	{ id = 231, category = "Resources", cmd = "ulimit -a", desc = "Resource limits" },
	{ id = 232, category = "Resources", cmd = "cat /proc/loadavg", desc = "Load average" },
	{ id = 233, category = "Resources", cmd = "cat /proc/stat", desc = "System statistics" },
	{ id = 234, category = "Network", cmd = "netstat -rn", desc = "Routing table (netstat)" },
	{ id = 235, category = "Network", cmd = "route -n", desc = "Routing table (route)" },
	{ id = 236, category = "Network", cmd = "ifconfig -a", desc = "Network interfaces (legacy)" },
	{ id = 237, category = "Time", cmd = "date", desc = "Current date and time" },
	{ id = 238, category = "Time", cmd = "uptime", desc = "System uptime" },
	{ id = 239, category = "Time", cmd = "last reboot", desc = "Recent reboots" },
	{ id = 240, category = "Mount", cmd = "findmnt", desc = "Mounted filesystems tree" },
	{ id = 241, category = "Mount", cmd = "cat /proc/mounts", desc = "Kernel mount table" },
	{ id = 242, category = "Package", cmd = "apt list --installed | wc -l", desc = "Installed package count" },
	{ id = 243, category = "Package", cmd = "yum list installed | wc -l", desc = "Installed RPM count" },
	{ id = 244, category = "Package", cmd = "pip freeze | wc -l", desc = "Python package count" },
	{ id = 245, category = "Package", cmd = "npm list -g --depth=0 | wc -l", desc = "Global npm package count" },
	{ id = 246, category = "Shell", cmd = "compgen -c | wc -l", desc = "Available commands count" },
	{ id = 247, category = "Shell", cmd = "alias", desc = "Shell aliases" },
	{ id = 248, category = "Shell", cmd = "type -a python", desc = "Python command type" },
	{ id = 249, category = "Random", cmd = "fortune", desc = "Random fortune" },
	{ id = 250, category = "Random", cmd = "cal", desc = "Calendar" },
	{ id = 251, category = "Network", cmd = "cat /etc/network/interfaces", desc = "Network interfaces config" },
}

function M.get_preset(id)
	for _, preset in ipairs(M.presets) do
		if preset.id == id then
			return preset
		end
	end
	return nil
end

function M.get_all_presets()
	return M.presets
end

function M.get_presets_by_category(category)
	local filtered = {}
	for _, preset in ipairs(M.presets) do
		if preset.category == category then
			table.insert(filtered, preset)
		end
	end
	return filtered
end

function M.get_categories()
	local categories = {}
	local seen = {}
	for _, preset in ipairs(M.presets) do
		if not seen[preset.category] then
			table.insert(categories, preset.category)
			seen[preset.category] = true
		end
	end
	table.sort(categories)
	return categories
end

-- Add user presets (starting at 1000)
function M.add_user_presets(user_presets)
	if not user_presets then
		return
	end

	for i, preset in ipairs(user_presets) do
		local user_preset = {
			id = 1000 + i - 1,
			category = preset.category or "User",
			cmd = preset.cmd,
			desc = preset.desc or "User command",
		}
		table.insert(M.presets, user_preset)
	end

	-- Sort by ID to maintain order
	table.sort(M.presets, function(a, b)
		return a.id < b.id
	end)
end

return M
