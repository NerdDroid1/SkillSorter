# Skill Sorter - Friendly Auto Sort

A lightweight Project Zomboid Build 42 server-side/singleplayer Lua sorter that moves items from an input container into nearby category containers.

This version is designed to be player-friendly: players do not need to memorize exact capitalization or long category names. Crates can be named simply `Input`, `Food`, `Clothes`, `Mech`, etc.

## What it does

1. A player places items into an input container.
2. Every few seconds, the sorter scans near online players.
3. Items in the input container are categorized.
4. Matching items are moved into nearby destination containers.

Example:

- Name one crate: `Input`
- Name another crate: `Food`
- Name another crate: `Clothes`
- Name another crate: `Mech`
- Drop mixed loot into `Input`
- The server moves food/cookware into `Food`, clothing into `Clothes`, and vehicle/mechanics parts into `Mech`

## Build/version

- Project Zomboid Build 42 layout included
- Mod ID: `SkillSorter`
- Lua entry file: `42/media/lua/server/SkillSorterServer.lua`

## Container naming

The sorter is forgiving. These all work for the input container:

- `Input`
- `input`
- `INPUT`
- `Dump`
- `dump`
- `Sort:Input`
- `sort:input`
- `SORT:INPUT`
- `[Sort:Input]`
- `[sort:input]`
- `[SORT:INPUT]`

These all work for a Food container:

- `Food`
- `food`
- `FOOD`
- `Sort:Food`
- `sort:food`
- `[Sort:Food]`
- `[sort:food]`

The same rule applies to all categories and aliases.

## Recommended short crate names

Use these for the easiest player experience:

| Crate name | What goes there |
|---|---|
| `Input` | Drop-off container; items are sorted from here |
| `Food` | Food, cooking supplies, cookware, kitchen items, water containers |
| `Clothes` | Clothing, accessories, bags, backpacks, armor, protective gear, appearance items |
| `Mech` | Mechanics tools, vehicle maintenance, all vehicle build/body parts |
| `Weld` | Welding, metalworking, blacksmithing, raw metal, sheet metal, pipes, ingots, crucibles |
| `Agri` | Farming, gardening, seeds, crops, animals, animal parts, hides, bones, feed |
| `Books` | Books, maps, magazines, recipes, VHS/CD/media |
| `Med` | First aid and medical supplies |
| `Sew` | Tailoring, fabric, thread, needles, ripped sheets, strips |
| `Elec` | Electronics, communications, batteries, radios, light sources, security electronics |
| `Guns` | Firearms, ammo, weapon parts, explosives |
| `Weps` | Melee weapons and general weaponized tools |
| `Carp` | Carpentry, woodworking, planks, logs, nails, saws, hammers |
| `Surv` | Fishing, trapping, camping, fire-starting, survival gear |
| `Misc` | Catch-all for anything that does not match another category |

## Long category names also work

If players prefer descriptive names, these also work:

- `Mechanics`
- `Welding`
- `Agriculture`
- `FoodCooking`
- `Clothing`
- `BooksMedia`
- `Medical`
- `Tailoring`
- `Electrical`
- `Firearms`
- `WeaponsTools`
- `Carpentry`
- `Survival`
- `Misc`

## Category design

This build uses the PZwiki item list as a broad exact fallback map and combines categories for real base organization rather than one crate per wiki category.

Important combined categories:

- Food + cookware are combined into `Food`
- Clothing + accessories + bags + protective gear are combined into `Clothes`
- Farming + animals + animal parts are combined into `Agri`
- Vehicle maintenance + vehicle body/build parts are combined into `Mech`

This means doors, windows, seats, bumpers, hoods, tires, brakes, suspension, batteries, engine parts, and similar car-building items go into `Mech`.

## Priority rules

Some items could logically fit more than one place. The sorter uses ordered rules to keep things practical:

1. Vehicle-specific parts go to `Mech` before metal rules can send them to `Weld`.
2. Clothing/wearable/protective gear goes to `Clothes` before animal/leather rules can send it to `Agri`.
3. Books/maps/recipes go to `Books` before food or survival rules.
4. Food/cookware goes to `Food` before survival rules catch things like fish.
5. Firearms/ammo go to `Guns` before general weapon/tool rules.
6. Unmatched items go to `Misc`.

## Multiplayer notes

This mod can be installed as a normal Workshop mod. If a server lists the mod in `Mods=`, clients will be prompted to install it from Workshop like any other Project Zomboid mod.

If you instead run the Lua as a private server-only base-file injection, clients may fail checksum validation unless the server disables Lua checksum. For normal Workshop use, install it as a Workshop mod and include the Workshop ID in the server config.

## Server install notes for AMP / dedicated server

After publishing to Steam Workshop:

1. Add the Workshop ID to `WorkshopItems=`.
2. Add the Mod ID to `Mods=`:
   - `SkillSorter`
3. Restart the server.
4. Verify the latest server log shows the mod loading and the server reaches `*** SERVER STARTED ****`.

For AMP-managed Project Zomboid servers, edit `GenericModule.kvp` / `App.AppSettings`, not only the regenerated INI, because AMP rewrites the INI on startup.

## Folder layout

The packaged folder uses this layout:

```text
SkillSorterWorkshop/
  mods/
    SkillSorter/
      mod.info
      README.md
      SkillSorterServer.lua
      42/
        mod.info
        media/
          lua/
            server/
              SkillSorterServer.lua
```

The root `SkillSorterServer.lua` is included only for easy review. The Build 42 runtime file is under `42/media/lua/server/`.

## Known limitations

- The sorter only scans near online players.
- Destination containers should be near the `Input` container.
- Sorting happens periodically, not instantly.
- It does not create containers or labels automatically.
- It is intentionally simple and server-friendly; it does not include a client UI.

## Troubleshooting

### Nothing is moving

Check:

- Is one container named `Input`, `input`, `[Sort:Input]`, or similar?
- Are destination containers nearby?
- Is the player near the containers?
- Is there a destination container for the category? If not, the item will stay in input.
- Did the server load the mod after restart?

### Some items go to Misc

That is expected for rare or ambiguous items. Create a `Misc` crate near the input crate.

### Vehicle parts do not go to Mech

Use a `Mech` or `Mechanics` crate. Vehicle maintenance and body/build parts are intentionally combined into Mechanics.

### Players do not know names

Use the short names: `Input`, `Food`, `Clothes`, `Mech`, `Weld`, `Agri`, `Books`, `Med`, `Sew`, `Elec`, `Guns`, `Weps`, `Carp`, `Surv`, `Misc`.

## Workshop description short version

Player-friendly auto-sorting for Project Zomboid. Name one crate `Input`, then nearby crates `Food`, `Clothes`, `Mech`, `Weld`, `Agri`, etc. Drop mixed loot into Input and the server routes items into matching containers. Supports forgiving names like `Food`, `food`, `[Sort:Food]`, or `sort:food`. Combines practical categories such as food+cookware, clothes+bags+armor, animals+farming, and all vehicle parts into Mechanics.

## Credits

Built By Nerd Droid. 




## License

See `LICENSE.md`.
