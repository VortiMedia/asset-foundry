# Getting started

This guide installs Asset Foundry and creates one image asset: a free real photo when one fits, or a generated image when none does.

## Terms

- **Asset:** One requested image and its manifest row.
- **Batch:** The asset names that the operator approves for one command.
- **Manifest:** The `assets.tsv` file that defines assets.
- **Reference:** An existing image that guides a generation.
- **Recipe:** A reusable prompt pattern.
- **Candidate:** One photo that a search found, with a preview in `out/candidates/NAME/`.
- **Output:** A taken photo (`out/NAME.jpg`) or a generated image (`out/NAME.png`).

Use one term for each concept. Do not use *job* or *task* when you mean *asset* or *batch*.

## Prerequisites

Install these items:

- Bash
- A current Node.js runtime with npm
- Git
- `curl` and `jq`
- A Vercel account with AI Gateway access
- A free Unsplash developer application, a free Pexels API key, or both

## Install the CLI

1. Install the pinned CLI.

   ```sh
   npm install --global ai-cli@0.4.3
   ```

2. Check the installed version.

   ```sh
   ai --version
   ```

Expected result: the command reports version `0.4.3`.

## Configure Vercel AI Gateway

1. Open the [Vercel AI Gateway key page](https://vercel.com/ai-gateway/api-keys).

2. Create one key for Asset Foundry.

3. Set a spend quota that matches your operating budget.

4. Disable automatic quota refresh when you need a fixed total cap.

5. Copy the environment template.

   ```sh
   cp .env.example .env
   ```

6. Put the gateway key in `.env`.

   ```dotenv
   AI_GATEWAY_API_KEY=your_gateway_key
   ```

Expected result: `.env` contains the gateway key and remains untracked.

## Add photo library keys

1. Create an application at [Unsplash Developers](https://unsplash.com/developers). Copy its access key.

2. Request a key at [Pexels API](https://www.pexels.com/api/).

3. Put the keys in `.env`.

   ```dotenv
   UNSPLASH_ACCESS_KEY=your_unsplash_access_key
   PEXELS_API_KEY=your_pexels_key
   ```

One key is enough to search. Both keys give more results.

Do not put a provider key in this repository. Do not commit `.env`.

## Define the first asset

1. Open `assets.tsv`.

2. Add one tab-separated row.

   ```tsv
   ceramic-vessel-study	1:1	-	Single handmade ceramic vessel on a warm white studio sweep, soft side light, editorial product photograph, no text
   ```

3. Check that the row has four columns.

4. Check that the ratio is supported.

5. Check that the asset name is unique.

## Search for a real photo

1. Search the libraries.

   ```sh
   ./find.sh ceramic-vessel-study handmade ceramic vase
   ```

   Expected result: one line for each result, then `found N for ceramic-vessel-study in out/candidates/ceramic-vessel-study/`.

2. Look at the previews.

3. If one fits, take it.

   ```sh
   ./find.sh --take ceramic-vessel-study PICK
   ```

   Expected result: `out/ceramic-vessel-study.jpg` and `out/ceramic-vessel-study.credit.tsv`. The asset is done.

## Generate the asset

Generate only when no photo fits. Confirm a batch with one name and one estimated paid call. Run this command only after batch confirmation:

```sh
./gen.sh ceramic-vessel-study
```

Expected terminal result:

```text
made ceramic-vessel-study
```

Expected file result:

```text
out/ceramic-vessel-study.png
```

If the output already exists, the command prints `skip ceramic-vessel-study`. It does not replace the file or make a paid call.

## Continue

Read the [Operator guide](operator-guide.md) before you run a multi-asset batch. Use the [Reference](reference.md) when you need exact command or exit behavior.

## Documentation note

This guide uses a writing style inspired by ASD Simplified Technical English. It does not claim ASD-STE100 compliance, certification, or affiliation.
