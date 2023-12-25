set -e

# Gets all the non-draft and non-prerelease tags of a repo
get_all_tag_names() { (
	set -e

	local owner="$1"
	local repo="$2"

	for ((page = 1; ; page++)); do
		local versions=$(
			curl -s "https://api.github.com/repos/$owner/$repo/releases?per_page=100&page=$page" |
				jq -r 'sort_by(.published_at) | .[] | select(.prerelease==false and .draft==false) | .tag_name'
		)

		if [ -z "$versions" ]; then
			break
		fi

		echo "$versions"
	done
); }

# Returns a list of tags that the overlay is missing
get_missing_tags() { (
	set -e

	declare -A missingTags

	for tag in $(get_all_tag_names "onflow" "flow-cli"); do
		missingTags[$tag]="true"
	done

	for tag in $(get_all_tag_names "chris-de-leon" "flow-cli.nix"); do
		unset missingTags[$tag]
	done

	if [ -f "blacklist.txt" ]; then
		for tag in $(cat "blacklist.txt"); do
			unset missingTags[$tag]
		done
	fi

	echo "${!missingTags[@]}" | tr ' ' '\n' | sort -V
); }

# Creates releases for the missing tags
git checkout master
while read -r tag; do
	# Quits early if there are no missing tags
	if [ -z "$tag" ]; then
		echo "Up to date"
		break
	else
		echo "Processing $tag"
	fi

	# Updates releases.nix - if assets for the overlay are missing, then adds
	# the tag to a blacklist to avoid processing the same buggy version twice
	set +e
	bash ./update.sh "$tag"
	is_success=$?
	set -e

	# Creates a new release if the update was successful, otherwise updates
	# the blacklist
	if [ "$is_success" -eq 0 ]; then
		echo "Update was successful - creating release"
		git add ./flow-cli/releases.nix
		git commit -m "updates releases.nix for version $tag"
		git push
		git push --delete origin "$tag" || true
		gh release create "$tag" --title "Release $tag"
	else
		echo "Update was unsuccessful - updating blacklist"
		echo "$tag" >>"blacklist.txt"
		git add ./blacklist.txt
		git commit -m "updates blacklist.txt for version $tag"
		git push
	fi
done <<<$(get_missing_tags)
