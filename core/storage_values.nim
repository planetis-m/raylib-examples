# ***************************************************************************************
#
# raylib [textures] example - Texture loading and drawing a part defined by a rectangle
#
# This example has been created using raylib 1.3 (www.raylib.com)
# raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
# Copyright (c) 2015 Ramon Santamaria (@raysan5)
#
# ***************************************************************************************
import raylib, std/[random, lenientops, strutils]

const
  screenWidth = 800
  screenHeight = 450

type
  StorageData = uint32

# NOTE: Storage positions must start with 0, directly related to file memory layout
const
  PositionScore = StorageData(0)
  PositionHiscore = StorageData(1)

proc main =
  # Initialization
  # -------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [core] example - storage save/load values")

  var score = 0'i32
  var hiscore = 0'i32
  var framesCounter = 0

  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  #--------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    #------------------------------------------------------------------------------------
    if isKeyPressed(KeyR):
      score = rand(1000..2000).int32
      hiscore = rand(2000..4000).int32
    if isKeyPressed(KeyEnter):
      discard saveStorageValue(PositionScore, score)
      discard saveStorageValue(PositionHiscore, hiscore)
    elif isKeyPressed(KeySpace):
      # NOTE: If requested position could not be found, value 0 is returned
      score = loadStorageValue(PositionScore)
      hiscore = loadStorageValue(PositionHiscore)

    inc framesCounter
    # Draw
    # -------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    drawText(&"SCORE: {score}", 280, 130, 40, Maroon)
    drawText(&"HI-SCORE: {hiscore}", 210, 200, 50, Black)

    drawText(&"frames: {framesCounter}", 10, 10, 20, Lime)

    drawText("Press R to generate random numbers", 220, 40, 20, LightGray)
    drawText("Press ENTER to SAVE values", 250, 310, 20, LightGray)
    drawText("Press SPACE to LOAD values", 252, 350, 20, LightGray)
    endDrawing()

main()
