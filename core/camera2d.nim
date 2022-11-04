# ***************************************************************************************
#
# raylib [core] example - 2d camera
#
# This example has been created using raylib 1.5 (www.raylib.com)
# raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
# Copyright (c) 2016 Ramon Santamaria (@raysan5)
# Converted in 2020 by bones527
# Adapted in 2021 by greenfork
#
# ***************************************************************************************

import raylib, std/[lenientops, random]

const
  MaxBuildings = 100

  screenWidth = 800
  screenHeight = 450

proc main =
  initWindow(screenWidth, screenHeight, "Camera 2D")

  var
    player = Rectangle(x: 400, y: 280, width: 40, height: 40)
    buildings: array[MaxBuildings, Rectangle]
    buildColors: array[MaxBuildings, Color]
    spacing: int32 = 0

  for i in 0 ..< MaxBuildings:
    buildings[i].width = rand(50..200).float32
    buildings[i].height = rand(100..800).float32
    buildings[i].y = screenHeight - 130 - buildings[i].height
    buildings[i].x = -6000'f32 + spacing

    spacing += buildings[i].width.int32

    buildColors[i] = Color(
      r: rand(200..240).uint8,
      g: rand(200..240).uint8,
      b: rand(200..240).uint8,
      a: 255.uint8
    )
  var camera = Camera2D(
    target: Vector2(x: player.x + 20, y: player.y + 20),
    offset: Vector2(x: screenWidth / 2'f32, y: screenHeight / 2'f32),
    rotation: 0,
    zoom: 1,
  )

  setTargetFPS(60)
  while not windowShouldClose():
    # Update
    # -----------------------------------------------------------------------------------
    # Player movement
    if isKeyDown(KeyRight): player.x += 2
    elif isKeyDown(KeyLeft): player.x -= 2
    # Camera target follows player
    camera.target = Vector2(x: player.x + 20, y: player.y + 20)
    # Camera rotation controls
    if isKeyDown(KeyA): camera.rotation -= 1
    elif isKeyDown(KeyS): camera.rotation += 1
    # Limit camera rotation to 80 degrees (-40 to 40)
    if camera.rotation > 40: camera.rotation = 40
    elif camera.rotation < -40: camera.rotation = -40
    # Camera zoom controls
    camera.zoom += getMouseWheelMove() * 0.05'f32
    if camera.zoom > 3: camera.zoom = 3
    elif camera.zoom < 0.1'f32: camera.zoom = 0.1'f32
    # Camera reset (zoom and rotation)
    if isKeyPressed(KeyR):
      camera.zoom = 1
      camera.rotation = 0
    # Draw
    # -----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground RayWhite
    beginMode2D camera
    drawRectangle -6000, 320, 13000, 8000, DarkGray
    for i in 0 ..< MaxBuildings:
      drawRectangleRec buildings[i], buildColors[i]
    drawRectangleRec player, Red
    drawLine camera.target.x.int32, -screenHeight * 10, camera.target.x.int32,
        screenHeight * 10, Green
    drawLine -screenWidth * 10, camera.target.y.int32, screenWidth * 10,
        camera.target.y.int32, Green
    endMode2D()
    drawText "SCREEN AREA", 640, 10, 20, Red
    drawRectangle 0, 0, screenWidth, 5, Red
    drawRectangle 0, 5, 5, screenHeight - 10, Red
    drawRectangle screenWidth - 5, 5, 5, screenHeight - 10, Red
    drawRectangle 0, screenHeight - 5, screenWidth, 5, Red
    drawRectangle 10, 10, 250, 113, fade(SkyBlue, 0.5)
    drawRectangleLines 10, 10, 250, 113, Blue
    drawText "Free 2d camera controls:", 20, 20, 10, Black
    drawText "- Right/Left to move Offset", 40, 40, 10, DarkGray
    drawText "- Mouse Wheel to Zoom in-out", 40, 60, 10, DarkGray
    drawText "- A / S to Rotate", 40, 80, 10, DarkGray
    drawText "- R to reset Zoom and Rotation", 40, 100, 10, DarkGray
    endDrawing()
  # De-Initialization
  # -------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context

main()
