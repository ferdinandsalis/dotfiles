#!/usr/bin/env bash

# Revert script for macOS setup changes
set -e

echo "🔄 Reverting macOS system changes..."

# Revert General UI/UX changes
defaults delete NSGlobalDomain NSAutomaticCapitalizationEnabled 2>/dev/null || true
defaults delete NSGlobalDomain NSAutomaticDashSubstitutionEnabled 2>/dev/null || true
defaults delete NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled 2>/dev/null || true
defaults delete NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled 2>/dev/null || true
defaults delete NSGlobalDomain NSAutomaticSpellingCorrectionEnabled 2>/dev/null || true
defaults delete NSGlobalDomain ApplePressAndHoldEnabled 2>/dev/null || true
defaults delete NSGlobalDomain KeyRepeat 2>/dev/null || true
defaults delete NSGlobalDomain InitialKeyRepeat 2>/dev/null || true
defaults delete NSGlobalDomain AppleLanguages 2>/dev/null || true
defaults delete NSGlobalDomain AppleLocale 2>/dev/null || true
defaults delete NSGlobalDomain AppleMeasurementUnits 2>/dev/null || true
defaults delete NSGlobalDomain AppleMetricUnits 2>/dev/null || true

# Revert Finder changes
defaults delete com.apple.finder QuitMenuItem 2>/dev/null || true
defaults delete com.apple.finder DisableAllAnimations 2>/dev/null || true
defaults delete com.apple.finder NewWindowTarget 2>/dev/null || true
defaults delete com.apple.finder ShowExternalHardDrivesOnDesktop 2>/dev/null || true
defaults delete com.apple.finder ShowHardDrivesOnDesktop 2>/dev/null || true
defaults delete com.apple.finder ShowMountedServersOnDesktop 2>/dev/null || true
defaults delete com.apple.finder ShowRemovableMediaOnDesktop 2>/dev/null || true
defaults delete com.apple.finder AppleShowAllExtensions 2>/dev/null || true
defaults delete NSGlobalDomain AppleShowAllExtensions 2>/dev/null || true
defaults delete com.apple.finder ShowStatusBar 2>/dev/null || true
defaults delete com.apple.finder ShowPathbar 2>/dev/null || true
defaults delete com.apple.finder _FXShowPosixPathInTitle 2>/dev/null || true
defaults delete com.apple.finder _FXSortFoldersFirst 2>/dev/null || true
defaults delete com.apple.finder FXDefaultSearchScope 2>/dev/null || true
defaults delete com.apple.finder FXEnableExtensionChangeWarning 2>/dev/null || true
defaults delete NSGlobalDomain com.apple.springing.enabled 2>/dev/null || true
defaults delete NSGlobalDomain com.apple.springing.delay 2>/dev/null || true
defaults delete com.apple.desktopservices DSDontWriteNetworkStores 2>/dev/null || true
defaults delete com.apple.desktopservices DSDontWriteUSBStores 2>/dev/null || true
defaults delete com.apple.frameworks.diskimages skip-verify 2>/dev/null || true
defaults delete com.apple.frameworks.diskimages skip-verify-locked 2>/dev/null || true
defaults delete com.apple.frameworks.diskimages skip-verify-remote 2>/dev/null || true
defaults delete com.apple.frameworks.diskimages auto-open-ro-root 2>/dev/null || true
defaults delete com.apple.frameworks.diskimages auto-open-rw-root 2>/dev/null || true
defaults delete com.apple.finder OpenWindowForNewRemovableDisk 2>/dev/null || true

# Revert Dock changes
defaults delete com.apple.dock mouse-over-hilite-stack 2>/dev/null || true
defaults delete com.apple.dock tilesize 2>/dev/null || true
defaults delete com.apple.dock mineffect 2>/dev/null || true
defaults delete com.apple.dock minimize-to-application 2>/dev/null || true
defaults delete com.apple.dock enable-spring-load-actions-on-all-items 2>/dev/null || true
defaults delete com.apple.dock show-process-indicators 2>/dev/null || true
defaults delete com.apple.dock launchanim 2>/dev/null || true
defaults delete com.apple.dock expose-animation-duration 2>/dev/null || true
defaults delete com.apple.dock expose-group-by-app 2>/dev/null || true
defaults delete com.apple.dashboard mcx-disabled 2>/dev/null || true
defaults delete com.apple.dock dashboard-in-overlay 2>/dev/null || true
defaults delete com.apple.dock mru-spaces 2>/dev/null || true

# Revert Safari changes
defaults delete com.apple.Safari UniversalSearchEnabled 2>/dev/null || true
defaults delete com.apple.Safari SuppressSearchSuggestions 2>/dev/null || true
defaults delete com.apple.Safari WebKitTabToLinksPreferenceKey 2>/dev/null || true
defaults delete com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks 2>/dev/null || true
defaults delete com.apple.Safari ShowFullURLInSmartSearchField 2>/dev/null || true
defaults delete com.apple.Safari HomePage 2>/dev/null || true
defaults delete com.apple.Safari AutoOpenSafeDownloads 2>/dev/null || true
defaults delete com.apple.Safari ShowFavoritesBar 2>/dev/null || true
defaults delete com.apple.Safari IncludeInternalDebugMenu 2>/dev/null || true
defaults delete com.apple.Safari IncludeDevelopMenu 2>/dev/null || true
defaults delete com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey 2>/dev/null || true
defaults delete com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled 2>/dev/null || true
defaults delete com.apple.Safari WebKitJavaEnabled 2>/dev/null || true
defaults delete com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically 2>/dev/null || true
defaults delete com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled 2>/dev/null || true
defaults delete com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles 2>/dev/null || true
defaults delete com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically 2>/dev/null || true
defaults delete com.apple.Safari WebKitMediaPlaybackRequiresUserAction 2>/dev/null || true
defaults delete com.apple.Safari WebKitMediaPlaybackAllowsInline 2>/dev/null || true
defaults delete com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback 2>/dev/null || true
defaults delete com.apple.Safari SendDoNotTrackHTTPHeader 2>/dev/null || true
defaults delete com.apple.Safari InstallExtensionUpdatesAutomatically 2>/dev/null || true

# Revert Mail changes
defaults delete com.apple.mail DisableReplyAnimations 2>/dev/null || true
defaults delete com.apple.mail DisableSendAnimations 2>/dev/null || true
defaults delete com.apple.mail AddressesIncludeNameOnPasteboard 2>/dev/null || true
defaults delete com.apple.mail BundleCompatibilityVersion 2>/dev/null || true
defaults delete com.apple.mail DraftsViewerAttributes 2>/dev/null || true
defaults delete com.apple.mail NSUserKeyEquivalents 2>/dev/null || true
defaults delete com.apple.mail DisableInlineAttachmentViewing 2>/dev/null || true
defaults delete com.apple.mail SpellCheckingBehavior 2>/dev/null || true

# Revert Activity Monitor changes
defaults delete com.apple.ActivityMonitor OpenMainWindow 2>/dev/null || true
defaults delete com.apple.ActivityMonitor IconType 2>/dev/null || true
defaults delete com.apple.ActivityMonitor ShowCategory 2>/dev/null || true
defaults delete com.apple.ActivityMonitor SortColumn 2>/dev/null || true
defaults delete com.apple.ActivityMonitor SortDirection 2>/dev/null || true

# Revert other app changes
defaults delete com.apple.addressbook ABShowDebugMenu 2>/dev/null || true
defaults delete com.apple.DiskUtility DUDebugMenuEnabled 2>/dev/null || true
defaults delete com.apple.DiskUtility advanced-image-options 2>/dev/null || true
defaults delete com.apple.appstore WebKitDeveloperExtras 2>/dev/null || true
defaults delete com.apple.appstore ShowDebugMenu 2>/dev/null || true
defaults delete com.apple.ImageCapture disableHotPlug 2>/dev/null || true
defaults delete com.apple.messageshelper.MessageController SOInputLineSettings 2>/dev/null || true

# Reset sleep settings to defaults
echo "🔄 Resetting power management settings..."
sudo pmset -a displaysleep 1 2>/dev/null || true
sudo pmset -c sleep 1 2>/dev/null || true
sudo pmset -b sleep 5 2>/dev/null || true
sudo pmset -a lidwake 1 2>/dev/null || true
sudo pmset -a autorestart 0 2>/dev/null || true

# Restart affected applications
echo "🔄 Restarting affected applications..."
for app in "Activity Monitor" "Address Book" "Calendar" "cfprefsd" "Contacts" "Dock" "Finder" "Mail" "Messages" "Photos" "Safari" "SystemUIServer" "iCal"; do
	killall "${app}" &> /dev/null || true
done

echo "✅ macOS settings reverted to defaults"
echo "Note: Some changes may require a logout/restart to fully take effect."