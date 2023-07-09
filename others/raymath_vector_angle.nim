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
    if isKeyPressed(Space):
      angleMode = not angleMode
    case angleMode
    of Angle:
      # Calculate angle between two vectors, considering a common origin (v0)
      v1 = v0 + Vector2(x: 100, y: 80)
      v2 = getMousePosition()
      angle = angle(normalize(v1 - v0), normalize(v2 - v0)).radToDeg
    of LineAngle:
      # Calculate angle defined by a two vectors line, in reference to horizontal line
      v1 = Vector2(x: screenWidth div 2, y: screenHeight div 2)
      v2 = getMousePosition()
      angle = lineAngle(v1, v2).radToDeg
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(White)
    if angleMode == Angle:
      drawText("v0", v0.x.int32, v0.y.int32, 10, DarkGray)
    drawText("v1", v1.x.int32, v1.y.int32, 10, DarkGray)
    drawText("v2", v2.x.int32, v2.y.int32, 10, DarkGray)
    case angleMode
    of Angle:
      drawText("MODE: Angle between V1 and V2", 10, 10, 20, Black)
      drawLine(v0, v1, 2, Black)
      drawLine(v0, v2, 2, Red)
      let startAngle = 90 - lineAngle(v0, v1).radToDeg
      drawCircleSector(v0, 40, startAngle, startAngle + angle - 360*float32(angle > 180), 32, fade(Green, 0.6))
    of LineAngle:
      drawText("MODE: Angle formed by line V1 to V2", 10, 10, 20, Black)
      drawLine(0, screenHeight div 2, screenWidth, screenHeight div 2, LightGray)
      drawLine(v1, v2, 2, Red)
      drawCircleSector(v1, 40, 90, 180 - angle - 90, 32, fade(Green, 0.6))
    drawText("Press SPACE to change MODE", 460, 10, 20, DarkGray)
    drawText(&"ANGLE: {angle:2.2f}", 10, 40, 20, Lime)
    endDrawing()
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context
  # --------------------------------------------------------------------------------------

main()
