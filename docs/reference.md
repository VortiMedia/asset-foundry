# Reference

## Manifest schema

`assets.tsv` has four tab-separated columns.

| Position | Column | Required value |
| --- | --- | --- |
| 1 | `name` | Unique output name without extension; use dashes and no spaces |
| 2 | `ratio` | `16:9`, `3:2`, `1:1`, `4:5`, or `9:16` |
| 3 | `refs` | Comma-separated relative paths, or `-` |
| 4 | `prompt` | One image-generation instruction |

The first line can be a comment header:

```tsv
# name	ratio	refs	prompt
```

Blank lines and lines whose first column starts with `#` are ignored.

## Commands

### Search

```sh
./find.sh NAME QUERY...
```

The script searches Unsplash and Pexels for the query. It asks each library for up to six photos in the orientation of the asset ratio. It skips a library whose key is not set and names that library.

It replaces `out/candidates/NAME/` with:

| File | Content |
| --- | --- |
| `PICK.jpg` | One preview for each result |
| `candidates.tsv` | One row for each result, used by `--take` |
| `unsplash.json`, `pexels.json` | Raw search responses |

It prints one line for each result: pick, original size, photographer, and description. A `PICK` has the form `unsplash-ID` or `pexels-ID`.

| Ratio | Orientation | Long edge |
| --- | --- | --- |
| `16:9`, `3:2` | Landscape | Width |
| `1:1` | Square | Width |
| `4:5`, `9:16` | Portrait | Height |

### Take

```sh
./find.sh --take NAME PICK
```

The script downloads the photo with a long edge of at most 2400 pixels. It writes `out/NAME.jpg` and `out/NAME.credit.tsv`. For an Unsplash photo, it first counts the download through the Unsplash download endpoint, as the Unsplash API guidelines require.

If `out/NAME.jpg` or `out/NAME.png` exists, the script prints `skip NAME` and downloads nothing.

The credit file has one field for each line:

| Field | Content |
| --- | --- |
| `asset` | Asset name |
| `source` | `unsplash` or `pexels` |
| `pick` | Pick that was taken |
| `original_size` | Original pixel size |
| `credit` | `Photo by NAME on Unsplash` or `Photo by NAME on Pexels` |
| `photographer_url` | Photographer page with referral parameters |
| `page_url` | Photo page with referral parameters |
| `license` | License name and URL |
| `alt` | Library description, or `-` |
| `taken_at` | UTC time of the download |

### Generate

```sh
./gen.sh NAME [NAME...]
```

The script selects the named rows. It generates them in manifest order with `openai/gpt-image-2` at high quality.

Generate every missing asset:

```sh
./gen.sh --all
```

Do not combine `--all` with names.

## Environment variables

| Variable | Used by | Meaning |
| --- | --- | --- |
| `AI_GATEWAY_API_KEY` | `gen.sh` | Vercel AI Gateway credential; required to generate |
| `UNSPLASH_ACCESS_KEY` | `find.sh` | Unsplash application access key; free |
| `PEXELS_API_KEY` | `find.sh` | Pexels API key; free |

A search needs at least one library key. Taking a Pexels photo needs no key.

The scripts load `.env` when that file exists. Do not commit `.env`.

## Dimensions

| Ratio | Generated size |
| --- | --- |
| `16:9` | `1536x864` |
| `3:2` | `1536x1024` |
| `1:1` | `1024x1024` |
| `4:5` | `1024x1280` |
| `9:16` | `864x1536` |

## References

Use `-` when an asset has no reference.

Separate multiple reference paths with commas. Do not add spaces around commas.

```tsv
package-final	4:5	out/package-base.png,brand/approved-label.png	Put the design from the second reference on the blank package in the first reference.
```

The script emits one `-i PATH` argument for each reference. It preserves left-to-right order.

## Output behavior

A taken photo is `out/NAME.jpg`. A generated image is `out/NAME.png`.

If either output exists, `gen.sh` prints `skip NAME`. It does not call the model or replace the file.

After a successful generation, the script prints `made NAME`.

The script passes these fixed CLI options:

```text
image -q -n 1 --no-preview -m openai/gpt-image-2 --size SIZE --quality high
```

The script also redirects standard input from `/dev/null`.

## Exit behavior

| Exit code | `find.sh` | `gen.sh` |
| --- | --- | --- |
| `0` | Search listed results, or photo taken or skipped | All selected assets were made or skipped |
| `64` | Usage error, unknown asset, or unknown pick | Usage error or unknown asset |
| `65` | Unsupported ratio, or empty download | Unsupported ratio |
| `66` | Take before search | Not used |
| `69` | `curl` or `jq` is not installed | `ai` is not installed |
| `75` | One library failed; results from the other library are listed | Not used |
| `78` | No library key, or Unsplash key missing for an Unsplash take | `AI_GATEWAY_API_KEY` is missing |
| Other nonzero | `curl` failed | `ai` or another required command failed |

The first failure stops a generation batch. No script retries.

## Tests

```sh
tests/run.sh
```

The tests replace `curl` and `ai` with fakes. They make no network request and no paid call.

## Documentation note

This reference uses a writing style inspired by ASD Simplified Technical English. It does not claim ASD-STE100 compliance, certification, or affiliation.
