# Getting started

This guide installs Asset Foundry and creates one image asset.

## Terms

- **Asset:** One requested image and its manifest row.
- **Batch:** The asset names that the operator approves for one command.
- **Manifest:** The `assets.tsv` file that defines assets.
- **Reference:** An existing image that guides a generation.
- **Recipe:** A reusable prompt pattern.
- **Output:** A generated PNG file in `out/`.

Use one term for each concept. Do not use *job* or *task* when you mean *asset* or *batch*.

## Prerequisites

Install these items:

- Bash
- A current Node.js runtime with npm
- Git
- A Vercel account with AI Gateway access

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

Expected result: `.env` contains one secret and remains untracked.

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

6. Confirm a batch with one name and one estimated paid call.

## Generate the asset

Run this command only after batch confirmation:

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
