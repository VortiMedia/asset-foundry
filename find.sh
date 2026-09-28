#!/usr/bin/env bash
# Search free photo libraries for a manifest asset, or take one result as its output.
set -euo pipefail

usage() {
  echo "Usage: ./find.sh NAME QUERY... | ./find.sh --take NAME PICK" >&2
}

project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
cd "$project_dir"

per_source=6
long_edge=2400
utm='utm_source=asset-foundry&utm_medium=referral'

take=false
if [[ ${1:-} == --take ]]; then
  take=true
  shift
  if (( $# != 2 )); then
    usage
    exit 64
  fi
elif (( $# < 2 )); then
  usage
  exit 64
fi

name=$1
shift

ratio=
while IFS=$'\t' read -r manifest_name manifest_ratio _; do
  case "$manifest_name" in ''|'#'*) continue ;; esac
  if [[ $manifest_name == "$name" ]]; then
    ratio=$manifest_ratio
    break
  fi
done < assets.tsv
if [[ -z $ratio ]]; then
  echo "error: unknown asset '$name'" >&2
  exit 64
fi

case "$ratio" in
  16:9|3:2) orientation=landscape unsplash_orientation=landscape dimension=w ;;
  1:1) orientation=square unsplash_orientation=squarish dimension=w ;;
  4:5|9:16) orientation=portrait unsplash_orientation=portrait dimension=h ;;
  *)
    echo "error: unsupported ratio '$ratio' for asset '$name'" >&2
    exit 65
    ;;
esac

for tool in curl jq; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "error: $tool is not installed" >&2
    exit 69
  fi
done

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

candidates_dir="out/candidates/$name"
candidates="$candidates_dir/candidates.tsv"

with_query() {
  local url=$1 query=$2
  if [[ $url == *'?'* ]]; then echo "$url&$query"; else echo "$url?$query"; fi
}

if [[ $take == true ]]; then
  pick=$1
  for existing in "out/$name.png" "out/$name.jpg"; do
    if [[ -f $existing ]]; then
      echo "skip $name ($existing exists)"
      exit 0
    fi
  done
  if [[ ! -f $candidates ]]; then
    echo "error: no candidates for '$name'; run ./find.sh $name QUERY first" >&2
    exit 66
  fi

  row=
  while IFS= read -r line; do
    [[ ${line%%$'\t'*} == "$pick" ]] && row=$line && break
  done < "$candidates"
  if [[ -z $row ]]; then
    echo "error: '$pick' is not a candidate for '$name'" >&2
    exit 64
  fi
  IFS=$'\t' read -r _ source width height photographer photographer_url page_url full_url download_location alt _ <<< "$row"

  case "$source" in
    unsplash)
      if [[ -z ${UNSPLASH_ACCESS_KEY:-} ]]; then
        echo "error: UNSPLASH_ACCESS_KEY is required to take an Unsplash photo" >&2
        exit 78
      fi
      auth="Authorization: Client-ID $UNSPLASH_ACCESS_KEY"
      image_url=$(with_query "$full_url" "fm=jpg&q=85&fit=max&$dimension=$long_edge")
      # Unsplash API guidelines: count the download through download_location.
      curl -fsS -H "$auth" -H 'Accept-Version: v1' -o /dev/null "$download_location"
      credit="Photo by $photographer on Unsplash"
      license='Unsplash License, https://unsplash.com/license'
      ;;
    pexels)
      image_url=$(with_query "$full_url" "auto=compress&cs=tinysrgb&$dimension=$long_edge")
      credit="Photo by $photographer on Pexels"
      license='Pexels License, https://www.pexels.com/license/'
      ;;
    *)
      echo "error: unknown source '$source' in $candidates" >&2
      exit 65
      ;;
  esac

  partial="out/$name.jpg.partial"
  curl -fsS -o "$partial" "$image_url" || {
    status=$?
    rm -f "$partial"
    echo "error: download failed for $pick" >&2
    exit "$status"
  }
  if [[ ! -s $partial ]]; then
    rm -f "$partial"
    echo "error: empty download for $pick" >&2
    exit 65
  fi
  mv "$partial" "out/$name.jpg"

  {
    printf 'asset\t%s\n' "$name"
    printf 'source\t%s\n' "$source"
    printf 'pick\t%s\n' "$pick"
    printf 'original_size\t%sx%s\n' "$width" "$height"
    printf 'credit\t%s\n' "$credit"
    printf 'photographer_url\t%s\n' "$(with_query "$photographer_url" "$utm")"
    printf 'page_url\t%s\n' "$(with_query "$page_url" "$utm")"
    printf 'license\t%s\n' "$license"
    printf 'alt\t%s\n' "$alt"
    printf 'taken_at\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  } > "out/$name.credit.tsv"

  echo "took $name out/$name.jpg ($credit)"
  exit 0
fi

query="$*"
encoded_query=$(jq -rn --arg q "$query" '$q | @uri')

if [[ -z ${UNSPLASH_ACCESS_KEY:-} && -z ${PEXELS_API_KEY:-} ]]; then
  echo "error: UNSPLASH_ACCESS_KEY or PEXELS_API_KEY is required" >&2
  echo "add a free key for either library to .env" >&2
  exit 78
fi

rm -rf "$candidates_dir"
mkdir -p "$candidates_dir"
: > "$candidates"
failed=0

# Each source writes rows: pick source width height photographer photographer_url page url download_location alt preview
search() {
  local source=$1 response=$2 filter=$3 header=$4 url=$5
  if ! curl -fsS -H "$header" -H 'Accept-Version: v1' -o "$response" "$url"; then
    echo "error: $source search failed; results below exclude $source" >&2
    failed=1
    return 0
  fi
  # Tab is IFS whitespace, so an empty field would shift columns; write "-" instead.
  jq -r "$filter | map(if . == null or . == \"\" then \"-\" else tostring end) | @tsv" "$response" >> "$candidates"
}

if [[ -n ${UNSPLASH_ACCESS_KEY:-} ]]; then
  search unsplash "$candidates_dir/unsplash.json" \
    '.results[] | ["unsplash-\(.id)", "unsplash", .width, .height, .user.name, .user.links.html, .links.html, .urls.raw, .links.download_location, .alt_description // .description, .urls.small]' \
    "Authorization: Client-ID $UNSPLASH_ACCESS_KEY" \
    "https://api.unsplash.com/search/photos?query=$encoded_query&per_page=$per_source&orientation=$unsplash_orientation&content_filter=high"
else
  echo "note: UNSPLASH_ACCESS_KEY is not set; Unsplash was not searched" >&2
fi

if [[ -n ${PEXELS_API_KEY:-} ]]; then
  search pexels "$candidates_dir/pexels.json" \
    '.photos[] | ["pexels-\(.id)", "pexels", .width, .height, .photographer, .photographer_url, .url, .src.original, "-", .alt, .src.medium]' \
    "Authorization: $PEXELS_API_KEY" \
    "https://api.pexels.com/v1/search?query=$encoded_query&per_page=$per_source&orientation=$orientation"
else
  echo "note: PEXELS_API_KEY is not set; Pexels was not searched" >&2
fi

count=0
while IFS=$'\t' read -r pick source width height photographer _ _ _ _ alt preview; do
  curl -fsS -o "$candidates_dir/$pick.jpg" "$preview"
  printf '%s\t%sx%s\t%s\t%s\n' "$pick" "$width" "$height" "$photographer" "$alt"
  count=$((count + 1))
done < "$candidates"

echo "found $count for $name in $candidates_dir/"
if (( failed )); then
  exit 75
fi
