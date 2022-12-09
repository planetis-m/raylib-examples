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

when defined(GraphicsApiOpenGl33):
  const
    glslVersion = 330
else:
  const
    glslVersion = 100

template sv(a): untyped = ShaderVariable(a)

proc main =
  # Initialization
  # -------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [shaders] example - texture waves")
  defer: closeWindow() # Close window and OpenGL context

  # Load texture texture to apply shaders
  let texture = loadTexture("resources/space.png")

  # Load shader and setup location points and values
  let shader = loadShader("", &"resources/shaders/glsl{glslVersion}/wave.fs")
  let secondsLoc = getShaderLocation(shader, sv"secondes")
  let freqXLoc = getShaderLocation(shader, sv"freqX")
  let freqYLoc = getShaderLocation(shader, sv"freqY")
  let ampXLoc = getShaderLocation(shader, sv"ampX")
  let ampYLoc = getShaderLocation(shader, sv"ampY")
  let speedXLoc = getShaderLocation(shader, sv"speedX")
  let speedYLoc = getShaderLocation(shader, sv"speedY")

  # Shader uniform values that can be updated at any time
  let freqX: float32 = 25
  let freqY: float32 = 25
  let ampX: float32 = 5
  let ampY: float32 = 5
  let speedX: float32 = 8
  let speedY: float32 = 8

  let screenSize = [getScreenWidth().float32, getScreenHeight().float32]
  setShaderValue(shader, getShaderLocation(shader, sv"size"), screenSize)
  setShaderValue(shader, freqXLoc, freqX)
  setShaderValue(shader, freqYLoc, freqY)
  setShaderValue(shader, ampXLoc, ampX)
  setShaderValue(shader, ampYLoc, ampY)
  setShaderValue(shader, speedXLoc, speedX)
  setShaderValue(shader, speedYLoc, speedY)

  var seconds: float32 = 0
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # Main game loop
  # -------------------------------------------------------------------------------------
  while not windowShouldClose(): # Detect window close button or ESC key
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
