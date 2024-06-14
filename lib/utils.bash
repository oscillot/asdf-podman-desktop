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
    grep '^v[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$'
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

delete_podman_app() {
  local install_path="/Applications"
  local app_name="Podman Desktop.app"
  local installed_app="$install_path/$app_name"

  if [[ ! -e $installed_app ]]; then
    echo "$TOOL_NAME not found. Are you sure it is installed?"
    exit 0
  fi

  echo "NOTICE: You can (should*) only have one version installed at a time. This will uninstall ANY version present."
  # get user feedback on what they want to do
  read -r -p "Do you wish to continue? [y/N] " response
  case "$response" in
    [yY][eE][sS] | [yY] | [√] )
      echo "Uninstalling $TOOL_NAME ($app_name)"
      ;;
    * )
      echo "Halting $TOOL_NAME uninstall. No changes have been made."
      exit 0
      ;;
  esac

  local plist_path
  local plist_name
  local plist_version

  plist_path="$installed_app/Contents/Info.plist"
  plist_name=$(/usr/libexec/PlistBuddy -c "Print :CFBundleName" "$plist_path")
  plist_version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$plist_path")

  if [[ "$plist_name" == "Podman Desktop" ]]; then
    rm -rf "$installed_app"

    echo "Removal of $TOOL_NAME ($app_name $plist_version) successful!"
    exit 0
  fi
}
