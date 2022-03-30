# ***************************************************************************************
#
# raylib [shaders] example - Texture Waves
#
# NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
#       OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
#
# NOTE: Shaders used in this example are #version 330 (OpenGL 3.3), to test this example
#       on OpenGL ES 2.0 platforms (Android, Raspberry Pi, HTML5), use #version 100 shaders
#       raylib comes with shaders ready for both versions, check raylib/shaders install folder
#
# This example has been created using raylib 2.5 (www.raylib.com)
# raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
# Example contributed by Anata (@anatagawa) and reviewed by Ramon Santamaria (@raysan5)
#
# Copyright (c) 2019 Anata (@anatagawa) and Ramon Santamaria (@raysan5)
#
# ***************************************************************************************

import raylib, std/strformat

const
  screenWidth = 800
  screenHeight = 450

when defined(PlatformDesktop):
  const
    glslVersion = 330
else:
  const
    glslVersion = 100 # PlatformRpi, PlatformAndroid, PlatformWeb

proc main =
  # Initialization
  # -------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [shaders] example - texture waves")
  defer: closeWindow() # Close window and OpenGL context

  # Load texture texture to apply shaders
  let texture = loadTexture("resources/space.png")

  # Load shader and setup location points and values
  let shader = loadShader("", &"resources/shaders/glsl{glslVersion}/wave.fs")
  let secondsLoc = getShaderLocation(shader, "secondes")
  let freqXLoc = getShaderLocation(shader, "freqX")
  let freqYLoc = getShaderLocation(shader, "freqY")
  let ampXLoc = getShaderLocation(shader, "ampX")
  let ampYLoc = getShaderLocation(shader, "ampY")
  let speedXLoc = getShaderLocation(shader, "speedX")
  let speedYLoc = getShaderLocation(shader, "speedY")

  # Shader uniform values that can be updated at any time
  var freqX = 25'f32
  var freqY = 25'f32
  var ampX = 5'f32
  var ampY = 5'f32
  var speedX = 8'f32
  var speedY = 8'f32

  var screenSize = [getScreenWidth().float32, getScreenHeight().float32]
  setShaderValue(shader, getShaderLocation(shader, "size"), screenSize)
  setShaderValue(shader, freqXLoc, freqX)
  setShaderValue(shader, freqYLoc, freqY)
  setShaderValue(shader, ampXLoc, ampX)
  setShaderValue(shader, ampYLoc, ampY)
  setShaderValue(shader, speedXLoc, speedX)
  setShaderValue(shader, speedYLoc, speedY)

  var seconds = 0'f32
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # Main game loop
  # -------------------------------------------------------------------------------------
  while not windowShouldClose(): #  Detect window close button or ESC key
    # Update
    # -----------------------------------------------------------------------------------
    seconds += getFrameTime()
    setShaderValue(shader, secondsLoc, seconds)
    # Draw
    # -----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    beginShaderMode(shader)
    drawTexture(texture, 0, 0, White)
    drawTexture(texture, texture.width, 0, White)
    endShaderMode()
    endDrawing()

main()
