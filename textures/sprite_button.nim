# ****************************************************************************************
#
#   raylib [textures] example - sprite button
#
#   Example originally created with raylib 2.5, last time updated with raylib 2.5
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2019-2022 Ramon Santamaria (@raysan5)
#
# ****************************************************************************************

import raylib

const
  screenWidth = 800
  screenHeight = 450

  NumFrames = 3 # Number of frames (rectangles) for the button sprite texture

type
  ButtonState = enum
    Normal, MouseHover, Pressed

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [textures] example - sprite button")
  defer: closeWindow() # Close window and OpenGL context
  initAudioDevice() # Initialize audio device
  defer: closeAudioDevice() # Close audio device
  let fxButton = loadSound("resources/buttonfx.wav") # Load button sound
  let button = loadTexture("resources/button.png") # Load button texture
  # Define frame rectangle for drawing
  var frameHeight = button.height.float32 / NumFrames
  var sourceRec = Rectangle(x: 0, y: 0, width: float32(button.width), height: frameHeight)
  # Define button bounds on screen
  var btnBounds = Rectangle(x: screenWidth.float32 / 2 - button.width.float32 / 2,
      y: screenHeight.float32 / 2 - button.height.float32 / NumFrames / 2,
      width: float32(button.width), height: frameHeight)
  var btnState = Normal # Button state
  var btnAction = false # Button action should be activated
  var mousePoint = Vector2(x: 0, y: 0)
  setTargetFPS(60)
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    mousePoint = getMousePosition()
    btnAction = false
    # Check button state
    if checkCollisionPointRec(mousePoint, btnBounds):
      if isMouseButtonDown(MouseButtonLeft):
        btnState = Pressed
      else:
        btnState = MouseHover
      if isMouseButtonReleased(MouseButtonLeft):
        btnAction = true
    else:
      btnState = Normal
    if btnAction:
      playSound(fxButton)
      # TODO: Any desired action
    sourceRec.y = btnState.float32 * frameHeight
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    drawTexture(button, sourceRec, Vector2(x: btnBounds.x, y: btnBounds.y), White) # Draw button frame
    endDrawing()
    # ------------------------------------------------------------------------------------

main()
