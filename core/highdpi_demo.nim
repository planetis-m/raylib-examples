# *****************************************************************************************
#
#   raylib [core] example - highdpi demo
#
#   Example complexity rating: [★★☆☆] 2/4
#
#   Example originally created with raylib 5.0, last time updated with raylib 5.5
#
#   Example contributed by Jonathan Marler (@marler8997) and reviewed by Ramon Santamaria (@raysan5)
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2025 Jonathan Marler (@marler8997)
#
# ******************************************************************************************

import raylib, std/[strformat, lenientops]

const
  ScreenWidth = 800
  ScreenHeight = 450

proc drawTextCenter(text: string, x: int32, y: int32, fontSize: int32, color: Color) =
  let size = measureText(getFontDefault(), text, fontSize.float32, 3)
  let pos = Vector2(x: x.float32 - size.x/2, y: y.float32 - size.y/2)
  drawText(getFontDefault(), text, pos, fontSize.float32, 3, color)

proc main =
  # Initialization
  setConfigFlags(flags(WindowHighdpi, WindowResizable))
  initWindow(ScreenWidth, ScreenHeight, "raylib [core] example - highdpi demo")
  defer: closeWindow()
  setWindowMinSize(450, 450)

  var
    logicalGridDescY: int32 = 120
    logicalGridLabelY: int32 = logicalGridDescY + 30
    logicalGridTop: int32 = logicalGridLabelY + 30
    logicalGridBottom: int32 = logicalGridTop + 80
    pixelGridTop: int32 = logicalGridBottom - 20
    pixelGridBottom: int32 = pixelGridTop + 80
    pixelGridLabelY: int32 = pixelGridBottom + 30
    pixelGridDescY: int32 = pixelGridLabelY + 30
    cellSize: int32 = 50
    cellSizePx: float32

  setTargetFPS(60)

  # Main game loop
  while not windowShouldClose():
    # Update
    let monitorCount = getMonitorCount()

    if monitorCount > 1 and isKeyPressed(N):
      setWindowMonitor((getCurrentMonitor() + 1) mod monitorCount)

    let currentMonitor = getCurrentMonitor()
    let dpiScale = getWindowScaleDPI()
    cellSizePx = cellSize.float32 / dpiScale.x

    # Draw
    drawing():
      clearBackground(RayWhite)

      let windowCenter = getScreenWidth() div 2
      drawTextCenter(&"Dpi Scale: {dpiScale.x:.6f}", windowCenter, 30, 40, DarkGray)
      drawTextCenter(&"Monitor: {currentMonitor + 1}/{monitorCount} ([N] next monitor)", windowCenter, 70, 20, LightGray)
      drawTextCenter(&"Window is {getScreenWidth()} \"logical points\" wide", windowCenter, logicalGridDescY, 20, Orange)

      var odd = true
      var i = cellSize
      while i < getScreenWidth():
        if odd:
          drawRectangle(i, logicalGridTop, cellSize, logicalGridBottom - logicalGridTop, Orange)

        drawTextCenter(&"{i}", i, logicalGridLabelY, 10, LightGray)
        drawLine(i, logicalGridLabelY + 10, i, logicalGridBottom, Gray)
        i += cellSize
        odd = not odd

      odd = true
      const minTextSpace = 30
      var lastTextX = -minTextSpace
      var j = cellSize
      while j < getRenderWidth():
        let x = int32(j.float32 / dpiScale.x)
        if odd:
          drawRectangle(x, pixelGridTop, int32(cellSizePx), pixelGridBottom - pixelGridTop, Color(r: 0, g: 121, b: 241, a: 100))

        drawLine(x, pixelGridTop, int32(j.float32 / dpiScale.x), pixelGridLabelY - 10, Gray)

        if x - lastTextX >= minTextSpace:
          drawTextCenter(&"{j}", x, pixelGridLabelY, 10, LightGray)
          lastTextX = x
        j += cellSize
        odd = not odd

      drawTextCenter(&"Window is {getRenderWidth()} \"physical pixels\" wide", windowCenter, pixelGridDescY, 20, Blue)

      let text = "Can you see this?"
      let size = measureText(getFontDefault(), text, 20, 3)
      let pos = Vector2(x: getScreenWidth().float32 - size.x - 5, y: getScreenHeight().float32 - size.y - 5)
      drawText(getFontDefault(), text, pos, 20, 3, LightGray)

main()
