# *******************************************************************************************
#
#   raylib [shapes] example - easings box anim
#
#   Example complexity rating: [★★☆☆] 2/4
#
#   Example originally created with raylib 2.5, last time updated with raylib 2.5
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2014-2025 Ramon Santamaria (@raysan5)
#
# ********************************************************************************************

import raylib, reasings, std/lenientops

const
  ScreenWidth = 800
  ScreenHeight = 450

proc main =
  # Initialization
  initWindow(ScreenWidth, ScreenHeight, "raylib [shapes] example - easings box anim")
  defer: closeWindow() # Close window and OpenGL context

  # Box variables to be animated with easings
  var
    rec = Rectangle(x: getScreenWidth()/2'f32, y: -100, width: 100, height: 100)
    rotation: float32 = 0
    alpha: float32 = 1
    state: int32 = 0
    framesCounter: int32 = 0

  setTargetFPS(60) # Set our game to run at 60 frames-per-second

  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    case state
    of 0: # Move box down to center of screen
      inc framesCounter

      # NOTE: Remember that 3rd parameter of easing function refers to
      # desired value variation, do not confuse it with expected final value!
      rec.y = elasticOut(float32(framesCounter), -100, getScreenHeight()/2'f32 + 100, 120)

      if framesCounter >= 120:
        framesCounter = 0
        state = 1

    of 1: # Scale box to an horizontal bar
      inc framesCounter
      rec.height = bounceOut(float32(framesCounter), 100, -90, 120)
      rec.width = bounceOut(float32(framesCounter), 100, float32(getScreenWidth()), 120)

      if framesCounter >= 120:
        framesCounter = 0
        state = 2

    of 2: # Rotate horizontal bar rectangle
      inc framesCounter
      rotation = quadOut(float32(framesCounter), 0, 270, 240)

      if framesCounter >= 240:
        framesCounter = 0
        state = 3

    of 3: # Increase bar size to fill all screen
      inc framesCounter
      rec.height = circOut(float32(framesCounter), 10, float32(getScreenHeight()), 120)

      if framesCounter >= 120:
        framesCounter = 0
        state = 4

    of 4: # Fade out animation
      inc framesCounter
      alpha = sineOut(float32(framesCounter), 1, -1, 160)

      if framesCounter >= 160:
        framesCounter = 0
        state = 5

    else: discard

    # Reset animation at any moment
    if isKeyPressed(Space):
      rec = Rectangle(x: getScreenWidth()/2'f32, y: -100, width: 100, height: 100)
      rotation = 0
      alpha = 1
      state = 0
      framesCounter = 0

    # Draw
    drawing():
      clearBackground(RayWhite)
      drawRectangle(rec, Vector2(x: rec.width/2'f32, y: rec.height/2'f32), rotation, fade(Black, alpha))
      drawText("PRESS [SPACE] TO RESET BOX ANIMATION!", 10, getScreenHeight() - 25, 20, LightGray)

main()
