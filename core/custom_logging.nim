# ****************************************************************************************
#
# raylib [core] example - Custom logging
#
# This example has been created using raylib 2.1 (www.raylib.com)
# raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
# Example contributed by Pablo Marcos Oltra (@pamarcos) and reviewed by Ramon Santamaria (@raysan5)
#
# Copyright (c) 2018 Pablo Marcos Oltra (@pamarcos) and Ramon Santamaria (@raysan5)
# Converted in 2021 by greenfork
#
# ****************************************************************************************

import raylib, std/[times, strformat]

const
  screenWidth = 800
  screenHeight = 450

proc logCustom(msgType: TraceLogLevel; text: cstring; args: va_list) {.cdecl.} =
  # Custom logging funtion
  var buffer = newString(128)
  vsprintf(buffer.cstring, text, args)
  var header = newStringOfCap(36)
  let timeStr = now().format("yyyy-MM-dd hh:mm:ss")
  header.add &"[{timeStr}] "
  case msgType
  of LogInfo: header.add "[INFO]: "
  of LogError: header.add "[ERROR]: "
  of LogWarning: header.add "[WARN]: "
  of LogDebug: header.add "[DEBUG]: "
  else: discard
  echo(header, buffer)

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  # First thing we do is setting our custom logger to ensure everything raylib logs
  # will use our own logger instead of its internal one
  setTraceLogCallback(logCustom)
  initWindow(screenWidth, screenHeight, "raylib [core] example - custom logging")
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    # TODO: Update your variables here
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    drawText("Check out the console output to see the custom logger in action!", 60, 200,
        20, LightGray)
    endDrawing()
  # De-Initialization
  # -------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context

main()
