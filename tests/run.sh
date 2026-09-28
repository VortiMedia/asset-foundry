#!/usr/bin/env bash
# Offline tests for find.sh and gen.sh. Fake curl and ai replace the network.
set -uo pipefail

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

passed=0
failed=0
check() {
  local label=$1
  shift
  if "$@"; then
    passed=$((passed + 1))
  else
    failed=$((failed + 1))
    echo "FAIL: $label" >&2
  fi
}

mkdir -p "$work/bin" "$work/repo"
cp "$repo/find.sh" "$repo/gen.sh" "$work/repo/"
printf '# name\tratio\trefs\tprompt\nstreet-hero\t16:9\t-\tQuiet suburban street at dusk\ndoor-portrait\t4:5\t-\tFront door with brass hardware\nplan-b\t3:2\t-\tSomething no library has\n' > "$work/repo/assets.tsv"

cat > "$work/bin/curl" <<'FAKE'
#!/usr/bin/env bash
out=/dev/stdout url= headers=
while (( $# )); do
  case "$1" in
    -o) out=$2; shift ;;
    -H) headers="$headers[$2]"; shift ;;
    http*) url=$1 ;;
  esac
  shift
done
echo "$url $headers" >> "$FAKE_LOG"
case "$url" in
  https://api.unsplash.com/search/*)
    [[ -n ${FAIL_UNSPLASH:-} ]] && exit 22
    cat > "$out" <<'JSON'
{"results":[
 {"id":"aB1_c-2","width":6000,"height":4000,"alt_description":"street at dusk","description":null,
  "user":{"name":"Ada Lane","links":{"html":"https://unsplash.com/@ada"}},
  "links":{"html":"https://unsplash.com/photos/aB1_c-2","download_location":"https://api.unsplash.com/photos/aB1_c-2/download?ixid=x"},
  "urls":{"raw":"https://images.unsplash.com/photo-1?ixid=x","small":"https://images.unsplash.com/photo-1?w=400"}},
 {"id":"zz9","width":5000,"height":3000,"alt_description":null,"description":null,
  "user":{"name":"Bo Chen","links":{"html":"https://unsplash.com/@bo"}},
  "links":{"html":"https://unsplash.com/photos/zz9","download_location":"https://api.unsplash.com/photos/zz9/download"},
  "urls":{"raw":"https://images.unsplash.com/photo-2?ixid=y","small":"https://images.unsplash.com/photo-2?w=400"}}
]}
JSON
    ;;
  https://api.pexels.com/*)
    cat > "$out" <<'JSON'
{"photos":[{"id":2014422,"width":4000,"height":5000,"url":"https://www.pexels.com/photo/door-2014422/",
 "photographer":"Cy Diaz","photographer_url":"https://www.pexels.com/@cy","alt":"",
 "src":{"original":"https://images.pexels.com/photos/2014422/pexels-photo-2014422.jpeg","medium":"https://images.pexels.com/photos/2014422/m.jpeg"}}]}
JSON
    ;;
  https://api.unsplash.com/photos/*) echo '{}' > "$out" ;;
  https://images.pexels.com/photos/*/pexels-photo-*)
    [[ -n ${FAIL_DOWNLOAD:-} ]] && { printf 'PART' > "$out"; exit 22; }
    printf 'JPEG' > "$out"
    ;;
  *) printf 'JPEG' > "$out" ;;
esac
FAKE
cat > "$work/bin/ai" <<'FAKE'
#!/usr/bin/env bash
echo "ai $*" >> "$FAKE_LOG"
while (( $# )); do [[ $1 == -o ]] && printf 'PNG' > "$2"; shift; done
FAKE
chmod +x "$work/bin/curl" "$work/bin/ai"

export PATH="$work/bin:$PATH" FAKE_LOG="$work/log"
cd "$work/repo" || exit 1
run() { : > "$FAKE_LOG"; env -u UNSPLASH_ACCESS_KEY -u PEXELS_API_KEY -u AI_GATEWAY_API_KEY "$@" > "$work/stdout" 2> "$work/stderr"; }
has() { grep -q -- "$2" "$1"; }

# Search both libraries.
run UNSPLASH_ACCESS_KEY=u PEXELS_API_KEY=p ./find.sh street-hero quiet street dusk
check "search exits 0" test $? -eq 0
check "search lists 3 candidates" has "$work/stdout" "found 3 for street-hero"
check "empty alt does not shift columns" has "$work/stdout" $'unsplash-zz9\t5000x3000\tBo Chen\t-$'
check "previews saved" test -s out/candidates/street-hero/unsplash-aB1_c-2.jpg -a -s out/candidates/street-hero/pexels-2014422.jpg
check "query is URL-encoded" has "$FAKE_LOG" "query=quiet%20street%20dusk"
check "16:9 asks Unsplash for landscape" has "$FAKE_LOG" "orientation=landscape&content_filter=high"
check "Unsplash key sent as Client-ID" has "$FAKE_LOG" "Authorization: Client-ID u"

# One key only.
run PEXELS_API_KEY=p ./find.sh door-portrait front door
check "one key is enough" test $? -eq 0
check "missing key is named" has "$work/stderr" "UNSPLASH_ACCESS_KEY is not set"
check "4:5 asks Pexels for portrait" has "$FAKE_LOG" "orientation=portrait"

# No keys, unknown asset, failed source.
run ./find.sh street-hero street
check "no keys exits 78" test $? -eq 78
run PEXELS_API_KEY=p ./find.sh nope street
check "unknown asset exits 64" test $? -eq 64
run FAIL_UNSPLASH=1 UNSPLASH_ACCESS_KEY=u PEXELS_API_KEY=p ./find.sh plan-b street
check "failed source exits 75" test $? -eq 75
check "failed source is named" has "$work/stderr" "unsplash search failed"
check "other source still listed" has "$work/stdout" "found 1 for plan-b"

# Take an Unsplash photo.
run UNSPLASH_ACCESS_KEY=u ./find.sh --take street-hero unsplash-aB1_c-2
check "take exits 0" test $? -eq 0
check "photo saved" test -s out/street-hero.jpg
check "download counted with key" has "$FAKE_LOG" "photos/aB1_c-2/download?ixid=x \[Authorization: Client-ID u\]"
check "full size requested" has "$FAKE_LOG" "photo-1?ixid=x&fm=jpg&q=85&fit=max&w=2400"
check "credit recorded" has out/street-hero.credit.tsv $'credit\tPhoto by Ada Lane on Unsplash'
check "credit link has UTM" has out/street-hero.credit.tsv "unsplash.com/@ada?utm_source=asset-foundry"
check "no partial left" test ! -e out/street-hero.jpg.partial

run UNSPLASH_ACCESS_KEY=u ./find.sh --take street-hero unsplash-zz9
check "second take skips" has "$work/stdout" "skip street-hero"
run PEXELS_API_KEY=p ./find.sh --take door-portrait pexels-999
check "unknown pick exits 64" test $? -eq 64

# A failed download leaves nothing behind.
run FAIL_DOWNLOAD=1 ./find.sh --take door-portrait pexels-2014422
check "failed download exits with curl status" test $? -eq 22
check "failed download leaves no output" test ! -e out/door-portrait.jpg -a ! -e out/door-portrait.jpg.partial

# Take a Pexels portrait: long edge is height.
run ./find.sh --take door-portrait pexels-2014422
check "Pexels take needs no key" test $? -eq 0
check "portrait sized by height" has "$FAKE_LOG" "pexels-photo-2014422.jpeg?auto=compress&cs=tinysrgb&h=2400"
check "empty alt stored as dash" has out/door-portrait.credit.tsv $'alt\t-'

# gen.sh falls back only where no photo was taken.
run AI_GATEWAY_API_KEY=g ./gen.sh street-hero plan-b
check "gen exits 0" test $? -eq 0
check "taken photo is skipped" has "$work/stdout" "skip street-hero"
check "ai called once" test "$(grep -c '^ai ' "$FAKE_LOG")" -eq 1
check "gpt-image-2 at high quality" has "$FAKE_LOG" "-m openai/gpt-image-2 --size 1536x1024 --quality high"
check "generated output saved" test -s out/plan-b.png

echo "$passed passed, $failed failed"
(( failed == 0 ))
