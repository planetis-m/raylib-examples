const
  col1 = Color(r: 160, g: 154, b: 146, a: 255) # DustyGrey
  col2 = Color(r: 47, g: 88, b: 141, a: 255) # LightNavyBlue
  col3 = Color(r: 37, g: 47, b: 64, a: 255) # EbonyClay
  col4 = Color(r: 244, g: 220, b: 109, a: 255) # Goldenrod
  col5 = Color(r: 78, g: 131, b: 87, a: 255) # DarkSage

const
  ElfColor = col4
  GoblinColor = col5

const
  # Map used for testing
  MapWidth = 7 # Width in tiles
  MapHeight = 7 # Height in tiles
  # 2D array representing map tile IDs
  Map: array[MapWidth*MapHeight, int16] = [
    10, 10, 10, 2, 88, 88, 2,
    2, 146, 146, 146, 189, 146, 2,
    2, 189, 28, 146, 146, 210, 29,
    2, 146, 146, 129, 114, 146, 29,
    2, 210, 146, 146, 28, 209, 28,
    2, 146, 209, 146, 2, 146, 2,
    29, 28, 28, 29, 28, 2, 2
  ]
  # 2D array representing entity IDs on the map
  Entities: array[MapWidth*MapHeight, int16] = [
    0, 0, 0, 0, 0, 0, 0,
    0, 142, 0, 0, 0, 123, 0,
    0, 0, 0, 123, 0, 142, 0,
    0, 142, 0, 0, 0, 0, 0,
    0, 123, 0, 0, 0, 0, 0,
    0, 0, 0, 142, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0
  ]
  # 2D arrays representing foreground and background colors for each tile
  BgColors: array[MapWidth*MapHeight, Color] = [
    col3, col3, col3, col1, col3, col3, col1,
    col1, col3, col3, col3, col3, col3, col1,
    col1, col3, col2, col3, col3, col3, col2,
    col1, col3, col3, col1, col1, col3, col2,
    col1, col3, col3, col3, col2, col3, col2,
    col1, col3, col3, col3, col1, col3, col1,
    col2, col2, col2, col2, col2, col1, col1,
  ]
  FgColors: array[MapWidth*MapHeight, Color] = [
    col2, col2, col2, col2, col2, col2, col2,
    col2, col2, col2, col2, col1, col2, col2,
    col2, col1, col1, col2, col2, col2, col1,
    col2, col2, col2, col2, col2, col2, col1,
    col2, col2, col2, col2, col1, col2, col1,
    col2, col2, col2, col2, col2, col2, col2,
    col1, col1, col1, col1, col1, col2, col2,
  ]
  Walls: array[MapWidth*MapHeight, bool] = [
    true, true, true, true, true, true, true,
    true, false, false, false, false, false, true,
    true, false, true, false, false, false, true,
    true, false, false, true, true, false, true,
    true, false, false, false, true, false, true,
    true, false, false, false, true, false, true,
    true, true, true, true, true, true, true,
  ]
