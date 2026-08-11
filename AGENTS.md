# Asset Foundry

This repository is a controlled, manifest-based workflow for explicitly requested image assets.

## Scope boundary

- Treat the user's asset request as a hard boundary.
- Create only the assets that the user explicitly requests.
- Add only the necessary `assets.tsv` rows and generated files in `out/`.
- Do not add dependencies, helpers, variants, or unrelated cleanup.
- Generate one initial result for each requested asset. Do not retry or create variants automatically.
- Use a two-pass base-plus-reference workflow only when the user requests it.
- Preserve unrelated manifest rows, recipes, reference files, configuration, and work in progress.
- Stop after you verify the requested files and command result.

## Manifest

`assets.tsv` has four tab-separated columns:

| Column | Content |
| --- | --- |
| `name` | Output filename without `.png` |
| `ratio` | `16:9`, `3:2`, `1:1`, `4:5`, or `9:16` |
| `refs` | Comma-separated reference paths, or `-` for none |
| `prompt` | Image description |

Keep names short and clear. Use dashes, not spaces. Preserve the TSV schema.

## Workflow

1. Present one concise batch plan with the asset names and estimated paid-call count.
2. Wait for the user to confirm the batch.
3. Add only the confirmed asset rows to `assets.tsv`.
4. Run `./gen.sh NAME [NAME...]` with exactly those names.
5. Use `./gen.sh --all` only when the user explicitly requests every missing asset.
6. Show the output paths.
7. Wait for review.

Never call `ai image` directly. Never read or edit `.env`; `gen.sh` loads it internally.

## Approved models

| Model ID | Use |
| --- | --- |
| `openai/gpt-image-2` | Default final model |
| `google/gemini-3.1-flash-image` | Inexpensive draft model |

Set `MODEL` only to one of these exact IDs. OpenAI generations use high quality. Gemini generations omit the quality option.

## Two-pass reference work

Use this workflow only when the user asks for it:

1. Generate a base scene with a blank target surface.
2. Add a second manifest row.
3. List the base output first in `refs`.
4. List the approved reference file second in `refs`.
5. Use `openai/gpt-image-2` for the second pass.
6. Request both names together so that they run in manifest order.

Do not ask a model to recreate an approved mark from memory. Do not apply a mark with a separate compositing tool.

## Revisions and history

- Give each requested revision a new manifest row, such as `catalog-chair-v2`.
- For a reference revision, use the clean base and original approved reference again.
- Put the user's specific feedback in the revised prompt.
- Add only reusable prompting lessons to `prompts/recipes.md`.
- Commit accepted manifest and instruction changes only after review.
- Keep generated `out/` files ignored.

## Prompt recipes

Use `prompts/recipes.md` for local prompt patterns. Draw exact diagrams as SVG. Use approved files for real company marks.
