# Contributing

Keep each change small and reviewable. Do not expand the project scope without prior agreement.

## Use project terms

Use these terms consistently:

| Term | Definition |
| --- | --- |
| Asset | One requested image and its manifest row |
| Batch | The asset names approved for one command |
| Manifest | The `assets.tsv` file |
| Reference | An existing image that guides generation |
| Recipe | A reusable prompt pattern |
| Output | A generated PNG in `out/` |

## Write documentation

- Use active voice.
- Use direct commands.
- Put one action in each numbered step.
- Put a condition before the action that depends on it.
- Put the expected result after a command.
- Prefer short sentences.
- Use one term for each concept.
- Do not claim ASD-STE100 compliance, certification, or affiliation.

This writing system is inspired by ASD Simplified Technical English only.

## Keep changes scoped

- Change only files that the contribution requires.
- Do not add a dependency for a task that Bash can already perform.
- Do not commit `.env`, output images, or private references.
- Do not add client names, client prompts, or client marks.
- Do not create generated examples for documentation.
- Do not change the manifest schema or command interface without prior discussion.

## Validate a change

1. Run the shell syntax check.

   ```sh
   bash -n gen.sh
   ```

2. Validate the Claude settings JSON.

   ```sh
   python3 -m json.tool .claude/settings.json >/dev/null
   ```

3. Check that each active manifest row has four tab-separated columns.

4. Check that each ratio is supported.

5. Check that each asset name is unique.

6. Check that each static reference path exists.

7. Test generation behavior with a fake `ai` executable.

8. Confirm that the test made no network request.

9. Check ignored files.

   ```sh
   git check-ignore .env out/example.png brand/private-reference.png
   ```

10. Inspect the staged diff for private or unrelated content.

Do not run a paid generation to validate a code or documentation change.
