# This mod likely will not be maintained

I no longer really play the game, so ongoing updates and fixes are unlikely.

# Gift Select All Pages

Selects all gift-eligible friends across every page, with Select None clearing the full selection.

<!-- drh:show -->
Selects all gift-eligible friends across every page, with Select None clearing the full selection.
- Select All includes eligible friends across every page, including the last entry.
- Select None clears the full selection and updates the current page.
- Respects the game's gift eligibility rules; gifts are sent through the normal controls.
<!-- /drh:show -->

The Friends tab shares its selection with other actions, including Remove. Choose the intended action after selecting friends.

## Requirements

Dungeon Rampage Haxe V17 and DRH Mod API 1.2 or a compatible later 1.x release. The launcher resolves the API dependency. This mod uses game internals and may need updates for later game releases.

## Installation

Install the release ZIP through the DRH Launcher Mods page. Do not use GitHub's automatic source-code ZIP as the release artifact.

To test a source checkout, run this from its repository folder with your launcher path:

```powershell
& "C:\Path\To\DRH-Launcher.com" --run-mod (Get-Location).Path
```

## Publishing

The included official workflow drafts a release when you push a `v<version>` tag matching `mod.json`. Test the generated ZIP before publishing the draft. Follow [Making a mod](https://github.com/Tutez64/Dungeon-Rampage-Haxe/blob/master/docs/making-a-mod.md) to submit the published release to the mod index.

## License

MIT. See [LICENSE](LICENSE).
