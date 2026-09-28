#!/usr/bin/env bash
# Generate explicitly selected manifest assets in manifest order.
set -euo pipefail

usage() {
  echo "Usage: ./gen.sh NAME [NAME...] | ./gen.sh --all" >&2
}

project_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
cd "$project_dir"

if (( $# == 0 )); then
  usage
  exit 64
fi

generate_all=false
if [[ $1 == --all ]]; then
  if (( $# != 1 )); then
    echo "error: --all cannot be combined with asset names" >&2
    usage
    exit 64
  fi
  generate_all=true
fi

asset_exists() {
  local requested_name=$1
  local manifest_name remainder
  while IFS=$'\t' read -r manifest_name remainder; do
    case "$manifest_name" in ''|'#'*) continue ;; esac
    [[ $manifest_name == "$requested_name" ]] && return 0
  done < assets.tsv
  return 1
}

requested_names=("$@")
if [[ $generate_all == false ]]; then
  for requested_name in "${requested_names[@]}"; do
    if ! asset_exists "$requested_name"; then
      echo "error: unknown asset '$requested_name'" >&2
      exit 64
    fi
  done
fi

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

if [[ -z ${AI_GATEWAY_API_KEY:-} ]]; then
  echo "error: AI_GATEWAY_API_KEY is required" >&2
  echo "copy .env.example to .env and add a spend-capped Vercel AI Gateway key" >&2
  exit 78
fi

if ! command -v ai >/dev/null 2>&1; then
  echo "error: ai-cli is not installed; install ai-cli@0.4.3" >&2
  exit 69
fi

should_generate() {
  local manifest_name=$1
  local requested_name
  [[ $generate_all == true ]] && return 0
  for requested_name in "${requested_names[@]}"; do
    [[ $manifest_name == "$requested_name" ]] && return 0
  done
  return 1
}

mkdir -p out

while IFS=$'\t' read -r name ratio refs prompt; do
  case "$name" in ''|'#'*) continue ;; esac
  should_generate "$name" || continue

  output="out/$name.png"
  if [[ -f $output || -f out/$name.jpg ]]; then
    echo "skip $name"
    continue
  fi

  image_args=()
  if [[ $refs != - ]]; then
    IFS=',' read -r -a reference_paths <<< "$refs"
    for reference_path in "${reference_paths[@]}"; do
      image_args+=(-i "$reference_path")
    done
  fi

  case "$ratio" in
    16:9) size=1536x864 ;;
    3:2) size=1536x1024 ;;
    1:1) size=1024x1024 ;;
    4:5) size=1024x1280 ;;
    9:16) size=864x1536 ;;
    *)
      echo "error: unsupported ratio '$ratio' for asset '$name'" >&2
      exit 65
      ;;
  esac

  ai image -q -n 1 --no-preview -m openai/gpt-image-2 \
    --size "$size" --quality high ${image_args[@]+"${image_args[@]}"} \
    -o "$output" "$prompt" </dev/null
  echo "made $name"
done < assets.tsv
