# Prompt recipes

Each recipe is one line. Replace the words in CAPITALS.

## Search queries

Search before you write a prompt. Use two to four concrete words for the subject and one for the light or mood.

    suburban street dusk
    brick row house front door
    empty office desk morning

Do not paste the generation prompt into a search. Photo libraries match tags, not sentences. If the first search finds nothing that fits, try one different wording before you generate.

## Structure

Write the prompt in this order:

    SUBJECT, SETTING, LIGHT, CAMERA, FINISH

Example:

    Handmade ceramic cup on a limestone counter, soft north window light, 50mm lens at table height, natural product photograph, no text

## Useful terms

| Goal | Add these terms |
| --- | --- |
| Natural photograph | `natural light`, `35mm lens`, `available light` |
| Matte surface | `matte finish`, `subtle texture`, `no gloss` |
| Controlled depth | `f/4`, `shallow depth of field` |
| Clean reference surface | `blank surface`, `no text`, `no markings` |

## Terms to avoid

Do not use `8k`, `ultra detailed`, `masterpiece`, or `hyperrealistic`. These terms can make an image look artificial.

## Recipes

### Product study

    Single PRODUCT on a SURFACE, LIGHT from DIRECTION, CAMERA POSITION, accurate materials, editorial product photograph, no text

### Interior

    Furnished ROOM with MATERIALS, window light from DIRECTION, wide-angle lens, natural interior photograph, no people, no logos

### Exterior

    BUILDING TYPE in WEATHER, TIME OF DAY light, eye-level 35mm lens, restrained architectural photograph, no people, no text

### Base surface

    SUBJECT with a blank TARGET SURFACE, no text, no markings, LIGHT, CAMERA, natural photograph

### Reference edit

Use the clean base output as the first reference. Use the approved reference file as the second reference.

    Put the approved design from the second reference on the blank TARGET SURFACE in the first reference. Place it at ALIGNMENT and SCALE. Follow the surface shape. Match the light and shadow. Preserve the design shape, colors, and wording exactly.

Name the exact surface, alignment, and scale. Reference-image placement can vary. Wait for the user to request a revision.

## Revise only when requested

| Problem | Action |
| --- | --- |
| Surface is too shiny | Add `matte finish`. |
| Reference is not sharp | Add `preserve the design shape exactly`. |
| Image looks artificial | Add `available light` and `subtle grain`. Remove quality terms. |
| Shape is wrong | Correct the manifest `ratio` before the next user-directed run. |

Do not retry automatically.
