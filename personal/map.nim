
const
  col00 = Black
  col01 = Color(r: 99, g: 42, b: 123, a: 255)
  col02 = Color(r: 194, g: 71, b: 184, a: 255)
  col03 = Color(r: 78, g: 61, b: 59, a: 255)
  col04 = Color(r: 84, g: 77, b: 84, a: 255)
  col05 = Color(r: 120, g: 108, b: 100, a: 255)
  col06 = Color(r: 160, g: 154, b: 146, a: 255)
  col07 = Color(r: 245, g: 238, b: 228, a: 255)
  col08 = Color(r: 100, g: 213, b: 223, a: 255)
  col09 = Color(r: 71, g: 143, b: 202, a: 255)
  col10 = Color(r: 47, g: 88, b: 141, a: 255)
  col11 = Color(r: 37, g: 47, b: 64, a: 255)
  col12 = Color(r: 99, g: 37, b: 14, a: 255)
  col13 = Color(r: 158, g: 50, b: 39, a: 255)
  col14 = Color(r: 216, g: 121, b: 69, a: 255)
  col15 = Color(r: 244, g: 220, b: 109, a: 255)
  col16 = Color(r: 137, g: 170, b: 85, a: 255)
  col17 = Color(r: 78, g: 131, b: 87, a: 255)
  col18 = Color(r: 56, g: 105, b: 86, a: 255)
  col19 = Color(r: 43, g: 74, b: 60, a: 255)
  col20 = Color(r: 233, g: 155, b: 124, a: 255)
  col21 = Color(r: 130, g: 83, b: 65, a: 255)

const
  MapWidth = 14
  MapHeight = 14
  Map: array[MapWidth*MapHeight, int16] = [
    1, 30, 86, 2, 171, 175, 175, 175, 175, 175, 175, 175, 175, 172,
    130, 2, 86, 2, 146, 16, 209, 146, 146, 146, 146, 210, 146, 30,
    113, 10, 10, 2, 114, 146, 146, 13, 114, 16, 146, 113, 28, 114,
    2, 36, 38, 36, 2, 47, 47, 227, 53, 146, 146, 245, 33, 34,
    2, 26, 86, 42, 245, 104, 104, 104, 104, 146, 209, 53, 146, 157,
    2, 26, 86, 42, 129, 146, 46, 146, 110, 146, 146, 214, 210, 173,
    2, 26, 86, 26, 196, 146, 46, 210, 146, 199, 246, 130, 146, 2,
    2, 26, 72, 26, 196, 55, 1, 1, 55, 245, 53, 53, 146, 2,
    2, 42, 72, 26, 196, 146, 110, 146, 146, 214, 53, 151, 146, 2,
    2, 26, 86, 26, 113, 137, 235, 146, 43, 217, 53, 215, 146, 2,
    2, 189, 86, 42, 28, 29, 28, 29, 197, 185, 53, 215, 209, 2,
    13, 26, 86, 42, 39, 53, 53, 53, 53, 53, 53, 167, 146, 2,
    13, 13, 145, 11, 11, 11, 250, 137, 235, 246, 200, 12, 11, 12,
    129, 2, 2, 2, 12, 2, 2, 2, 170, 2, 2, 2, 12, 11
  ]
  Entities: array[MapWidth*MapHeight, int16] = [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 123, 0,
    0, 0, 0, 0, 0, 142, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 142, 0, 0, 0,
    0, 142, 0, 0, 0, 123, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 142, 0, 0, 123, 0, 0, 0,
    0, 0, 0, 142, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 142, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 123, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  ]
  BgColors: array[MapWidth*MapHeight, Color] = [
    col11, col11, col11, col11, col11, col11, col11, col11, col11, col11, col11, col11, col11, col11,
    col06, col11, col11, col11, col11, col11, col11, col11, col11, col11, col11, col11, col11, col11,
    col11, col11, col11, col11, col11, col11, col11, col11, col11, col11, col11, col11, col05, col11,
    col11, col11, col11, col11, col06, col11, col11, col06, col05, col11, col11, col06, col11, col11,
    col11, col11, col11, col11, col06, col05, col05, col05, col05, col11, col11, col10, col11, col11,
    col11, col11, col11, col11, col11, col11, col11, col11, col11, col11, col11, col10, col11, col11,
    col11, col11, col11, col11, col11, col11, col11, col11, col11, col10, col10, col06, col11, col11,
    col11, col11, col11, col11, col11, col00, col00, col00, col00, col10, col00, col00, col11, col11,
    col11, col11, col11, col11, col11, col11, col11, col11, col11, col10, col00, col10, col11, col11,
    col11, col11, col11, col11, col11, col11, col11, col11, col11, col10, col00, col10, col11, col11,
    col11, col11, col11, col11, col10, col10, col10, col10, col10, col10, col00, col10, col11, col11,
    col05, col11, col11, col11, col11, col00, col00, col00, col00, col00, col00, col10, col11, col11,
    col05, col10, col10, col10, col10, col10, col10, col10, col10, col10, col10, col10, col10, col05,
    col11, col11, col11, col11, col05, col11, col11, col11, col06, col11, col11, col11, col05, col05,
  ]
  FgColors: array[MapWidth*MapHeight, Color] = [
    col00, col05, col04, col06, col05, col05, col05, col05, col05, col05, col05, col05, col05, col05,
    col11, col06, col04, col06, col10, col18, col10, col10, col10, col10, col10, col10, col10, col05,
    col06, col06, col06, col06, col06, col10, col10, col05, col06, col18, col10, col06, col06, col06,
    col06, col05, col05, col05, col06, col05, col05, col05, col06, col10, col10, col05, col05, col05,
    col06, col10, col04, col10, col05, col06, col06, col06, col06, col10, col10, col06, col10, col13,
    col06, col10, col04, col10, col06, col10, col04, col10, col04, col10, col10, col06, col10, col13,
    col06, col10, col04, col10, col05, col10, col04, col10, col10, col06, col06, col10, col10, col06,
    col06, col10, col07, col10, col05, col04, col10, col10, col04, col06, col11, col11, col10, col06,
    col06, col10, col07, col10, col05, col10, col04, col10, col10, col06, col11, col06, col10, col06,
    col06, col10, col04, col10, col06, col07, col07, col10, col04, col06, col11, col06, col10, col06,
    col06, col07, col04, col10, col06, col06, col06, col06, col06, col06, col11, col06, col10, col06,
    col06, col10, col04, col10, col06, col11, col11, col11, col11, col11, col11, col06, col10, col06,
    col06, col06, col06, col06, col06, col06, col07, col07, col07, col06, col06, col06, col06, col06,
    col06, col06, col06, col06, col06, col06, col06, col06, col07, col06, col06, col06, col06, col06,
  ]
  Walls: array[MapWidth*MapHeight, bool] = [
    true, true, true, true, true, true, true, true, true, true, true, true, true, true,
    true, true, true, true, false, false, false, false, false, false, false, false, false, true,
    true, true, true, true, true, false, false, true, true, false, false, true, true, true,
    true, true, true, true, true, true, true, true, true, false, false, true, true, true,
    true, false, false, false, true, true, true, true, true, false, false, true, false, true,
    true, false, false, false, true, false, true, false, false, false, false, true, false, true,
    true, false, false, false, true, false, true, false, false, true, true, true, false, true,
    true, false, true, false, true, false, true, true, false, true, false, false, false, true,
    true, false, true, false, true, false, false, false, false, true, false, true, false, true,
    true, false, false, false, true, true, true, false, true, true, false, true, false, true,
    true, false, false, false, true, true, true, true, true, true, false, true, false, true,
    true, false, false, false, false, false, false, false, false, false, false, true, false, true,
    true, true, true, true, true, true, true, true, true, true, true, true, true, true,
    true, true, true, true, true, true, true, true, true, true, true, true, true, true,
  ]
