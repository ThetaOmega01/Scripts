#!/bin/bash

# Script to set up hibernation on Arch Linux with btrfs and zram
# Assumptions:
# - Root filesystem is btrfs
# - zram is already configured
# - swap subvolume is already created

set -e # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
  echo -e "${RED}[ERROR]${NC} $1"
  exit 1
}

# Prerequisites check
[[ $EUID -eq 0 ]] && error "Don't run as root. Use sudo when needed."
findmnt -n -o FSTYPE / | grep -q btrfs || error "Root filesystem must be btrfs."
swapon --show | grep -q zram || error "No zram swap found. Set up zram first."

log "=== Hibernation Setup ==="

# Get system info and swap size
RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
ZRAM_SIZE=$(swapon --show --noheadings | grep zram | awk '{print $3}' | head -1)
log "RAM: ${RAM_GB}GB, Zram: ${ZRAM_SIZE}"

echo "Swap file should be at least: zram + RAM size (current: ${ZRAM_SIZE} + ${RAM_GB}GB)"
read -p "Enter swap file size: " SWAP_SIZE
[[ -z "$SWAP_SIZE" ]] && error "Swap size cannot be empty"

# Create swap file
sudo btrfs filesystem mkswapfile --size "${SWAP_SIZE}" --uuid clear /swap/swapfile

# Get resume parameters
RESUME_UUID=$(sudo findmnt -no UUID -T /swap/swapfile)
RESUME_OFFSET=$(sudo btrfs inspect-internal map-swapfile -r /swap/swapfile)

log "Resume UUID: ${RESUME_UUID}, Offset: ${RESUME_OFFSET}"

# Configure fstab
log "Configuring /etc/fstab..."
grep -q "/swap/swapfile" /etc/fstab ||
  echo "/swap/swapfile none swap defaults,pri=0 0 0" | sudo tee -a /etc/fstab

# Configure systemd-boot kernel parameters
log "Configuring systemd-boot kernel parameters..."

CURRENT_CMDLINE=$(cat /etc/kernel/cmdline 2>/dev/null || echo "")
CURRENT_CMDLINE=$(echo "$CURRENT_CMDLINE" | sed 's/resume=[^ ]* //g; s/resume_offset=[^ ]* //g')
echo "${CURRENT_CMDLINE} resume=UUID=${RESUME_UUID} resume_offset=${RESUME_OFFSET}" |
  sudo tee /etc/kernel/cmdline >/dev/null

# Configure mkinitcpio
log "Configuring mkinitcpio..."
grep -q "HOOKS=.*resume" /etc/mkinitcpio.conf ||
  sudo sed -i 's/\(HOOKS=.*\)fsck/\1resume fsck/' /etc/mkinitcpio.conf

# Rebuild initramfs and enable swap
log "Rebuilding initramfs and enabling swap..."
sudo mkinitcpio -P
sudo swapon /swap/swapfile

# Verify and complete setup
log "=== Setup Complete ==="

echo -e "\n${BLUE}Current swap configuration:${NC}"
swapon --show

echo -e "\n${BLUE}Resume: UUID=${RESUME_UUID} Offset=${RESUME_OFFSET}${NC}"
echo -e "\n${BLUE}Kernel cmdline:${NC} $(cat /etc/kernel/cmdline)"

echo -e "\n${GREEN}Hibernation setup completed!${NC}"
echo -e "\n${YELLOW}Next steps:${NC}"
echo "1. Reboot: sudo reboot"
echo "2. Test: sudo systemctl hibernate"
echo "3. Debug: journalctl -b | grep -i hibernate"