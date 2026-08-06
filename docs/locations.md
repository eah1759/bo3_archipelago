# Location IDs

Location ids have three parts: AABCC

- A refers to the map
- B refers to the location category
- C generally increments to keep ids unique

## Maps:

`0XXXX` is reserved for base game + first 4 dlc maps, with `09XXX` reserved specially for universal / non map specific locations.

- ` 1XXX`: The Giant
- ` 2XXX`: Castle
- ` 3XXX`: Shadows
- ` 4XXX`: Gorod
- ` 5XXX`: Zetsubou
- ` 6XXX`: Revelations
- ` 7XXX -  8XXX`: Unused
- ` 9XXX`: Universal

`1XXXX` is reserved for dlc 5 maps, aka Zombies Chronicles maps

- `10XXX`: Unused
- `11XXX`: Kino
- `12XXX`: Moon
- `13XXX`: Origins
- `14XXX`: Nacht
- `15XXX - 19XXX`: Unused

`2XXXX` and above are reserved for custom workshop maps

- `20XXX`: Wanted

## Location Categories:

These change on a per map basis, however there are a few consistent categories:

- `0XX`: Round locations from round 2 (001) to round 100 (099)
- `9XX`: Kill and Headshot checks

Other categories this digit can represent are as follows:

- Main EE
- Music EE
- Craftables / Buildables
- Side EEs
- Equipables
- Misc Locations
