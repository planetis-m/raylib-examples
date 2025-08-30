# ****************************************************************************************
#
#   raylib [shaders] example - hot reloading
#
#   Example complexity rating: [★★★☆] 3/4
#
#   NOTE: This example requires raylib OpenGL 3.3 for shaders support and only #version 330
#         is currently supported. OpenGL ES 2.0 platforms are not supported at the moment
#
#   Example originally created with raylib 3.0, last time updated with raylib 3.5
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2020-2025 Ramon Santamaria (@raysan5)
#
# ****************************************************************************************

import raylib, rlgl, std/[os, times, strformat]

const
  ScreenWidth = 800
  ScreenHeight = 450

when defined(GraphicsApiOpenGl33):
  const GlslVersion = 330
else:  # Android, Web
  const GlslVersion = 100

proc main() =
  # Initialization
  initWindow(ScreenWidth, ScreenHeight, "raylib [shaders] example - hot reloading")
  defer: closeWindow()  # Important pattern in naylib

  let fragShaderFileName = &"resources/shaders/glsl{GlslVersion}/reload.fs"
  var fragShaderFileModTime = getLastModificationTime(fragShaderFileName)

  # Load raymarching shader
  # NOTE: Defining empty string ("") for vertex shader forces usage of internal default vertex shader
  var shader = loadShader("", fragShaderFileName)

  # Get shader locations for required uniforms
  var resolutionLoc = getShaderLocation(shader, "resolution")
  var mouseLoc = getShaderLocation(shader, "mouse")
  var timeLoc = getShaderLocation(shader, "time")

  let resolution: array[2, float32] = [ScreenWidth.float32, ScreenHeight.float32]
  setShaderValue(shader, resolutionLoc, resolution)

  var totalTime: float32 = 0.0
  var shaderAutoReloading = false

  setTargetFPS(60)

  # Main game loop
  while not windowShouldClose():
    # Update
    totalTime += getFrameTime()
    let mouse = getMousePosition()
    let mousePos: array[2, float32] = [mouse.x, mouse.y]

    # Set shader required uniform values
    setShaderValue(shader, timeLoc, totalTime)
    setShaderValue(shader, mouseLoc, mousePos)

    # Hot shader reloading
    if shaderAutoReloading or isMouseButtonPressed(Left):
      let currentFragShaderModTime = getLastModificationTime(fragShaderFileName)

      # Check if shader file has been modified
      if currentFragShaderModTime != fragShaderFileModTime:
        # Try reloading updated shader
        let updatedShader = loadShader("", fragShaderFileName)

        if updatedShader.id != getShaderIdDefault():  # It was correctly loaded
          shader = updatedShader

          # Get shader locations for required uniforms
          resolutionLoc = getShaderLocation(shader, "resolution")
          mouseLoc = getShaderLocation(shader, "mouse")
          timeLoc = getShaderLocation(shader, "time")

          # Reset required uniforms
          setShaderValue(shader, resolutionLoc, resolution)

        fragShaderFileModTime = currentFragShaderModTime

    if isKeyPressed(A):
      shaderAutoReloading = not shaderAutoReloading

    # Draw
    drawing():
      clearBackground(RayWhite)

      # We only draw a white full-screen rectangle, frame is generated in shader
      shaderMode(shader):
        drawRectangle(0, 0, ScreenWidth, ScreenHeight, White)

      drawText(&"PRESS [A] to TOGGLE SHADER AUTOLOADING: {(if shaderAutoReloading: \"AUTO\" else: \"MANUAL\")}",
               10, 10, 10, if shaderAutoReloading: Red else: Black)
      if not shaderAutoReloading:
        drawText("MOUSE CLICK to SHADER RE-LOADING", 10, 30, 10, Black)

      # Convert time to string for display
      let timeStr = fragShaderFileModTime.utc().format("ddd MMM dd HH:mm:ss yyyy")
      drawText(&"Shader last modification: {timeStr}", 10, 430, 10, Black)

main()
