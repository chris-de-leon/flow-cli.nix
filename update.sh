set -e

# Defines the version to use for releases.nix
declare -r version="$1"

# Gets the URL to the flow-cli tarball
get_url() {
	local arch="$1"
	local tag="$2"
	echo "https://github.com/onflow/flow-cli/releases/download/$tag/flow-cli-$tag-$arch.tar.gz"
}

# Computes the nix sha256 hash
get_hash() {
	local arch="$1"
	local tag="$2"
	nix-shell -p nix-prefetch --run "nix-prefetch fetchzip --url \"$(get_url $arch $tag)\""
}

# Fetches hashes and urls for linux-amd64
declare -r url_x86_64_linux=$(get_url 'linux-amd64' "$version")
declare -r hash_x86_64_linux=$(get_hash 'linux-amd64' "$version")
if [ -z "$hash_x86_64_linux" ]; then exit 1; fi

# Fetches hashes and urls for linux-arm64
declare -r url_aarch64_linux=$(get_url 'linux-arm64' "$version")
declare -r hash_aarch64_linux=$(get_hash 'linux-arm64' "$version")
if [ -z "$hash_aarch64_linux" ]; then exit 1; fi

# Fetches hashes and urls for darwin-amd64
declare -r url_x86_64_darwin=$(get_url 'darwin-amd64' "$version")
declare -r hash_x86_64_darwin=$(get_hash 'darwin-amd64' "$version")
if [ -z "$hash_x86_64_darwin" ]; then exit 1; fi

# Fetches hashes and urls for darwin-arm64
declare -r url_aarch64_darwin=$(get_url 'darwin-arm64' "$version")
declare -r hash_aarch64_darwin=$(get_hash 'darwin-arm64' "$version")
if [ -z "$hash_aarch64_darwin" ]; then exit 1; fi

# Updates releases.nix
cat >./flow-cli/releases.nix <<EOF
{
  version = "$version";
  timestamp = "$(date -u +"%Y-%m-%dT%H:%M:%SZ")";
  sources = {
    "x86_64-linux" = {
      url = "$url_x86_64_linux";
      sha256 = "$hash_x86_64_linux";

    };
    "aarch64-linux" = {
      url = "$url_aarch64_linux";
      sha256 = "$hash_aarch64_linux";
    };
    "x86_64-darwin" = {
      url = "$url_x86_64_darwin";
      sha256 = "$hash_x86_64_darwin";
    };
    "aarch64-darwin" = {
      url = "$url_aarch64_darwin";
      sha256 = "$hash_aarch64_darwin";
    };
  };
}
EOF

# Updates flake.lock
nix flake update
