# Reference

## Manifest schema

`assets.tsv` has four tab-separated columns.

| Position | Column | Required value |
| --- | --- | --- |
| 1 | `name` | Unique output name without `.png`; use dashes and no spaces |
| 2 | `ratio` | `16:9`, `3:2`, `1:1`, `4:5`, or `9:16` |
| 3 | `refs` | Comma-separated relative paths, or `-` |
| 4 | `prompt` | One image-generation instruction |

The first line can be a comment header:

```tsv
# name	ratio	refs	prompt
```

Blank lines and lines whose first column starts with `#` are ignored.

## Commands

Generate one asset:

```sh
./gen.sh NAME
```

Generate selected assets:

```sh
./gen.sh NAME [NAME...]
```

The script selects the named rows. It generates them in manifest order.

Generate every missing asset:

```sh
./gen.sh --all
```

Do not combine `--all` with names.

Select the draft model:

```sh
MODEL=google/gemini-3.1-flash-image ./gen.sh NAME
```

Select the final model explicitly:

```sh
MODEL=openai/gpt-image-2 ./gen.sh NAME
```

## Environment variables

| Variable | Required | Default | Meaning |
| --- | --- | --- | --- |
| `AI_GATEWAY_API_KEY` | Yes | None | Vercel AI Gateway credential |
| `MODEL` | No | `openai/gpt-image-2` | Approved image model route |

The script loads `.env` when that file exists. Do not commit `.env`.

## Supported models

| Model ID | Use | Quality argument |
| --- | --- | --- |
| `openai/gpt-image-2` | Final | `high` |
| `google/gemini-3.1-flash-image` | Draft | Omitted |

No other model ID is accepted.

## Dimensions

| Ratio | OpenAI dimensions | Gemini aspect ratio |
| --- | --- | --- |
| `16:9` | `1536x864` | `16:9` |
| `3:2` | `1536x1024` | `3:2` |
| `1:1` | `1024x1024` | `1:1` |
| `4:5` | `1024x1280` | `4:5` |
| `9:16` | `864x1536` | `9:16` |

## References

Use `-` when an asset has no reference.

Separate multiple reference paths with commas. Do not add spaces around commas.

```tsv
package-final	4:5	out/package-base.png,brand/approved-label.png	Put the design from the second reference on the blank package in the first reference.
```

The script emits one `-i PATH` argument for each reference. It preserves left-to-right order.

## Output behavior

The output path is `out/NAME.png`.

If the output exists, the script prints `skip NAME`. It does not call the model or replace the file.

After a successful generation, the script prints `made NAME`.

The script passes these fixed CLI options:

```text
image -q -n 1 --no-preview
```

The script also redirects standard input from `/dev/null`.

## Exit behavior

| Exit code | Condition |
| --- | --- |
| `0` | All selected assets were made or skipped |
| `64` | Usage error, unknown asset, or unsupported model |
| `65` | Unsupported ratio on the OpenAI route |
| `69` | `ai` is not installed |
| `78` | `AI_GATEWAY_API_KEY` is missing |
| Other nonzero | `ai` or another required command failed |

The first failure stops the batch. The script does not retry.

## Documentation note

This reference uses a writing style inspired by ASD Simplified Technical English. It does not claim ASD-STE100 compliance, certification, or affiliation.
