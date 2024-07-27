import std/[strutils, sequtils]

type
  Section = enum
    Palette,
    RaceColors,
    MapDimensions,
    Map,
    Entities,
    BgColors,
    FgColors,
    Walls,

  GameData* = object
    colors: seq[Color]
    elfColor, goblinColor: Color
    mapWidth, mapHeight: int
    map: seq[int16]
    entities: seq[int16]
    bgColors: seq[Color]
    fgColors: seq[Color]
    walls: seq[bool]

proc parseGameData*(filename: string): GameData =
  result = GameData()
  var
    currentSection = Palette
    count = 0
  for line in lines(filename):
    inc count
    if line.startsWith("#"):
      currentSection = parseEnum[Section](line.substr(1).strip)
    elif line.len > 0:
      let parts = line.split(',').mapIt(it.strip)
      if parts.len < 2:
        echo "illformed data at ", count, ": ", line
      case currentSection
      of Palette:
        result.colors[parts[0].parseInt()] = Color(
          r: parts[1].parseInt().uint8,
          g: parts[2].parseInt().uint8,
          b: parts[3].parseInt().uint8,
          a: parts[4].parseInt().uint8
        )
      of RaceColors:
        case parts[0]
        of "Elf": result.elfColor = result.colors[parts[1].parseInt()]
        of "Goblin": result.goblinColor = result.colors[parts[1].parseInt()]
      of MapDimensions:
        case parts[0]
        of "Width": result.mapWidth = parts[1].parseInt()
        of "Height": result.mapHeight = parts[1].parseInt()
      of Map:
        result.map.add(parts.mapIt(it.parseInt().int16))
      of Entities:
        result.entities.add(parts.mapIt(it.parseInt().int16))
      of BgColors:
        result.bgColors.add(parts.mapIt(result.colors[it.parseInt()]))
      of FgColors:
        result.fgColors.add(parts.mapIt(result.colors[it.parseInt()]))
      of Walls:
        result.walls.add(parts.mapIt(it.parseInt().bool))

proc parseEntityLayer*(gameData: GameData): (Cells, Units) =
  var
    cells = newSeq[Cell](gameData.mapWidth*gameData.mapHeight)
    units: Units = @[]
    count = 0
  for i in 0 ..< cells.len:
    let (y, x) = divmod(i.int16, gameData.mapWidth.int16)
    cells[i] = Cell(
      position: (x, y),
      unit: NilUnitIdx,
      wall: gameData.walls[i]
    )
    case gameData.entities[i]
    of ElfTileIdx:
      units.add(Unit(race: Elf, cell: CellIdx(i), health: DefaultHealth))
      cells[i].unit = UnitIdx(count)
      inc count
    of GoblinTileIdx:
      units.add(Unit(race: Goblin, cell: CellIdx(i), health: DefaultHealth))
      cells[i].unit = UnitIdx(count)
      inc count
    else:
      discard # No unit is present
  (cells, units)
