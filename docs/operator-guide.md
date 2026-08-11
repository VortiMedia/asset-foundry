# Operator guide

Use this guide for daily Asset Foundry work.

## Daily workflow

1. Receive the asset request.

2. Convert each requested asset into one manifest row.

3. Present the batch names and estimated paid-call count.

4. Wait for batch confirmation.

5. Add only the confirmed rows to the manifest.

6. Run `./gen.sh` with exactly the confirmed names.

7. Show the output paths.

8. Wait for review.

Stop after the output is ready for review. Do not create a variant or retry unless the user requests a revision.

## Approve a batch

Use a concise approval statement:

```text
Batch: cafe-service-counter, ceramic-vessel-study
Estimated paid calls: 2
```

If an output already exists, note that the script will skip it. Do not count a known skip as a paid call.

Use named generation for normal work:

```sh
./gen.sh cafe-service-counter ceramic-vessel-study
```

The script processes selected assets in manifest order. The command argument order does not change manifest order.

Use `./gen.sh --all` only after the user explicitly approves every missing manifest asset.

## Select a model

Use `openai/gpt-image-2` for the default final asset:

```sh
./gen.sh cafe-service-counter
```

Use `google/gemini-3.1-flash-image` for an inexpensive draft:

```sh
MODEL=google/gemini-3.1-flash-image ./gen.sh cafe-service-counter
```

Treat a draft and a final asset as separate paid calls. Get approval before you create both.

## Create a revision

If the user requests a revision, create a new manifest row.

1. Keep the accepted or reviewed row unchanged.

2. Add a version suffix to the new name.

   ```text
   cafe-service-counter-v2
   ```

3. Put the user's specific feedback in the new prompt.

4. Confirm the revision as a new batch.

5. Generate only the revision name.

Do not overwrite an earlier output. Do not retry automatically after a failure.

## Use references

Put private reference files in `brand/`. Git ignores those files.

List multiple references in prompt order:

```tsv
product-package-final	4:5	out/product-package-base.png,brand/approved-label.png	Put the approved label from the second reference on the blank package in the first reference. Preserve the label exactly.
```

The script sends the base output first and the approved label second.

## Use a two-pass edit

Use two-pass work only after the user requests it.

1. Add a base asset with a blank target surface.

2. Add an edit asset after the base asset.

3. Put the base output first in the edit asset's `refs` field.

4. Put the approved reference file second.

5. Use `openai/gpt-image-2` for the edit.

6. Request both names in one command.

   ```sh
   MODEL=openai/gpt-image-2 ./gen.sh product-package-base product-package-final
   ```

Expected result: the base runs before the edit because the script follows manifest order.

Do not ask the model to recreate an approved design from memory. Do not use a separate overlay tool. For a revision, reference the clean base and the original approved file again.

## Handle failures

If a generation fails, the script stops at that asset. Earlier outputs remain in `out/`. Later assets do not run.

1. Read the command error.

2. Correct only the cause of the failure.

3. Report the remaining paid-call estimate.

4. Get approval before you run the batch again.

The script will skip earlier outputs on the next run.

## Documentation note

This guide uses a writing style inspired by ASD Simplified Technical English. It does not claim ASD-STE100 compliance, certification, or affiliation.
