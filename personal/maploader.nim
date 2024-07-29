import std/[strutils, sequtils]

type
  Section = enum
    Colors,
    RaceColors,
    MapDimensions,
    TMap = "Map",
    TEntities = "Entities",
    TBgColors = "BgColors",
    TFgColors = "FgColors",
    TWalls = "Walls",

proc parseGameData*(filename: string): auto =
  var
    colors: seq[Color]
    elfColor, goblinColor: Color
    mapWidth, mapHeight: int
    map: seq[int16]
    entities: seq[int16]
    bgColors: seq[Color]
    fgColors: seq[Color]
    walls: seq[bool]
    currentSection = Colors
    count = 0
  for line in staticRead(filename).splitLines():
    inc count
    if line.startsWith('#'):
      currentSection = parseEnum[Section](line.substr(1).strip)
    elif line.len > 0:
      let parts = line.split(',').mapIt(it.strip)
      if parts.len < 2:
        echo "illformed data at ", count, ": ", line
      case currentSection
      of Colors:
        colors.add Color(
          r: parts[0].parseInt().uint8,
          g: parts[1].parseInt().uint8,
          b: parts[2].parseInt().uint8,
          a: 255
        )
      of RaceColors:
        case parts[0]
        of "Elf": elfColor = colors[parts[1].parseInt()]
        of "Goblin": goblinColor = colors[parts[1].parseInt()]
      of MapDimensions:
        case parts[0]
        of "Width": mapWidth = parts[1].parseInt()
        of "Height": mapHeight = parts[1].parseInt()
      of TMap:
        map.add(parts.mapIt(it.parseInt().int16))
      of TEntities:
        entities.add(parts.mapIt(it.parseInt().int16))
      of TBgColors:
        bgColors.add(parts.mapIt(colors[it.parseInt()]))
      of TFgColors:
        fgColors.add(parts.mapIt(colors[it.parseInt()]))
      of TWalls:
        walls.add(parts.mapIt(it.parseInt().bool))
  (elfColor, goblinColor, mapWidth, mapHeight,
   map, entities, bgColors, fgColors, walls)
