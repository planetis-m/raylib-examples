# ****************************************************************************************
#
#   raylib [core] example - window scale letterbox (and virtual mouse)
#
#   Example originally created with raylib 2.5, last time updated with raylib 4.0
#
#   Example contributed by Anata (@anatagawa) and reviewed by Ramon Santamaria (@raysan5)
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2019-2022 Anata (@anatagawa) and Ramon Santamaria (@raysan5)
#
# ****************************************************************************************

import raylib, raymath, std/[random, strformat, lenientops]

const
  windowWidth = 800
  windowHeight = 450

  gameScreenWidth = 640
  gameScreenHeight = 480

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Enable config flags for resizable window and vertical synchro
  setConfigFlags(flags(FlagWindowResizable, FlagVsyncHint))
  initWindow(windowWidth, windowHeight, "raylib [core] example - window scale letterbox")
  defer: closeWindow() # Close window and OpenGL context
  setWindowMinSize(320, 240)

  # Render texture initialization, used to hold the rendering result so we can easily resize it
  let target = loadRenderTexture(gameScreenWidth, gameScreenHeight)
  setTextureFilter(target.texture, TextureFilterBilinear) # Texture scale filter to use

  var colors: array[10, Color]
  for i in 0..colors.high:
    colors[i] = Color(
      r: rand(100'u8..250'u8),
      g: rand(50'u8..150'u8),
      b: rand(10'u8..100'u8),
      a: 255
    )

  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    # Compute required framebuffer scaling
    let scale = min(getScreenWidth().float32/gameScreenWidth, getScreenHeight().float32/gameScreenHeight)

    if isKeyPressed(KeySpace):
      # Recalculate random colors for the bars
      for i in 0..colors.high:
        colors[i] = Color(
          r: rand(100'u8..250'u8),
          g: rand(50'u8..150'u8),
          b: rand(10'u8..100'u8),
          a: 255
        )

    let mouse = getMousePosition()
    var virtualMouse = Vector2(
      x: clamp((mouse.x - (getScreenWidth() - (gameScreenWidth*scale))*0.5'f32)/scale, 0, gameScreenWidth),
      y: clamp((mouse.y - (getScreenHeight() - (gameScreenHeight*scale))*0.5'f32)/scale, 0, gameScreenHeight)
    )

    # Apply the same transformation as the virtual mouse to the real mouse (i.e. to work with raygui)
    # setMouseOffset(-(getScreenWidth() - (gameScreenWidth*scale))*0.5'f32, -(getScreenHeight() - (gameScreenHeight*scale))*0.5'f32)
    # setMouseScale(1/scale, 1/scale)
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    # Draw everything in the render texture, note this will not be rendered on screen, yet
    beginTextureMode(target)
    clearBackground(RayWhite) # Clear render texture background color
    for i in 0..colors.high:
      drawRectangle(0, (gameScreenHeight div 10)*i.int32, gameScreenWidth, gameScreenHeight div 10,
          colors[i])
    drawText("If executed inside a window,\nyou can resize the window,\nand see the screen scaling!",
        10, 25, 20, White)
    drawText(&"Default Mouse: [{mouse.x.int32}, {mouse.y.int32}]", 350, 25, 20, Green)
    drawText(&"Virtual Mouse: [{virtualMouse.x.int32}, {virtualMouse.y.int32}]", 350, 55, 20, Yellow)
    endTextureMode()

    beginDrawing()
    clearBackground(Black) # Clear screen background
    # Draw render texture to screen, properly scaled
    drawTexture(target.texture,
        Rectangle(
          x: 0,
          y: 0,
          width: target.texture.width.float32,
          height: -target.texture.height.float32
        ),
        Rectangle(
          x: (getScreenWidth() - (gameScreenWidth*scale))*0.5'f32,
          y: (getScreenHeight() - (gameScreenHeight*scale))*0.5'f32,
          width: gameScreenWidth*scale,
          height: gameScreenHeight*scale
        ),
        Vector2(x: 0, y: 0), 0, White)
    endDrawing()
    # ------------------------------------------------------------------------------------

main()
