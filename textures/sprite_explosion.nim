import raylib, std/lenientops

const
  screenWidth = 800
  screenHeight = 450

  FramesPerLine = 5
  Lines = 5

proc main =
  initWindow(screenWidth, screenHeight, "raylib [textures] example - sprite explosion")
  defer: closeWindow()
  initAudioDevice()
  defer: closeAudioDevice()
  # Load explosion sound
  let fxBoom = loadSound("resources/boom.wav")
  # Load explosion texture
  let explosion = loadTexture("resources/explosion.png")
  # Init variables for animation
  let frameWidth = float32(explosion.width div FramesPerLine) # Sprite one frame rectangle width
  let frameHeight = float32(explosion.height div Lines) # Sprite one frame rectangle height
  var currentFrame = 0'i32
  var currentLine = 0'i32
  var frameRec = Rectangle(x: 0, y: 0, width: frameWidth, height: frameHeight)
  var position = Vector2(x: 0, y: 0)
  var active = false
  var framesCounter = 0'i32
  setTargetFPS(120)
  # -------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # -----------------------------------------------------------------------------------
    # Check for mouse button pressed and activate explosion (if not active)
    if isMouseButtonPressed(MouseButtonLeft) and not active:
      position = getMousePosition()
      active = true
      position.x -= frameWidth/2'f32
      position.y -= frameHeight/2'f32
      playSound(fxBoom)
    if active:
      inc(framesCounter)
      if framesCounter > 2:
        inc(currentFrame)
        if currentFrame >= FramesPerLine:
          currentFrame = 0
          inc(currentLine)
          if currentLine >= Lines:
            currentLine = 0
            active = false
        framesCounter = 0
    frameRec.x = frameWidth * currentFrame
    frameRec.y = frameHeight * currentLine
    # -----------------------------------------------------------------------------------
    # Draw
    # -----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    # Draw explosion required frame rectangle
    if active:
      drawTextureRec(explosion, frameRec, position, White)
    endDrawing()

main()
