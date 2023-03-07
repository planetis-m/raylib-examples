# ****************************************************************************************
#
#   raylib [core] examples - basic screen manager
#
#   NOTE: This example illustrates a very simple screen manager based on a states machines
#
#   Example originally created with raylib 4.0, last time updated with raylib 4.0
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2021-2022 Ramon Santamaria (@raysan5)
#   Converted to Nim by Antonis Geralis (@planetis-m) in 2022
#
# ****************************************************************************************

import raylib

# ----------------------------------------------------------------------------------------
# Types and Structures Definition
# ----------------------------------------------------------------------------------------

type
  GameScreen = enum
    Logo, Title, Gameplay, Ending

const
  screenWidth = 800
  screenHeight = 450

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [core] example - basic screen manager")
  defer: closeWindow() # Close window and OpenGL context
  var currentScreen: GameScreen = Logo
  # TODO: Initialize all required variables and load all required data here!
  var framesCounter: int32 = 0 # Useful to count frames
  setTargetFPS(60) # Set desired framerate (frames-per-second)
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    case currentScreen
    of Logo:
      # TODO: Update LOGO screen variables here!
      inc(framesCounter) # Count frames
      # Wait for 2 seconds (120 frames) before jumping to TITLE screen
      if framesCounter > 120:
        currentScreen = Title
    of Title:
      # TODO: Update TITLE screen variables here!
      # Press enter to change to GAMEPLAY screen
      if isKeyPressed(Enter) or isGestureDetected(Tap):
        currentScreen = Gameplay
    of Gameplay:
      # TODO: Update GAMEPLAY screen variables here!
      # Press enter to change to ENDING screen
      if isKeyPressed(Enter) or isGestureDetected(Tap):
        currentScreen = Ending
    of Ending:
      # TODO: Update ENDING screen variables here!
      # Press enter to return to TITLE screen
      if isKeyPressed(Enter) or isGestureDetected(Tap):
        currentScreen = Title
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    case currentScreen
    of Logo:
      # TODO: Draw LOGO screen here!
      drawText("LOGO SCREEN", 20, 20, 40, LightGray)
      drawText("WAIT for 2 SECONDS...", 290, 220, 20, Gray)
    of Title:
      # TODO: Draw TITLE screen here!
      drawRectangle(0, 0, screenWidth, screenHeight, Green)
      drawText("TITLE SCREEN", 20, 20, 40, DarkGreen)
      drawText("PRESS ENTER or TAP to JUMP to GAMEPLAY SCREEN", 120, 220, 20, DarkGreen)
    of Gameplay:
      # TODO: Draw GAMEPLAY screen here!
      drawRectangle(0, 0, screenWidth, screenHeight, Purple)
      drawText("GAMEPLAY SCREEN", 20, 20, 40, Maroon)
      drawText("PRESS ENTER or TAP to JUMP to ENDING SCREEN", 130, 220, 20, Maroon)
    of Ending:
      # TODO: Draw ENDING screen here!
      drawRectangle(0, 0, screenWidth, screenHeight, Blue)
      drawText("ENDING SCREEN", 20, 20, 40, DarkBlue)
      drawText("PRESS ENTER or TAP to RETURN to TITLE SCREEN", 120, 220, 20, DarkBlue)
    endDrawing()
    # ------------------------------------------------------------------------------------

main()
