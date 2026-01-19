# *****************************************************************************************
#
#   raylib [core] example - highdpi testbed
#
#   Example complexity rating: [★☆☆☆] 1/4
#
#   Example originally created with raylib 5.6-dev, last time updated with raylib 5.6-dev
#
#   Example contributed by Ramon Santamaria (@raysan5) and reviewed by Ramon Santamaria (@raysan5)
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2025 Ramon Santamaria (@raysan5)
#
# ******************************************************************************************

import raylib, std/[strformat, lenientops]

const
  ScreenWidth = 800
  ScreenHeight = 450

proc main =
  # Initialization
  setConfigFlags(flags(WindowResizable, WindowHighdpi))
  initWindow(ScreenWidth, ScreenHeight, "raylib [core] example - highdpi testbed")
  defer: closeWindow()

  var
    scaleDpi = getWindowScaleDPI()
    mousePos = getMousePosition()
    currentMonitor = getCurrentMonitor()
    windowPos = getWindowPosition()
    gridSpacing: int32 = 40  # Grid spacing in pixels

  setTargetFPS(60)

  # Main game loop
  while not windowShouldClose():
    # Update
    mousePos = getMousePosition()
    currentMonitor = getCurrentMonitor()
    scaleDpi = getWindowScaleDPI()
    windowPos = getWindowPosition()

    if isKeyPressed(Space): toggleBorderlessWindowed()
    if isKeyPressed(F): toggleFullscreen()

    # Draw
    drawing():
      clearBackground(RayWhite)

      # Draw grid
      for h in 0 ..< getScreenHeight() div gridSpacing + 1:
        drawText(&"{h*gridSpacing:02}", 4, h*gridSpacing - 4, 10, Gray)
        drawLine(24, h*gridSpacing, getScreenWidth(), h*gridSpacing, LightGray)

      for v in 0 ..< getScreenWidth() div gridSpacing + 1:
        drawText(&"{v*gridSpacing:02}", v*gridSpacing - 10, 4, 10, Gray)
        drawLine(v*gridSpacing, 20, v*gridSpacing, getScreenHeight(), LightGray)

      # Draw UI info
      drawText(&"CURRENT MONITOR: {currentMonitor + 1}/{getMonitorCount()} ({getMonitorWidth(currentMonitor)}x{getMonitorHeight(currentMonitor)})", 50, 50, 20, DarkGray)
      drawText(&"WINDOW POSITION: {int32(windowPos.x)}x{int32(windowPos.y)}", 50, 90, 20, DarkGray)
      drawText(&"SCREEN SIZE: {getScreenWidth()}x{getScreenHeight()}", 50, 130, 20, DarkGray)
      drawText(&"RENDER SIZE: {getRenderWidth()}x{getRenderHeight()}", 50, 170, 20, DarkGray)
      drawText(&"SCALE FACTOR: {scaleDpi.x:.1f}x{scaleDpi.y:.1f}", 50, 210, 20, Gray)

      # Draw reference rectangles, top-left and bottom-right corners
      drawRectangle(0, 0, 30, 60, Red)
      drawRectangle(getScreenWidth() - 30, getScreenHeight() - 60, 30, 60, Blue)

      # Draw mouse position
      drawCircle(getMousePosition(), 20, Maroon)
      drawRectangle(int32(mousePos.x - 25), int32(mousePos.y), 50, 2, Black)
      drawRectangle(int32(mousePos.x), int32(mousePos.y - 25), 2, 50, Black)
      drawText(&"[{getMouseX()},{getMouseY()}]", int32(mousePos.x - 44),
        int32(if mousePos.y > getScreenHeight() - 60: mousePos.y - 46 else: mousePos.y + 30), 20, Black)

main()
