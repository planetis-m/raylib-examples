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

type
  State = enum
    BounceX, BounceZ, FadeOut, Reset

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
  var state = BounceX
  var framesCounter: int32 = 0
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    case state
    of BounceX:
      inc(framesCounter)
      ballPositionX = elasticOut(framesCounter.float32, -100, screenWidth / 2 + 100, 120).int32
      if framesCounter >= 120:
        framesCounter = 0
        state = BounceZ
    of BounceZ:             # Increase ball radius with easing
      inc(framesCounter)
      ballRadius = elasticIn(framesCounter.float32, 20, 500, 200).int32
      if framesCounter >= 200:
        framesCounter = 0
        state = FadeOut
    of FadeOut:             # Change ball alpha with easing (background color blending)
      inc(framesCounter)
      ballAlpha = cubicOut(framesCounter.float32, 0, 1, 200)
      if framesCounter >= 200:
        framesCounter = 0
        state = Reset
    of Reset:               # Reset state to play again
      if isKeyPressed(Enter):
        # Reset required variables to play again
        ballPositionX = -100
        ballRadius = 20
        ballAlpha = 0
        state = BounceX
    if isKeyPressed(R):
      framesCounter = 0
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    if state >= FadeOut:
      drawRectangle(0, 0, screenWidth, screenHeight, Green)
    drawCircle(ballPositionX, 200, ballRadius.float32, fade(Red, 1 - ballAlpha))
    if state == Reset:
      drawText("PRESS [ENTER] TO PLAY AGAIN!", 240, 200, 20, Black)
    endDrawing()
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context
  # --------------------------------------------------------------------------------------

main()
