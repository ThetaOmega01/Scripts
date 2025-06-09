#!/bin/bash

echo "Do you want to (d)isable or (r)estore macOS animations? [d/r]"
read -r choice

if [[ "$choice" =~ ^[Dd]$ ]]; then
  echo "Disabling macOS animations..."

  # Window animations
  defaults write -g NSAutomaticWindowAnimationsEnabled -bool false

  # Smooth scrolling
  defaults write -g NSScrollAnimationEnabled -bool false

  # Window resize speed
  defaults write -g NSWindowResizeTime -float 0.001

  # Quick Look animation
  defaults write -g QLPanelAnimationDuration -float 0

  # Rubber-band scrolling
  defaults write -g NSScrollViewRubberbanding -bool false

  # Dock animations
  defaults write com.apple.dock autohide-time-modifier -float 0
  defaults write com.apple.dock autohide-delay -float 0
  defaults write com.apple.dock expose-animation-duration -float 0

  # Finder animations
  defaults write com.apple.finder DisableAllAnimations -bool true

  # Mail send/reply animations
  defaults write com.apple.Mail DisableSendAnimations -bool true
  defaults write com.apple.Mail DisableReplyAnimations -bool true

  # Apply changes
  killall Dock
  killall Finder

  echo "Animations disabled. You may need to log out or restart for all changes to take effect."

elif [[ "$choice" =~ ^[Rr]$ ]]; then
  echo "Restoring default macOS animations..."

  # Window animations
  defaults delete -g NSAutomaticWindowAnimationsEnabled

  # Smooth scrolling
  defaults delete -g NSScrollAnimationEnabled

  # Window resize speed
  defaults delete -g NSWindowResizeTime

  # Quick Look animation
  defaults delete -g QLPanelAnimationDuration

  # Rubber-band scrolling
  defaults delete -g NSScrollViewRubberbanding

  # Dock animations
  defaults delete com.apple.dock autohide-time-modifier
  defaults delete com.apple.dock autohide-delay
  defaults delete com.apple.dock expose-animation-duration

  # Finder animations
  defaults delete com.apple.finder DisableAllAnimations

  # Mail send/reply animations
  defaults delete com.apple.Mail DisableSendAnimations
  defaults delete com.apple.Mail DisableReplyAnimations

  # Apply changes
  killall Dock
  killall Finder

  echo "Animations restored to default. You may need to log out or restart for all changes to take effect."

else
  echo "Invalid choice. Please run the script again and enter 'd' or 'r'."
  exit 1
fi
