#!/bin/sh

DIR="`cd "\`dirname "$0"\`" && pwd -P`"

echo ">>>> macOS start"

if [ `uname` != "Darwin" ]; then
  echo ">>>> you probably don't want to run this"
  echo ">>>> macOS end"
  exit 1
fi

# download packages

# check for developer tools and install if necessary
xcode-select -p > /dev/null
RET=$?
if [ $RET -ne 0 ]; then
  echo ">>>> installing xcode developer tools"
  xcode-select --install
fi

# check for homebrew and install if necessary
which brew > /dev/null
RET=$?
if [ $RET -ne 0 ]; then
  echo ">>>> installing homebrew"
  /bin/sh -c "`curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh`"
fi

# update to latest version of homebrew
echo ">>>> brew update"
brew update -v

# install bundle packages if some are missing
brew bundle check --file="$DIR/Brewfile" > /dev/null
RET=$?
if [ $RET -ne 0 ]; then
  echo ">>>> brew bundle install"
  brew bundle install -v --no-lock --file="$DIR/Brewfile"
fi

# clean up unnecessary files
echo ">>>> brew cleanup and remove cache"
brew cleanup -v -s
rm -rf `brew --cache`

# check for problems
echo ">>>> brew doctor"
brew doctor -v

# set system preferences
echo ">>>> configuring system preferences... reboot for effect"
sh "$DIR/defaults.sh"

# remap caps lock to escape
# https://developer.apple.com/library/archive/technotes/tn2450/_index.html
echo ">>>> installing caps lock -> esc launch agent"
ln -sfv "$DIR/local.RemapCapsLockToEsc.plist" ~/Library/LaunchAgents/

# hush login messages
echo ">>>> touch ~/.hushlogin"
touch ~/.hushlogin

# load terminal profile
echo ">>>> setting default terminal profile... quit Terminal.app for effect"
open "$DIR/brett.terminal"
defaults write com.apple.terminal "Default Window Settings" "brett"
defaults write com.apple.terminal "Startup Window Settings" "brett"

echo ">>>> macOS end"
