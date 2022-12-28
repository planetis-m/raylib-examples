# ****************************************************************************************
#
# raylib [core] example - Windows drop files
#
# This example only works on platforms that support drag & drop (Windows, Linux, OSX, Html5?)
#
# This example has been created using raylib 1.3 (www.raylib.com)
# raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
# Copyright (c) 2015 Ramon Santamaria (@raysan5)
#
# ****************************************************************************************

import raylib

const
  screenWidth = 800
  screenHeight = 450

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [core] example - drop files")

  var droppedFiles: seq[string] = @[]
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    if isFileDropped():
      droppedFiles = getDroppedFiles()
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    if droppedFiles.len == 0:
      drawText("Drop your files to this window!", 100, 40, 20, DarkGray)
    else:
      drawText("Dropped files:", 100, 40, 20, DarkGray)
      for i in 0..droppedFiles.high:
        if i mod 2 == 0:
          drawRectangle(0, 85 + 40*i.int32, screenWidth, 40, fade(LightGray, 0.5))
        else:
          drawRectangle(0, 85 + 40*i.int32, screenWidth, 40, fade(LightGray, 0.3))
        drawText(droppedFiles[i], 120, 100 + 40*i.int32, 10, Gray)
      drawText("Drop new files...", 100, 110 + 40*droppedFiles.len.int32, 20, DarkGray)
    endDrawing()
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context
  # --------------------------------------------------------------------------------------

main()
