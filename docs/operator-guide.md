# Operator guide

Use this guide for daily Asset Foundry work.

## Daily workflow

1. Receive the asset request.

2. Convert each requested asset into one manifest row.

3. Search the free libraries for each asset.

4. Take a real photo for each asset that has one that fits.

5. Present the remaining asset names and paid-call count.

6. Wait for batch confirmation.

7. Run `./gen.sh` with exactly the confirmed names.

8. Show the output paths.

9. Wait for review.

Stop after the output is ready for review. Do not create a variant or retry unless the user requests a revision.

## Search before you generate

A real photo that fits is better than a generated image. A search is free.

1. Search with two to four concrete words.

   ```sh
   ./find.sh cafe-service-counter cafe counter window light
   ```

   Expected result: one line for each result, then `found N for cafe-service-counter in out/candidates/cafe-service-counter/`.

2. Look at each preview in `out/candidates/cafe-service-counter/`.

3. Take the photo that fits.

   ```sh
   ./find.sh --take cafe-service-counter unsplash-aB1c2D3
   ```

   Expected result: `took cafe-service-counter out/cafe-service-counter.jpg (Photo by NAME on Unsplash)`.

A photo fits when the subject matches, the long edge is at least 2400 pixels, it has no readable text, logo, watermark, or prominent face that the request did not ask for, and its light suits the destination.

If no photo fits, try one different wording. If that search also finds nothing, generate the asset. Tell the user in one line why no photo fit.

Keep `out/NAME.credit.tsv` with a taken photo. It holds the credit line and license.

## Approve a batch

Use a concise approval statement:

```text
Batch: cafe-service-counter, ceramic-vessel-study
Estimated paid calls: 2
```

If an output already exists, note that the script will skip it. A taken photo is an output. Do not count a known skip as a paid call.

Use named generation for normal work:

```sh
./gen.sh cafe-service-counter ceramic-vessel-study
```

The script processes selected assets in manifest order. The command argument order does not change manifest order.

Use `./gen.sh --all` only after the user explicitly approves every missing manifest asset.

## Generate in one call

Generation uses `openai/gpt-image-2` at high quality. There is no draft step. Write the prompt with the recipe structure in `prompts/recipes.md` so that one call gives the final asset. If the result is wrong, the user requests a revision.

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

5. Request both names in one command.

   ```sh
   ./gen.sh product-package-base product-package-final
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
