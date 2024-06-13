# ****************************************************************************************
#
#   raylib [shapes] example - Vector Angle
#
#   Example originally created with raylib 1.0, last time updated with raylib 4.2
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2023 Ramon Santamaria (@raysan5)
#
# ****************************************************************************************

import raylib, raymath, std/[math, strformat]

const
  screenWidth = 800
  screenHeight = 450

type
  AngleMode = enum
    Angle, LineAngle

proc `not`(x: AngleMode): AngleMode = AngleMode(not x.bool)

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [math] example - vector angle")
  var v0 = Vector2(x: screenWidth div 2, y: screenHeight div 2)
  var v1 = Vector2(x: 100, y: 80)
  var v2 = Vector2() # Updated with mouse position
  var angle: float32 = 0 # Angle in degrees
  var angleMode: AngleMode = Angle
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    var startAngle: float32 = 0
    case angleMode
    of Angle:
      startAngle = -lineAngle(v0, v1).radToDeg
    of LineAngle:
      startAngle = 0
    v2 = getMousePosition()
    if isKeyPressed(Space):
      angleMode = not angleMode
    case angleMode
    of Angle:
      if isMouseButtonDown(Right):
        v1 = getMousePosition()
      # Calculate angle between two vectors, considering a common origin (v0)
      angle = angle(normalize(v1 - v0), normalize(v2 - v0)).radToDeg
    of LineAngle:
      # Calculate angle defined by a two vectors line, in reference to horizontal line
      angle = lineAngle(v0, v2).radToDeg
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(White)
    case angleMode
    of Angle:
      drawText("MODE: Angle between V1 and V2", 10, 10, 20, Black)
      drawLine(v0, v1, 2, Black)
      drawLine(v0, v2, 2, Red)
      drawCircleSector(v0, 40, startAngle, startAngle + angle, 32, fade(Green, 0.6))
    of LineAngle:
      drawText("MODE: Angle formed by line V1 to V2", 10, 10, 20, Black)
      drawLine(0, screenHeight div 2, screenWidth, screenHeight div 2, LightGray)
      drawLine(v0, v2, 2, Red)
      drawCircleSector(v0, 40, startAngle, startAngle - angle, 32, fade(Green, 0.6))
    drawText("v0", v0.x.int32, v0.y.int32, 10, DarkGray)
    # If the line from v0 to v1 would overlap the text, move it's position up 10
    if angleMode == Angle and (v0 - v1).y > 0:
      drawText("v1", v1.x.int32, v1.y.int32-10, 10, DarkGray)
    if angleMode == Angle and (v0 - v1).y < 0:
      drawText("v1", v1.x.int32, v1.y.int32, 10, DarkGray)
    # If angle mode 1, use v1 to emphasize the horizontal line
    if angleMode == LineAngle:
      drawText("v1", v0.x.int32+40, v0.y.int32, 10, DarkGray)
    # position adjusted by -10 so it isn't hidden by cursor
    drawText("v2", v2.x.int32-10, v2.y.int32-10, 10, DarkGray)
    drawText("Press SPACE to change MODE", 460, 10, 20, DarkGray)
    drawText(&"ANGLE: {angle:2.2f}", 10, 70, 20, Lime)
    endDrawing()
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context
  # --------------------------------------------------------------------------------------

main()
