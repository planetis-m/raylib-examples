import std/[strutils, sequtils, math]

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

  Color = object
    r, g, b, a: uint8

  CellIdx = distinct int32
  UnitIdx = distinct int32

  Race = enum
    Elf, Goblin

  Unit = object
    cell: CellIdx # Index of the cell the unit is on
    health: int16
    race: Race

  Cell = object
    position: tuple[x, y: int16]
    unit: UnitIdx # Index of the unit on the cell (if any)
    wall: bool # Is the cell a wall?

  Cells = seq[Cell]
  Units = seq[Unit]

  GameData* = object
    colors: seq[Color]
    elfColor, goblinColor: Color
    mapWidth, mapHeight: int
    map: seq[int16]
    entities: seq[int16]
    bgColors: seq[Color]
    fgColors: seq[Color]
    walls: seq[bool]

const
  NilUnitIdx = UnitIdx(-1) # Invalid unit index
  NilCellIdx = CellIdx(-1) # Invalid cell index

  ElfTileIdx = 142
  GoblinTileIdx = 123

  AttackPower = 3
  DefaultHealth = 200

proc parseGameData*(filename: string): GameData =
  result = GameData()
  var
    currentSection = Palette
    count = 0
  for line in lines(filename):
    inc count
    if line.startsWith('#'):
      currentSection = parseEnum[Section](line.substr(1).strip)
    elif line.len > 0:
      let parts = line.split(',').mapIt(it.strip)
      if parts.len < 2:
        echo "illformed data at ", count, ": ", line
      case currentSection
      of Palette:
        result.colors.add Color(
          r: parts[0].parseInt().uint8,
          g: parts[1].parseInt().uint8,
          b: parts[2].parseInt().uint8,
          a: 255
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

let data = parseGameData("map7.txt")
var (cells, units) = parseEntityLayer(data)
