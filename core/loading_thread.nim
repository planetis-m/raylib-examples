# ****************************************************************************************
#
# raylib example - loading thread
#
# This example has been created using raylib 2.5 (www.raylib.com)
# raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
# Copyright (c) 2014-2019 Ramon Santamaria (@raysan5)
# Converted in 2021 by greenfork
#
# ****************************************************************************************

import std/times, threading/atomics, raylib

const
  screenWidth = 800
  screenHeight = 450

type
  State = enum
    Waiting, Loading, Finished

var threadId: Thread[void] # Loading data thread id
var dataLoaded: Atomic[bool] # Data Loaded completion indicator
dataLoaded.store(false)
var dataProgress: int32 = 0 # Data progress accumulator

proc loadDataThread() {.thread.} =
  var timeCounter: int32 = 0 # Time counted in ms
  var prevTime = cpuTime() # Previous time
  # We simulate data loading with a time counter for 5 seconds
  while timeCounter < 5000:
    var currentTime = cpuTime() - prevTime
    timeCounter = currentTime.int32*1000
    # We accumulate time over a global variable to be used in
    # main thread as a progress bar
    dataProgress = timeCounter div 10
  # When data has finished loading, we set global variable
  dataLoaded.store(true)

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [core] example - loading thread")
  var state: State = Waiting
  var framesCounter: int32 = 0
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # Main game loop
  # --------------------------------------------------------------------------------------
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    case state
    of Waiting:
      if isKeyPressed(Enter):
        createThread(threadId, loadDataThread)
        traceLog(Info, "Loading thread initialized successfully")
        state = Loading
    of Loading:
      inc framesCounter
      if dataLoaded.load:
        framesCounter = 0
        joinThread(threadId)
        traceLog(Info, "Loading thread terminated successfully")
        state = Finished
    of Finished:
      if isKeyPressed(Enter):
        # Reset everything to launch again
        dataLoaded.store(false)
        dataProgress = 0
        state = Waiting
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    case state
    of Waiting:
      drawText("PRESS ENTER to START LOADING DATA", 150, 170, 20, DarkGray)
    of Loading:
      drawRectangle(150, 200, dataProgress, 60, SkyBlue)
      if (framesCounter div 15) mod 2 == 1:
        drawText("LOADING DATA...", 240, 210, 40, DarkBlue)
    of Finished:
      drawRectangle(150, 200, 500, 60, Lime)
      drawText("DATA LOADED!", 250, 210, 40, Green)
    drawRectangleLines(150, 200, 500, 60, DarkGray)
    endDrawing()
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context
  # --------------------------------------------------------------------------------------

main()
