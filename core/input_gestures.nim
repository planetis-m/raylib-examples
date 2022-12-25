# ****************************************************************************************
#
# raylib [core] example - Input Gesture Detection
#
# This example has been created using raylib 1.4 (www.raylib.com)
# raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
# Copyright (c) 2016 Ramon Santamaria (@raysan5)
# Converted in 2021 by greenfork
#
# ****************************************************************************************

import raylib

const
  screenWidth = 800
  screenHeight = 450

  MaxGestureStrings = 20

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [core] example - input gestures")
  var touchArea = Rectangle(x: 220, y: 10, width: screenWidth - 230, height: screenHeight - 20)
  var gesturesCount = 0
  var gestureStrings: array[MaxGestureStrings, string]
  var currentGesture = GestureNone
  var lastGesture = GestureNone
  #setGesturesEnabled(flags(GestureTap, GestureDrag)) # Enable only some gestures to be detected
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # Main game loop
  # --------------------------------------------------------------------------------------
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    lastGesture = currentGesture
    currentGesture = getGestureDetected()
    let touchPosition = getTouchPosition(0)

    if checkCollisionPointRec(touchPosition, touchArea) and currentGesture != GestureNone:
      if currentGesture != lastGesture:
        # Store gesture string
        case currentGesture
        of GestureTap:
          gestureStrings[gesturesCount] = "GESTURE TAP"
        of GestureDoubletap:
          gestureStrings[gesturesCount] = "GESTURE DOUBLETAP"
        of GestureHold:
          gestureStrings[gesturesCount] = "GESTURE HOLD"
        of GestureDrag:
          gestureStrings[gesturesCount] = "GESTURE DRAG"
        of GestureSwipeRight:
          gestureStrings[gesturesCount] = "GESTURE SWIPE RIGHT"
        of GestureSwipeLeft:
          gestureStrings[gesturesCount] = "GESTURE SWIPE LEFT"
        of GestureSwipeUp:
          gestureStrings[gesturesCount] = "GESTURE SWIPE UP"
        of GestureSwipeDown:
          gestureStrings[gesturesCount] = "GESTURE SWIPE DOWN"
        of GesturePinchIn:
          gestureStrings[gesturesCount] = "GESTURE PINCH IN"
        of GesturePinchOut:
          gestureStrings[gesturesCount] = "GESTURE PINCH OUT"
        else:
          discard
        inc gesturesCount
        # Reset gestures strings
        if gesturesCount >= MaxGestureStrings:
          #for i in 0..<MaxGestureStrings:
            #gestureStrings[i] = ""
          gesturesCount = 0
    beginDrawing()
    clearBackground(RayWhite)
    drawRectangle(touchArea, Gray)
    drawRectangle(225, 15, screenWidth - 240, screenHeight - 30, RayWhite)
    drawText("GESTURES TEST AREA", screenWidth - 270, screenHeight - 40, 20, fade(Gray, 0.5))
    for i in 0..<gesturesCount:
      if i mod 2 == 0:
        drawRectangle(10, 30 + 20*i.int32, 200, 20, fade(LightGray, 0.5))
      else:
        drawRectangle(10, 30 + 20*i.int32, 200, 20, fade(LightGray, 0.3))
      if i < gesturesCount - 1:
        drawText(gestureStrings[i], 35, 36 + 20*i.int32, 10, DarkGray)
      else:
        drawText(gestureStrings[i], 35, 36 + 20*i.int32, 10, Maroon)
    drawRectangleLines(10, 29, 200, screenHeight - 50, Gray)
    drawText("DETECTED GESTURES", 50, 15, 10, Gray)
    if currentGesture != GestureNone:
      drawCircle(touchPosition, 30, Maroon)
    endDrawing()
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context
  # --------------------------------------------------------------------------------------

main()
