# ****************************************************************************************
#
#   raylib [shapes] example - easings ball anim
#
#   Example originally created with raylib 2.5, last time updated with raylib 2.5
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2014-2022 Ramon Santamaria (@raysan5)
#
# ****************************************************************************************

import raylib, reasings

const
  screenWidth = 800
  screenHeight = 450

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [shapes] example - easings ball anim")
  # Ball variable value to be animated with easings
  var ballPositionX: int32 = -100
  var ballRadius: int32 = 20
  var ballAlpha: float32 = 0.0
  var state: int32 = 0
  var framesCounter: int32 = 0
  setTargetFPS(60)
  # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    if state == 0:
      inc(framesCounter)
      ballPositionX = elasticOut(framesCounter.float32, -100,
          screenWidth / 2 + 100, 120).int32
      if framesCounter >= 120:
        framesCounter = 0
        state = 1
    elif state == 1:             # Increase ball radius with easing
      inc(framesCounter)
      ballRadius = elasticIn(framesCounter.float32, 20, 500, 200).int32
      if framesCounter >= 200:
        framesCounter = 0
        state = 2
    elif state == 2:             # Change ball alpha with easing (background color blending)
      inc(framesCounter)
      ballAlpha = cubicOut(framesCounter.float32, 0, 1, 200)
      if framesCounter >= 200:
        framesCounter = 0
        state = 3
    elif state == 3:             # Reset state to play again
      if isKeyPressed(KeyEnter):
        # Reset required variables to play again
        ballPositionX = -100
        ballRadius = 20
        ballAlpha = 0.0
        state = 0
    if isKeyPressed(KeyR):
      framesCounter = 0
    beginDrawing()
    clearBackground(RayWhite)
    if state >= 2:
      drawRectangle(0, 0, screenWidth, screenHeight, Green)
    drawCircle(ballPositionX, 200, ballRadius.float32,
               fade(Red, 1.0 - ballAlpha))
    if state == 3:
      drawText("PRESS [ENTER] TO PLAY AGAIN!", 240, 200, 20, Black)
    endDrawing()
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow()
  # Close window and OpenGL context
  # --------------------------------------------------------------------------------------

main()
