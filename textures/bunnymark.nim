# ***************************************************************************************
#
# raylib [textures] example - Bunnymark
#
# This example has been created using raylib 1.6 (www.raylib.com)
# raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
# Copyright (c) 2014-2019 Ramon Santamaria (@raysan5)
# Converted in 2021 by greenfork
#
# ***************************************************************************************

import raylib, std/[lenientops, random, strformat]

const
  screenHeight = 450
  screenWidth = 800

const
  MaxBunnies = 50_000 # 50K bunnies limit

  # This is the maximum amount of elements (quads) per batch
  # NOTE: This value is defined in [rlgl] module and can be changed there
  MaxBatchElements = 8192

type
  Bunny = object
    position: Vector2
    speed: Vector2
    color: Color

proc main =
  # Initialization
  # -------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [textures] example - bunnymark")
  defer: closeWindow() # Close window and OpenGL context
  # Load bunny texture
  let texBunny = loadTexture("resources/wabbit_alpha.png")
  var bunnies = newSeq[Bunny](MaxBunnies) # Bunnies seq
  var bunniesCount = 0 # Bunnies counter
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # Main game loop
  # -------------------------------------------------------------------------------------
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # -----------------------------------------------------------------------------------
    if isMouseButtonDown(MouseButtonLeft):
      # Create more bunnies
      for i in 0..<100:
        if bunniesCount < MaxBunnies:
          bunnies[bunniesCount] = Bunny(
            position: getMousePosition(),
            speed: Vector2(
              x: rand(-250..250)/60'f32,
              y: rand(-250..250)/60'f32
            ),
            color: Color(
              r: rand(50'u8..240'u8),
              g: rand(80'u8..240'u8),
              b: rand(100'u8..240'u8),
              a: 255
            )
          )
          inc bunniesCount
    for i in 0..<bunniesCount:
      bunnies[i].position.x += bunnies[i].speed.x
      bunnies[i].position.y += bunnies[i].speed.y

      if bunnies[i].position.x + texBunny.width/2'f32 > getScreenWidth() or
          bunnies[i].position.x + texBunny.width/2'f32 < 0:
        bunnies[i].speed.x *= -1
      if bunnies[i].position.y + texBunny.height/2'f32 > getScreenHeight() or
          bunnies[i].position.y + texBunny.height/2'f32 - 40 < 0:
        bunnies[i].speed.y *= -1
    # Draw
    # -----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    for i in 0..<bunniesCount:
      # NOTE: When internal batch buffer limit is reached (MaxBatchElements),
      # a draw call is launched and buffer starts being filled again;
      # before issuing a draw call, updated vertex data from internal CPU buffer is send to GPU...
      # Process of sending data is costly and it could happen that GPU data has not been completely
      # processed for drawing while new data is tried to be sent (updating current in-use buffers)
      # it could generates a stall and consequently a frame drop, limiting the number of drawn bunnies
      drawTexture(texBunny, bunnies[i].position.x.int32, bunnies[i].position.y.int32, bunnies[i].color)
    drawRectangle(0, 0, screenWidth, 40, Black)
    drawText(&"bunnies: {bunniesCount}", 120, 10, 20, Green)
    drawText(&"batched draw calls: {1 + bunniesCount div MaxBatchElements}", 320, 10, 20, Maroon)
    drawFPS(10, 10)
    endDrawing()

main()
