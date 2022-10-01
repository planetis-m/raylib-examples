# ****************************************************************************************
#
# raylib [core] example - Gamepad input
#
# NOTE: This example requires a Gamepad connected to the system
#       raylib is configuRed to work with the following gamepads:
#              - Xbox 360 Controller (Xbox 360, Xbox One)
#              - PLAYSTATION(R)3 Controller
#       Check raylib.h for buttons configuration
#
# Example originally created with raylib 1.1, last time updated with raylib 4.2
#
# Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
# BSD-like license that allows static linking with closed source software
#
# Copyright (c) 2013-2022 Ramon Santamaria (@raysan5)
#
# ****************************************************************************************
import raylib, std/strformat

# NOTE: Gamepad name ID depends on drivers and OS
const
  Xbox360LegacyNameId = "Xbox Controller"

when defined(linux):
  const
    Xbox360NameId = "Microsoft X-Box 360 pad"
    PS3NameId = "PLAYSTATION(R)3 Controller"
else:
  const
    Xbox360NameId = "Xbox 360 Controller"
    PS3NameId = "PLAYSTATION(R)3 Controller"

const
  screenWidth = 800
  screenHeight = 450

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  setConfigFlags(flags(FlagMsaa4xHint)) # Set MSAA 4X hint before windows creation
  initWindow(screenWidth, screenHeight, "raylib [core] example - gamepad input")
  defer: closeWindow() # Close window and OpenGL context
  let texPs3Pad = loadTexture("resources/ps3.png")
  let texXboxPad = loadTexture("resources/xbox.png")
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ----------------------------------------------------------------------------------
    # ...
    # ----------------------------------------------------------------------------------
    # Draw
    # ----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    if isGamepadAvailable(0):
      drawText(&"GP1: {getGamepadName(0)}", 10, 10, 10, Black)
      if getGamepadName(0) in [Xbox360NameId, Xbox360LegacyNameId]:
        drawTexture(texXboxPad, 0, 0, DarkGray)
        # Draw buttons: xbox home
        if isGamepadButtonDown(0, GamepadButtonMiddle): drawCircle(394, 89, 19, Red)
        # Draw buttons: basic
        if isGamepadButtonDown(0, GamepadButtonMiddleRight): drawCircle(436, 150, 9, Red)
        if isGamepadButtonDown(0, GamepadButtonMiddleLeft): drawCircle(352, 150, 9, Red)
        if isGamepadButtonDown(0, GamepadButtonRightFaceLeft): drawCircle(501, 151, 15, Blue)
        if isGamepadButtonDown(0, GamepadButtonRightFaceDown): drawCircle(536, 187, 15, Lime)
        if isGamepadButtonDown(0, GamepadButtonRightFaceRight): drawCircle(572, 151, 15, Maroon)
        if isGamepadButtonDown(0, GamepadButtonRightFaceUp): drawCircle(536, 115, 15, Gold)
        # Draw buttons: d-pad
        drawRectangle(317, 202, 19, 71, Black)
        drawRectangle(293, 228, 69, 19, Black)
        if isGamepadButtonDown(0, GamepadButtonLeftFaceUp): drawRectangle(317, 202, 19, 26, Red)
        if isGamepadButtonDown(0, GamepadButtonLeftFaceDown): drawRectangle(317, 202 + 45, 19, 26, Red)
        if isGamepadButtonDown(0, GamepadButtonLeftFaceLeft): drawRectangle(292, 228, 25, 19, Red)
        if isGamepadButtonDown(0, GamepadButtonLeftFaceRight): drawRectangle(292 + 44, 228, 26, 19, Red)
        # Draw buttons: left-right back
        if isGamepadButtonDown(0, GamepadButtonLeftTrigger1): drawCircle(259, 61, 20, Red)
        if isGamepadButtonDown(0, GamepadButtonRightTrigger1): drawCircle(536, 61, 20, Red)
        # Draw axis: left joystick
        drawCircle(259, 152, 39, Black)
        drawCircle(259, 152, 34, LightGray)
        drawCircle(259 +
            int32(getGamepadAxisMovement(0, GamepadAxisLeftX)*20), 152 +
            int32(getGamepadAxisMovement(0, GamepadAxisLeftY)*20), 25, Black)
        # Draw axis: right joystick
        drawCircle(461, 237, 38, Black)
        drawCircle(461, 237, 33, LightGray)
        drawCircle(461 +
            int32(getGamepadAxisMovement(0, GamepadAxisRightX)*20), 237 +
            int32(getGamepadAxisMovement(0, GamepadAxisRightY)*20), 25, Black)
        # Draw axis: left-right triggers
        drawRectangle(170, 30, 15, 70, Gray)
        drawRectangle(604, 30, 15, 70, Gray)
        drawRectangle(170, 30, 15, int32((1 +
            getGamepadAxisMovement(0, GamepadAxisLeftTrigger))/2*70), Red)
        drawRectangle(604, 30, 15, int32((1 +
            getGamepadAxisMovement(0, GamepadAxisRightTrigger))/2*70), Red)
        #drawText(&"Xbox axis LT: {GetGamepadAxisMovement(0, GamepadAxisLeftTRIGGER):02.02f}", 10, 40, 10, Black)
        #drawText(&"Xbox axis RT: {GetGamepadAxisMovement(0, GamepadAxisRightTRIGGER):02.02f}", 10, 60, 10, Black)
      elif getGamepadName(0) == PS3NameId:
        drawTexture(texPs3Pad, 0, 0, DarkGray)
        # Draw buttons: ps
        if isGamepadButtonDown(0, GamepadButtonMiddle): drawCircle(396, 222, 13, Red)
        # Draw buttons: basic
        if isGamepadButtonDown(0, GamepadButtonMiddleLeft): drawRectangle(328, 170, 32, 13, Red)
        if isGamepadButtonDown(0, GamepadButtonMiddleRight):
          drawTriangle(Vector2(x: 436, y: 168), Vector2(x: 436, y: 185), Vector2(x: 464, y: 177), Red)
        if isGamepadButtonDown(0, GamepadButtonRightFaceUp): drawCircle(557, 144, 13, Lime)
        if isGamepadButtonDown(0, GamepadButtonRightFaceRight): drawCircle(586, 173, 13, Red)
        if isGamepadButtonDown(0, GamepadButtonRightFaceDown): drawCircle(557, 203, 13, Violet)
        if isGamepadButtonDown(0, GamepadButtonRightFaceLeft): drawCircle(527, 173, 13, Pink)
        # Draw buttons: d-pad
        drawRectangle(225, 132, 24, 84, Black)
        drawRectangle(195, 161, 84, 25, Black)
        if isGamepadButtonDown(0, GamepadButtonLeftFaceUp): drawRectangle(225, 132, 24, 29, Red)
        if isGamepadButtonDown(0, GamepadButtonLeftFaceDown): drawRectangle(225, 132 + 54, 24, 30, Red)
        if isGamepadButtonDown(0, GamepadButtonLeftFaceLeft): drawRectangle(195, 161, 30, 25, Red)
        if isGamepadButtonDown(0, GamepadButtonLeftFaceRight): drawRectangle(195 + 54, 161, 30, 25, Red)
        # Draw buttons: left-right back buttons
        if isGamepadButtonDown(0, GamepadButtonLeftTrigger1): drawCircle(239, 82, 20, Red)
        if isGamepadButtonDown(0, GamepadButtonRightTrigger1): drawCircle(557, 82, 20, Red)
        # Draw axis: left joystick
        drawCircle(319, 255, 35, Black)
        drawCircle(319, 255, 31, LightGray)
        drawCircle(319 +
            int32(getGamepadAxisMovement(0, GamepadAxisLeftX)*20), 255 +
            int32(getGamepadAxisMovement(0, GamepadAxisLeftY)*20), 25, Black)
        # Draw axis: right joystick
        drawCircle(475, 255, 35, Black)
        drawCircle(475, 255, 31, LightGray)
        drawCircle(475 +
            int32(getGamepadAxisMovement(0, GamepadAxisRightX)*20), 255 +
            int32(getGamepadAxisMovement(0, GamepadAxisRightY)*20), 25, Black)
        # Draw axis: left-right triggers
        drawRectangle(169, 48, 15, 70, Gray)
        drawRectangle(611, 48, 15, 70, Gray)
        drawRectangle(169, 48, 15, int32((1 -
            getGamepadAxisMovement(0, GamepadAxisLeftTrigger))/2*70), Red)
        drawRectangle(611, 48, 15, int32((1 -
            getGamepadAxisMovement(0, GamepadAxisRightTrigger))/2*70), Red)
      else:
        drawText("- GENERIC GAMEPAD -", 280, 180, 20, Gray)
        # TODO: Draw generic gamepad
      drawText(&"DETECTED AXIS [{getGamepadAxisCount(0)}]:", 10, 50, 10, Maroon)
      for i in 0 ..< getGamepadAxisCount(0):
        drawText(&"AXIS {i}: {getGamepadAxisMovement(0, i.GamepadAxis):.02f}", 20, 70 + 20*i.int32, 10, DarkGray)
      if getGamepadButtonPressed() != -1.GamepadButton:
        drawText(&"DETECTED BUTTON: {getGamepadButtonPressed().int32}", 10, 430, 10, Red)
      else:
        drawText("DETECTED BUTTON: NONE", 10, 430, 10, Gray)
    else:
      drawText("GP1: NOT DETECTED", 10, 10, 10, Gray)
      drawTexture(texXboxPad, 0, 0, LightGray)
    endDrawing()

main()
