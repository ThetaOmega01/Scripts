#!/opt/homebrew/bin/fish

set -g flush_dns false
set -g failed_steps
set -g last_step

# Parse command line arguments
for arg in $argv
    switch $arg
        case --flush-dns -fd
            set flush_dns true
    end
end

function print_header
    set_color brcyan
    set total_width 40
    set text " $argv[1] "
    set text_length (string length $text)
    set remaining_space (math "$total_width - $text_length - 4")
    set left_dashes (math "floor($remaining_space / 2)")
    set right_dashes (math "ceil($remaining_space / 2)")
    set left_dash_str (string repeat -n $left_dashes "─")
    set right_dash_str (string repeat -n $right_dashes "─")
    echo -e "$left_dash_str┤ $argv[1] ├$right_dash_str\n"
    set_color normal
end

function check_status
    if test $status -eq 0
        set_color bryellow
        echo -e " -> Success"
        set_color normal
    else
        set_color brred
        echo -e "-> Failed"
        set_color normal
        if not contains -- $last_step $failed_steps
            set -g failed_steps $failed_steps $last_step
        end
    end
end

function show_step
    set -g last_step $argv[1]
    print_header $argv[1]
    set_color $argv[2]
    echo -e "$argv[3] $argv[4]"
    set_color normal
end

# TeX Live maintenance
show_step "TeX Live Maintenance" brmagenta "Updating TeX Live..."
sudo tlmgr update --self --all
check_status
sleep 1

# Homebrew Maintenance
show_step "Homebrew Maintenance" brmagenta "Updating Homebrew..."
brew update
check_status
sleep 1

show_step "Homebrew Maintenance" brmagenta "Upgrading packages..."
brew upgrade
check_status
sleep 1

show_step "Homebrew Maintenance" brmagenta "Cleaning up..."
brew cleanup
check_status
sleep 1

# System Update Check
show_step "System Update Check" brblue "Checking for macOS updates..."
softwareupdate --install --all
check_status
sleep 1

# Only flush DNS cache if the flag is set
if test $flush_dns = true
    show_step "DNS Cache Flush" brcyan "Flushing DNS cache..."
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
    check_status
    sleep 1
else
    show_step "DNS Cache Flush" bryellow "DNS cache flush skipped. Use --flush-dns or -fd to enable."
    sleep 1
end

if test (count $failed_steps) -gt 0
    set_color brred
    echo -e "\nThe following steps failed:"
    for step in $failed_steps
        echo -e " - $step"
    end
    set_color normal
else
    show_step "Maintenance Complete" brgreen "All maintenance tasks finished!"
    sleep 2
end
