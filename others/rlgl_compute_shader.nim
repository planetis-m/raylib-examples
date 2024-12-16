# ****************************************************************************************
#
#   raylib [rlgl] example - compute shader - Conway's Game of Life
#
#   NOTE: This example requires raylib OpenGL 4.3 versions for compute shaders support,
#         shaders used in this example are #version 430 (OpenGL 4.3)
#
#   Example originally created with raylib 4.0, last time updated with raylib 2.5
#
#   Example contributed by Teddy Astie (@tsnake41) and reviewed by Ramon Santamaria (@raysan5)
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2021-2023 Teddy Astie (@tsnake41)
#   Converted to Nim by Antonis Geralis (@planetis-m) in 2023
#
# ****************************************************************************************

import raylib, rlgl, std/syncio

const
  # IMPORTANT: This must match gol*.glsl GOL_WIDTH constant.
  # This must be a multiple of 16 (check golLogic compute dispatch).
  GoLWidth = 768

  # Maximum amount of queued draw commands (squares draw from mouse down events).
  MaxBufferedTransferts = 48

# Game Of Life Update Command
type
  GoLUpdateCmd = object
    x: uint32 # x coordinate of the gol command
    y: uint32 # y coordinate of the gol command
    w: uint32 # width of the filled zone
    enabled: uint32 # whether to enable or disable zone

# Game Of Life Update Commands SSBO
type
  GoLUpdateSSBO = object
    count: uint32
    commands: array[MaxBufferedTransferts, GoLUpdateCmd]

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(GoLWidth, GoLWidth, "raylib [rlgl] example - compute shader - game of life")
  defer: closeWindow() # Close window and OpenGL context
  let resolution = Vector2(x: GoLWidth, y: GoLWidth)
  var brushSize: int32 = 8

  # Game of Life logic compute shader
  let golLogicCode = readFile("resources/shaders/glsl430/gol.glsl")
  let golLogicShader = compileShader(golLogicCode, ComputeShader)
  let golLogicProgram = loadComputeShaderProgram(golLogicShader)

  # Game of Life logic render shader
  let golRenderShader = loadShader("", "resources/shaders/glsl430/gol_render.glsl")
  let resUniformLoc = getShaderLocation(golRenderShader, "resolution")

  # Game of Life transfert shader (CPU<->GPU download and upload)
  let golTransfertCode = readFile("resources/shaders/glsl430/gol_transfert.glsl")
  let golTransfertShader = compileShader(golTransfertCode, ComputeShader)
  let golTransfertProgram = loadComputeShaderProgram(golTransfertShader)

  # Load shader storage buffer object (SSBO), id returned
  var ssboA = loadShaderBuffer(GoLWidth*GoLWidth*sizeof(uint32), nil, DynamicCopy)
  var ssboB = loadShaderBuffer(GoLWidth*GoLWidth*sizeof(uint32), nil, DynamicCopy)
  let ssboTransfert = loadShaderBuffer(sizeof(GoLUpdateSSBO).uint32, nil, DynamicCopy)
  var transfertBuffer = GoLUpdateSSBO(count: 0)

  # Create a white texture of the size of the window to update
  # each pixel of the window using the fragment shader: golRenderShader
  var whiteImage = genImageColor(GoLWidth, GoLWidth, White)
  let whiteTex = loadTextureFromImage(whiteImage)
  reset(whiteImage)

  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose():
    # Update
    # ------------------------------------------------------------------------------------
    inc(brushSize, getMouseWheelMove().int32)
    if (isMouseButtonDown(Left) or isMouseButtonDown(Right)) and
        transfertBuffer.count < MaxBufferedTransferts:
      # Buffer a new command
      transfertBuffer.commands[transfertBuffer.count] = GoLUpdateCmd(
        x: getMouseX().uint32 - brushSize.uint32 div 2,
        y: getMouseY().uint32 - brushSize.uint32 div 2,
        w: brushSize.uint32,
        enabled: isMouseButtonDown(Left).uint32
      )
      inc(transfertBuffer.count)

    elif transfertBuffer.count > 0: # Process transfert buffer
      # Send SSBO buffer to GPU
      updateShaderBuffer(ssboTransfert, addr transfertBuffer, sizeof(GoLUpdateSSBO).uint32, 0)
      # Process SSBO commands on GPU
      enableShader(golTransfertProgram)
      bindShaderBuffer(ssboA, 1)
      bindShaderBuffer(ssboTransfert, 3)
      computeShaderDispatch(transfertBuffer.count, 1, 1)
      # Each GPU unit will process a command!
      disableShader()
      transfertBuffer.count = 0

    else:
      # Process game of life logic
      enableShader(golLogicProgram)
      bindShaderBuffer(ssboA, 1)
      bindShaderBuffer(ssboB, 2)
      computeShaderDispatch(GoLWidth div 16, GoLWidth div 16, 1)
      disableShader()
      # ssboA <-> ssboB
      swap(ssboA, ssboB)

    bindShaderBuffer(ssboA, 1)
    setShaderValue(golRenderShader, resUniformLoc, resolution)
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    drawing():
      clearBackground(Blank)
      shaderMode(golRenderShader):
        drawTexture(whiteTex, 0, 0, White)

      drawRectangleLines(getMouseX() - brushSize div 2,
                         getMouseY() - brushSize div 2, brushSize, brushSize, Red)
      drawText("Use Mouse wheel to increase/decrease brush size", 10, 10, 20, White)
      drawFPS(getScreenWidth() - 100, 10)
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  # Unload shader buffers objects.
  unloadShaderBuffer(ssboA)
  unloadShaderBuffer(ssboB)
  unloadShaderBuffer(ssboTransfert)

  # Unload compute shader programs
  unloadShaderProgram(golTransfertProgram)
  unloadShaderProgram(golLogicProgram)
  # --------------------------------------------------------------------------------------

main()
