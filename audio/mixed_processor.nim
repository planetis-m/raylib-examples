# ****************************************************************************************
#
#   raylib [audio] example - Mixed audio processing
#
#   Example originally created with raylib 4.2, last time updated with raylib 4.2
#
#   Example contributed by hkc (@hatkidchan) and reviewed by Ramon Santamaria (@raysan5)
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2023 hkc (@hatkidchan)
#   Converted to Nim by Antonis Geralis (@planetis-m) in 2023
#
# ****************************************************************************************

import raylib, std/[strformat, math]

const
  screenWidth = 800
  screenHeight = 450

var
  exponent: float32 = 1.0 # Audio exponentiation value
  averageVolume: array[400, float32] # Average volume history

# ----------------------------------------------------------------------------------------
# Audio processing function
# ----------------------------------------------------------------------------------------

proc processAudio(buffer: pointer; frames: uint32) {.cdecl.} =
  var samples = cast[ptr UncheckedArray[float32]](buffer) # Samples internally stored as <float>s
  var average: float32 = 0 # Temporary average volume
  for frame in 0 ..< frames.int:
    template left: untyped = samples[frame*2 + 0]
    template right: untyped = samples[frame*2 + 1]
    left = pow(abs(left), exponent)*(if (left < 0): -1 else: 1)
    right = pow(abs(right), exponent)*(if (right < 0): -1 else: 1)
    average += abs(left) / frames.float32 # accumulating average volume
    average += abs(right) / frames.float32
  # Moving history to the left
  for i in 0 ..< averageVolume.high:
    averageVolume[i] = averageVolume[i + 1]
  averageVolume[^1] = average # Adding last average value

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [audio] example - processing mixed output")
  defer: closeWindow() # Close window and OpenGL context

  initAudioDevice() # Initialize audio device
  defer: closeAudioDevice() # Close audio device (music streaming is automatically stopped)

  attachAudioMixedProcessor(processAudio)
  let music = loadMusicStream("resources/country.mp3")
  let sound = loadSound("resources/coin.wav")
  playMusicStream(music)
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    updateMusicStream(music) # Update music buffer with new stream data

    # Modify processing variables
    # ------------------------------------------------------------------------------------
    if isKeyPressed(Left): exponent -= 0.05'f32
    if isKeyPressed(Right): exponent += 0.05'f32

    if exponent <= 0.5'f32: exponent = 0.5'f32
    if exponent >= 3.0'f32: exponent = 3.0'f32

    if isKeyPressed(Space): playSound(sound)
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    drawText("MUSIC SHOULD BE PLAYING!", 255, 150, 20, LightGray)
    drawText(&"EXPONENT = {exponent:.2f}", 215, 180, 20, LightGray)
    drawRectangle(199, 199, 402, 34, LightGray)
    for i in 0 ..< 400:
      drawLine(201 + i.int32, int32(232 - averageVolume[i]*32), 201 + i.int32, 232, Maroon)
    drawRectangleLines(199, 199, 402, 34, Gray)
    drawText("PRESS SPACE TO PLAY OTHER SOUND", 200, 250, 20, LightGray)
    drawText("USE LEFT AND RIGHT ARROWS TO ALTER DISTORTION", 140, 280, 20, LightGray)
    endDrawing()
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  detachAudioMixedProcessor(processAudio) # Disconnect audio processor
  # --------------------------------------------------------------------------------------

main()
