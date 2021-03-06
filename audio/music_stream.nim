# ****************************************************************************************
#
#   raylib [audio] example - Music playing (streaming)
#
#   This example has been created using raylib 1.3 (www.raylib.com)
#   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
#   Copyright (c) 2015 Ramon Santamaria (@raysan5)
#
# ****************************************************************************************

import raylib

const
  screenWidth = 800
  screenHeight = 450

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight,
      "raylib [audio] example - music playing (streaming)")
  defer: closeWindow() # Close window and OpenGL context
  initAudioDevice()
  defer: closeAudioDevice() # Close audio device (music streaming is automatically stopped)
  # Initialize audio device
  let music = loadMusicStream("resources/country.mp3")
  # 1 second delay (device sampleRate*channels)
  playMusicStream(music)
  var timePlayed = 0'f32 # Time played normalized [0.0f..1.0f]
  var pause = false # Music playing paused
  setTargetFPS(60)
  # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    updateMusicStream(music) # Update music buffer with new stream data
    # Get normalized time played for current music stream
    timePlayed = getMusicTimePlayed(music) / getMusicTimeLength(music)
    if timePlayed > 1: timePlayed = 1 # Make sure time played is no longer than music
    beginDrawing()
    clearBackground(RayWhite)
    drawText("MUSIC SHOULD BE PLAYING!", 255, 150, 20, LightGray)
    drawRectangle(200, 200, 400, 12, LightGray)
    drawRectangle(200, 200, int32(timePlayed*400), 12, Maroon)
    drawRectangleLines(200, 200, 400, 12, Gray)
    drawText("PRESS SPACE TO RESTART MUSIC", 215, 250, 20, LightGray)
    drawText("PRESS P TO PAUSE/RESUME MUSIC", 208, 280, 20, LightGray)
    endDrawing()

main()
