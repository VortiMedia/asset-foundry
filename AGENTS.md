# Asset Foundry

This repository is a controlled, manifest-based workflow for explicitly requested image assets. It takes a free real photo when one fits and generates an image only when none does.

## Scope boundary

- Treat the user's asset request as a hard boundary.
- Create only the assets that the user explicitly requests.
- Add only the necessary `assets.tsv` rows and output files in `out/`.
- Do not add dependencies, helpers, variants, or unrelated cleanup.
- Take or generate one result for each requested asset. Do not retry or create variants automatically.
- Use a two-pass base-plus-reference workflow only when the user requests it.
- Preserve unrelated manifest rows, recipes, reference files, configuration, and work in progress.
- Stop after you verify the requested files and command result.

## Manifest

`assets.tsv` has four tab-separated columns:

| Column | Content |
| --- | --- |
| `name` | Output filename without extension |
| `ratio` | `16:9`, `3:2`, `1:1`, `4:5`, or `9:16` |
| `refs` | Comma-separated reference paths, or `-` for none |
| `prompt` | Image description for generation |

Keep names short and clear. Use dashes, not spaces. Preserve the TSV schema.

## Workflow

1. Add one manifest row for each requested asset.
2. Search the free libraries first: `./find.sh NAME QUERY...`. Use two to four concrete words. A search is free and needs no confirmation.
3. Look at every preview in `out/candidates/NAME/`.
4. Take a real photo when one fits: `./find.sh --take NAME PICK`. A fitting photo beats a generated image.
5. If no photo fits, say why in one line. Then present the paid batch: asset names and paid-call count.
6. Wait for the user to confirm the paid batch.
7. Run `./gen.sh NAME [NAME...]` with exactly those names. It skips any asset that already has a taken photo.
8. Show the output paths and, for a taken photo, its `out/NAME.credit.tsv`.
9. Wait for review.

A photo fits when all of these are true:

- The subject and setting match the request.
- The long edge in the listing is at least 2400 pixels.
- It has no readable text, logo, watermark, or prominent face, unless the request asks for one.
- Its light and palette suit the destination.

Use `./gen.sh --all` only when the user explicitly requests every missing asset.

Never call `ai image` directly. Never read or edit `.env`; the scripts load it internally.

To place an output in a Figma file, upload it with the Figma MCP `upload_assets` tool and pass the target node. Keep the credit file with a taken photo.

## Model

Generation uses `openai/gpt-image-2` at high quality. There is no draft model. Write the prompt well enough to get the asset in one call.

## Two-pass reference work

Use this workflow only when the user asks for it:

1. Generate a base scene with a blank target surface.
2. Add a second manifest row.
3. List the base output first in `refs`.
4. List the approved reference file second in `refs`.
5. Request both names together so that they run in manifest order.

Do not ask a model to recreate an approved mark from memory. Do not apply a mark with a separate compositing tool.

## Revisions and history

- Give each requested revision a new manifest row, such as `catalog-chair-v2`.
- For a reference revision, use the clean base and original approved reference again.
- Put the user's specific feedback in the revised prompt.
- Add only reusable prompting lessons to `prompts/recipes.md`.
- Commit accepted manifest and instruction changes only after review.
- Keep `out/` files ignored.

## Prompt recipes

Use `prompts/recipes.md` for search queries and prompt patterns. Draw exact diagrams as SVG. Use approved files for real company marks.

## Checks

Run `tests/run.sh` after a script change. It is offline and makes no paid call.
