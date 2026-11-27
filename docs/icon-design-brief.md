# Workshop icon design brief

## Goal

Improve the existing personal finance app with a small set of clear, consistent
icons. Start from the improved app and participants' feedback; rebuilding the
earlier interface is not part of this task. Inkscape is the suggested design
tool, with editable SVG deliverables.

## Pick a small first set

| Icon | Meaning to communicate | Current place to review |
|---|---|---|
| Income | Money received | Income shortcut and transaction rows |
| Expense | Money spent | Expense shortcut and transaction rows |
| Activity/history | Review recorded transactions | Bottom navigation |
| Edit | Correct a saved transaction | Transaction editor |
| Delete | Remove a saved entry deliberately | Editor and confirmation flow |
| Category | Group a transaction meaningfully | Category picker |

Choose two or three, rather than attempting every category at once. Ask whether
an icon adds meaning before adding decoration. Keep text labels, especially for
destructive actions. Avoid distinguishing Income/Expense only by color.

## Design constraints

- Test at small sizes such as 24, 32 and 48 pixels, not only zoomed in.
- Use a consistent artboard/viewBox and similar visual weight across the set.
- Check legibility against the app's dark background and light action buttons.
- Avoid tiny text and details that disappear on a phone.
- Keep shapes editable; avoid unnecessary embedded bitmap images or external
  linked resources in SVG files.
- If using text, consider converting a delivery copy to paths and retain the
  editable original. Check font licensing when redistributing font-dependent work.
- Preserve an original SVG even if a PNG preview is produced for review.

The current app uses navy panels, mint Income/action accents and coral Expense/
delete accents. Match the actual screens rather than assuming a new theme is
already being implemented.

## Finding icons versus drawing icons

If adapting an existing icon set, retain its source URL, author, license and any
required attribution. “Free to download” is not the same as permission to modify
and redistribute. Do not use image-search results as if they grant reuse rights.
Use original work when reuse terms are unclear.

This brief does not endorse a particular external icon pack. The group can bring
a candidate and review its license before selecting it.

## Suggested activity: 45–60 minutes

1. Spend 5–10 minutes reviewing the app and choosing the user problem.
2. Agree the meanings and style for two or three icons.
3. Sketch/draw or adapt licensed candidates in Inkscape.
4. Ask another participant to identify them at small size without hints.
5. Review a screenshot/mockup showing the candidate beside the current text label.
6. Revise and hand over the editable source plus a short usage/licensing note.

## Deliverables

For each icon, provide:

- A clearly named SVG, for example `income.svg` or `activity.svg`.
- A small PNG preview if helpful, with the export size recorded.
- Intended screen/action and a screenshot/mockup if available.
- Creator/contributors and license/source/attribution information.
- Any remaining concerns: ambiguous meaning, contrast, touch target or style.

Store the contribution in the agreed design branch/folder or attach it to a
GitHub issue. Do not place it directly in the live build without reviewing how
the framework loads assets. No icon assets are added by these preparation notes.

## Integration handoff

`ExpenseTracker/artwork.png` is the current app artwork. The app also draws rows
and controls directly using glGUI. Supplying SVG does not automatically enable
runtime SVG rendering or replace those controls.

The coding group should inspect the framework's supported artwork/texture
pipeline, decide what must be converted/embedded, place the asset in the proper
configuration, update the widget/drawing code, rebuild and test. Keep the SVG as
the source even when the runtime uses a generated raster/texture resource.

Agree the desired on-screen dimensions and tap target separately: a 24-pixel
icon does not mean its clickable area should be only 24 pixels wide.

## Review checklist

- [ ] A participant recognizes the intended meaning at small size.
- [ ] It matches the rest of the chosen set.
- [ ] It remains readable against the actual app colors.
- [ ] Text labels and delete confirmation still communicate the action.
- [ ] The SVG source is editable and self-contained.
- [ ] License and attribution information are recorded.
- [ ] Integration has a named owner and a separate Linux/Android check.
