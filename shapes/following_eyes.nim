# ****************************************************************************************
#
#   raylib [shapes] example - following eyes
#
#   Example complexity rating: [★★☆☆] 2/4
#
#   Example originally created with raylib 2.5, last time updated with raylib 2.5
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2013-2025 Ramon Santamaria (@raysan5)
#
# ****************************************************************************************

import raylib, std/[math, lenientops]

const
  ScreenWidth = 800
  ScreenHeight = 450

proc main =
  # Initialization
  initWindow(ScreenWidth, ScreenHeight, "raylib [shapes] example - following eyes")
  defer: closeWindow()  # Important pattern in naylib
  setTargetFPS(60)

  var
    scleraLeftPosition = Vector2(
      x: getScreenWidth()/2'f32 - 100, 
      y: getScreenHeight()/2'f32
    )
    scleraRightPosition = Vector2(
      x: getScreenWidth()/2'f32 + 100, 
      y: getScreenHeight()/2'f32
    )
    scleraRadius: float32 = 80

    irisLeftPosition = Vector2(
      x: getScreenWidth()/2'f32 - 100, 
      y: getScreenHeight()/2'f32
    )
    irisRightPosition = Vector2(
      x: getScreenWidth()/2'f32 + 100, 
      y: getScreenHeight()/2'f32
    )
    irisRadius: float32 = 24

  var
    angle: float32 = 0
    dx: float32 = 0
    dy: float32 = 0
    dxx: float32 = 0
    dyy: float32 = 0

  # Main game loop
  while not windowShouldClose():
    # Update
    irisLeftPosition = getMousePosition()
    irisRightPosition = getMousePosition()

    # Check not inside the left eye sclera
    if not checkCollisionPointCircle(irisLeftPosition, scleraLeftPosition, scleraRadius - irisRadius):
      dx = irisLeftPosition.x - scleraLeftPosition.x
      dy = irisLeftPosition.y - scleraLeftPosition.y

      angle = arctan2(dy, dx)

      dxx = (scleraRadius - irisRadius) * cos(angle)
      dyy = (scleraRadius - irisRadius) * sin(angle)

      irisLeftPosition.x = scleraLeftPosition.x + dxx
      irisLeftPosition.y = scleraLeftPosition.y + dyy

    # Check not inside the right eye sclera
    if not checkCollisionPointCircle(irisRightPosition, scleraRightPosition, scleraRadius - irisRadius):
      dx = irisRightPosition.x - scleraRightPosition.x
      dy = irisRightPosition.y - scleraRightPosition.y

      angle = arctan2(dy, dx)

      dxx = (scleraRadius - irisRadius) * cos(angle)
      dyy = (scleraRadius - irisRadius) * sin(angle)

      irisRightPosition.x = scleraRightPosition.x + dxx
      irisRightPosition.y = scleraRightPosition.y + dyy

    # Draw
    drawing():
      clearBackground(RayWhite)

      drawCircle(scleraLeftPosition, scleraRadius, LightGray)
      drawCircle(irisLeftPosition, irisRadius, Brown)
      drawCircle(irisLeftPosition, 10, Black)

      drawCircle(scleraRightPosition, scleraRadius, LightGray)
      drawCircle(irisRightPosition, irisRadius, DarkGreen)
      drawCircle(irisRightPosition, 10, Black)

      drawFPS(10, 10)

main()
