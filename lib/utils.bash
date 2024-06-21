#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/containers/podman-desktop"
TOOL_NAME="podman-desktop"

fail() {
  echo -e "asdf-$TOOL_NAME: $*"
  exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if podman-desktop is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
  git ls-remote --tags --refs "$GH_REPO" |
    grep -o 'refs/tags/.*' | cut -d/ -f3- |
    grep '^v[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$' |
    sed -E 's/^v//g'
}

list_all_versions() {
  # TODO: Adapt this. By default we simply list the tag names from GitHub releases.
  # Change this function if podman-desktop has other means of determining installable versions.
  list_github_tags
}

# example url https://github.com/containers/podman-desktop/releases/download/v1.10.3/podman-desktop-1.10.3-universal.dmg
download_release() {
  local version filename url
  version="$1"
  filename="$2"

  # TODO: Adapt the release URL convention for podman-desktop
  url="$GH_REPO/releases/download/v${version}/podman-desktop-${version}-universal.dmg"

  echo "* Downloading $TOOL_NAME release $version..."
  curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
  local install_type="$1"
  local version="$2"
  local install_path="/Applications"
  local app_name="Podman Desktop.app"
  local installed_app="$install_path/$app_name"

  if [ "$install_type" != "version" ]; then
    fail "asdf-$TOOL_NAME supports release installs only"
  fi

  (

    find ~/.asdf/installs/podman-desktop -type d -depth 1 | grep -vF "$version" | xargs rm -rf
    cp -r "$ASDF_DOWNLOAD_PATH/$app_name" "$installed_app"

    local plist_path
    local plist_name
    local plist_version

    plist_path="$installed_app/Contents/Info.plist"
    plist_name=$(/usr/libexec/PlistBuddy -c "Print :CFBundleName" "$plist_path")
    plist_version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$plist_path")

    [[ "$plist_name" == "Podman Desktop" ]] && [[ "$plist_version" == "$version" ]]

    echo "$TOOL_NAME $version installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error occurred while installing $TOOL_NAME $version."
  )
}

# the docs say that no env vars are provided but I can see:
# ASDF_DIR=/opt/homebrew/opt/asdf/libexec
# ASDF_INSTALL_PATH=~/.asdf/installs/podman-desktop/1.10.3
# ASDF_INSTALL_TYPE=version
# ASDF_INSTALL_VERSION=1.10.3
# are available

uninstall_version() {
  local install_type="$1"
  local install_path="/Applications"
  local app_name="Podman Desktop.app"
  local installed_app="$install_path/$app_name"

  if [[ ! -e $installed_app ]]; then
    echo "$TOOL_NAME not found. Nothing left to do!"
    return 0
  fi

  local plist_path
  local plist_name
  local plist_version

  plist_path="$installed_app/Contents/Info.plist"
  plist_name=$(/usr/libexec/PlistBuddy -c "Print :CFBundleName" "$plist_path")
  plist_version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$plist_path")

  if [[ "$plist_name" == "Podman Desktop" ]];then
    echo "Uninstalling $TOOL_NAME ($app_name)..."
    rm -rf "$installed_app"
    # and any other version info bc again, only 1 version can exist
    rm -rf ~/.asdf/installs/podman-desktop

    echo "$TOOL_NAME $ASDF_INSTALL_VERSION removal was successful!"
    return 0
  else
    # you weren't supposed to be able to get here you know
    fail "Expected to find 'Podman Desktop' in $installed_app/Contents/Info.plist but got $plist_name"
  fi
}
