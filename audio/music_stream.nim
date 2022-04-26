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

var low = [0'f32, 0]

proc audioProcessEffectLPF(buffer: pointer; frames: uint32) {.cdecl.} =
  # Audio effect: lowpass filter
  let buffer = cast[ptr UncheckedArray[float32]](buffer)
  const cutoff = 70'f32 / 44100'f32 # 70 Hz lowpass filter
  const k = cutoff / (cutoff + 0.1591549431'f32) # RC filter formula
  for i in countup(frames*2, 2):
    var
      l = buffer[i]
      r = buffer[i + 1]
    low[0] += k * (l - low[0])
    low[1] += k * (r - low[1])
    buffer[i] = low[0]
    buffer[i + 1] = low[1]

var delayBuffer: seq[float32]
var delayBufferSize = 0
var delayReadIndex = 2
var delayWriteIndex = 0

proc audioProcessEffectDelay(buffer: pointer; frames: uint32) {.cdecl.} =
  # Audio effect: delay
  let buffer = cast[ptr UncheckedArray[float32]](buffer)
  for i in countup(frames*2, 2):
    let leftDelay = delayBuffer[delayReadIndex] # ERROR: Reading buffer -> WHY??? Maybe thread related???4
    inc(delayReadIndex)
    let rightDelay = delayBuffer[delayReadIndex]
    inc(delayReadIndex)
    if delayReadIndex == delayBufferSize:
      delayReadIndex = 0
    buffer[i] = 0.5'f32 * buffer[i] + 0.5'f32 * leftDelay
    buffer[i + 1] = 0.5'f32 * buffer[i + 1] + 0.5'f32 * rightDelay
    delayBuffer[delayWriteIndex] = buffer[i]
    inc(delayWriteIndex)
    delayBuffer[delayWriteIndex] = buffer[i + 1]
    inc(delayWriteIndex)
    if delayWriteIndex == delayBufferSize:
      delayWriteIndex = 0

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
  # Allocate buffer for the delay effect
  delayBuffer = newSeq[float32](48000*2)
  # 1 second delay (device sampleRate*channels)
  playMusicStream(music)
  var timePlayed = 0'f32
  var pause = false
  var hasFilter = false
  var hasDelay = false
  setTargetFPS(60)
  # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    updateMusicStream(music)
    # Update music buffer with new stream data
    # Restart music playing (stop and play)
    if isKeyPressed(KeySpace):
      stopMusicStream(music)
      playMusicStream(music)
    if isKeyPressed(KeyP):
      pause = not pause
      if pause:
        pauseMusicStream(music)
      else:
        resumeMusicStream(music)
    if isKeyPressed(KeyF):
      hasFilter = not hasFilter
      if hasFilter:
        attachAudioStreamProcessor(music.stream, audioProcessEffectLPF)
      else:
        detachAudioStreamProcessor(music.stream, audioProcessEffectLPF)
    if isKeyPressed(KeyD):
      hasDelay = not hasDelay
      if hasDelay:
        attachAudioStreamProcessor(music.stream, audioProcessEffectDelay)
      else:
        detachAudioStreamProcessor(music.stream, audioProcessEffectDelay)
    timePlayed = getMusicTimePlayed(music) / getMusicTimeLength(music) * 400
    if timePlayed > 400:
      stopMusicStream(music)
    beginDrawing()
    clearBackground(RayWhite)
    drawText("MUSIC SHOULD BE PLAYING!", 255, 150, 20, LightGray)
    drawRectangle(200, 200, 400, 12, LightGray)
    drawRectangle(200, 200, timePlayed.int32, 12, Maroon)
    drawRectangleLines(200, 200, 400, 12, Gray)
    drawText("PRESS SPACE TO RESTART MUSIC", 215, 250, 20, LightGray)
    drawText("PRESS P TO PAUSE/RESUME MUSIC", 208, 280, 20, LightGray)
    endDrawing()

main()
