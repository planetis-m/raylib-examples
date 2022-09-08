# ***************************************************************************************
#
# raylib [others] example - Embedded files loading (Wave and Image)
#
# Example originally created with raylib 3.0, last time updated with raylib 2.5
#
# Example contributed by Kristian Holmgren (@defutura) and reviewed by Ramon Santamaria (@raysan5)
#
# Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
# BSD-like license that allows static linking with closed source software
#
# Copyright (c) 2020-2022 Kristian Holmgren (@defutura) and Ramon Santamaria (@raysan5)
#
# ***************************************************************************************

import raylib
include resources/[audio_data, image_data]

const
  screenWidth = 800
  screenHeight = 450

proc main =
  # Initialization
  # -------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [others] example - embedded files loading")
  defer: closeWindow() # Close window and OpenGL context
  initAudioDevice() # Initialize audio device
  defer: closeAudioDevice() # Close audio device
  # Loaded in CPU memory (RAM) from source file (audio_data.nim)
  # Same as: Wave wave = loadWave("sound.wav")
  let wave = toEmbedded(AudioData, AudioFrameCount, AudioSampleRate, AudioSampleSize, AudioChannels)

  # Wave converted to Sound to be played
  let sound = loadSoundFromWave(wave.Wave) # Convert proc argument to Wave

  # With a Wave loaded from file, after Sound is loaded, we can unload Wave
  # but in our case, Wave is embedded in executable, in program .data segment
  # we can not (and should not) try to free that private memory region
  #unloadWave(wave) # Do not unload wave data!

  # Loaded in CPU memory (RAM) from source file (image_data.nim)
  # Same as: Image image = loadImage("raylib_logo.png")
  let image = toEmbedded(ImageData, ImageWidth, ImageHeight, ImageFormat)
  # Image converted to Texture (VRAM) to be drawn
  let texture = loadTextureFromImage(image.Image) # Convert proc argument to Image

  # With an Image loaded from file, after Texture is loaded, we can unload Image
  # but in our case, Image is embedded in executable, in program .data segment
  # we can not (and should not) try to free that private memory region
  #unloadImage(image) # Do not unload image data!

  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # -------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # -----------------------------------------------------------------------------------
    if isKeyPressed(KeySpace): playSound(sound) # Play sound
    # Draw
    # -----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    drawTexture(texture, screenWidth div 2 - texture.width div 2, 40, White)
    drawText("raylib logo and sound loaded from header files", 150, 320, 20, LightGray)
    drawText("Press SPACE to PLAY the sound!", 220, 370, 20, LightGray)
    endDrawing()

main()
