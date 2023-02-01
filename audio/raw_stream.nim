# ****************************************************************************************
#
#   raylib [audio] example - Raw audio streaming
#
#   Example originally created with raylib 1.6, last time updated with raylib 4.2
#
#   Example created by Ramon Santamaria (@raysan5) and reviewed by James Hofmann (@triplefox)
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2015-2023 Ramon Santamaria (@raysan5) and James Hofmann (@triplefox)
#
# ****************************************************************************************

import raylib, std/[math, strformat]

const
  screenWidth = 800
  screenHeight = 450

const
  MaxSamples = 512
  MaxSamplesPerUpdate = 4096

var
  frequency: float32 = 440 # Cycles per second (hz)
  audioFrequency: float32 = 440 # Audio frequency, for smoothing
  oldFrequency: float32 = 1 # Previous value, used to test if sine needs to be rewritten, and to smoothly modulate frequency
  sineIdx: float32 = 0 # Index for audio rendering

proc audioInputCallback(buffer: pointer; frames: uint32) {.cdecl.} =
  # Audio input processing callback
  audioFrequency = frequency + (audioFrequency - frequency)*0.95'f32
  audioFrequency += 1
  audioFrequency -= 1
  let incr = audioFrequency/44100'f32
  let d = cast[ptr UncheckedArray[int16]](buffer)
  for i in 0..<frames:
    d[i] = int16(32000'f32*sin(2*PI*sineIdx))
    sineIdx += incr
    if sineIdx > 1: sineIdx -= 1

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [audio] example - raw audio streaming")
  defer: closeWindow() # Close window and OpenGL context

  initAudioDevice() # Initialize audio device
  defer: closeAudioDevice() # Close audio device (music streaming is automatically stopped)

  setAudioStreamBufferSizeDefault(MaxSamplesPerUpdate)
  # Init raw audio stream (sample rate: 44100, sample size: 16bit-short, channels: 1-mono)
  var stream = loadAudioStream(44100, 16, 1)
  setAudioStreamCallback(stream, audioInputCallback)
  # Buffer for the single cycle waveform we are synthesizing
  var data = newSeq[int16](MaxSamples)
  # Frame buffer, describing the waveform when repeated over the course of a frame
  var writeBuf = newSeq[int16](MaxSamplesPerUpdate)
  playAudioStream(stream)
  # Start processing stream buffer (no data loaded currently)
  # Position read in to determine next frequency
  var mousePosition = Vector2(x: -100, y: -100)
  # # Cycles per second (hz)
  # var frequency: float32 = 440
  # # Previous value, used to test if sine needs to be rewritten, and to smoothly modulate frequency
  # var oldFrequency: float32 = 1
  # # Cursor to read and copy the samples of the sine wave buffer
  # var readCursor: int32 = 0
  # Computed size in samples of the sine wave
  var waveLength: int32 = 1
  var position: Vector2

  setTargetFPS(30) # Set our game to run at 30 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    # Sample mouse input.
    mousePosition = getMousePosition()
    if isMouseButtonDown(Left):
      let fp = mousePosition.y
      frequency = 40 + fp
      let pan = mousePosition.x/screenWidth
      setAudioStreamPan(stream, pan)
    if frequency != oldFrequency:
      # Compute wavelength. Limit size in both directions.
      # let oldWavelength = waveLength
      waveLength = int32(22050/frequency)
      if waveLength > MaxSamples div 2: waveLength = MaxSamples div 2
      if waveLength < 1: waveLength = 1
      for i in 0..<waveLength*2:
        data[i] = int16(sin(2*PI*i.float32/waveLength.float32)*32000)
      # Make sure the rest of the line is flat
      for j in waveLength*2..<MaxSamples:
        data[j] = int16(0)
      # Scale read cursor's position to minimize transition artifacts
      # readCursor = int32(readCursor.float32*(waveLength.float32/oldWavelength.float32))
      oldFrequency = frequency
    # # Refill audio stream if required
    # if isAudioStreamProcessed(stream):
    #   # Synthesize a buffer that is exactly the requested size
    #   var writeCursor: int32 = 0
    #   while writeCursor < MaxSamplesPerUpdate:
    #     # Start by trying to write the whole chunk at once
    #     var writeLength = MaxSamplesPerUpdate - writeCursor
    #     # Limit to the maximum readable size
    #     let readLength = waveLength - readCursor
    #     if writeLength > readLength: writeLength = readLength
    #     copyMem(addr writeBuf[writeCursor], addr data[readCursor], writeLength*sizeof(int16))
    #     # Update cursors and loop audio
    #     readCursor = (readCursor + writeLength) mod waveLength
    #     inc writeCursor, writeLength
    #   # Copy finished frame to audio stream
    #   updateAudioStream(stream, writeBuf)
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    drawText(&"sine frequency: {frequency.int32}", getScreenWidth() - 220, 10, 20, Red)
    drawText("click mouse button to change frequency or pan", 10, 10, 20, DarkGray)
    # Draw the current buffer state proportionate to the screen
    for i in 0..<screenWidth:
      position.x = float32(i)
      position.y = 250 + 50*data[i*MaxSamples div screenWidth].float32/32000
      drawPixel(position, Red)
    endDrawing()
    # ------------------------------------------------------------------------------------

main()
