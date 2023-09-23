# ****************************************************************************************
#
#   raylib [audio] example - Playing sound multiple times
#
#   Example originally created with raylib 4.6
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2023 Jeffery Myers (@JeffM2501)
#
# ****************************************************************************************

import raylib

const
  screenWidth = 800
  screenHeight = 450

  MaxSounds = 10

var
  sound: Sound
  soundArray: array[MaxSounds, SoundAlias]
  currentSound: int32 = 0

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight,
             "raylib [audio] example - playing sound multiple times")
  defer: closeWindow() # Close window and OpenGL context

  initAudioDevice() # Initialize audio device
  defer: closeAudioDevice() # Close audio device (music streaming is automatically stopped)

  # load the sound list
  sound = loadSound("resources/sound.wav")
  # Load WAV audio file into the first slot as the 'source' sound
  # this sound owns the sample data
  for i in 0 ..< MaxSounds:
    soundArray[i] = loadSoundAlias(sound)
    # Load an alias of the sound into slots 1-9. These do not own the sound data, but can be played
  currentSound = 0 # Set the sound list to the start
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    if isKeyPressed(Space):
      playSound(Sound(soundArray[currentSound]))
      # play the next open sound slot
      inc(currentSound)
      # increment the sound slot
      if currentSound >= MaxSounds:
        currentSound = 0
    beginDrawing()
    clearBackground(RayWhite)
    drawText("Press SPACE to PLAY a WAV sound!", 200, 180, 20, LightGray)
    endDrawing()
    # ------------------------------------------------------------------------------------

main()
