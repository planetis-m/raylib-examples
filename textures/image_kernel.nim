# ****************************************************************************************
#
#   raylib [textures] example - Image loading and texture creation
#
#   NOTE: Images are loaded in CPU memory (RAM); textures are loaded in GPU memory (VRAM)
#
#   Example originally created with raylib 1.3, last time updated with raylib 1.3
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2015-2023 Karim Salem (@kimo-s)
#
# ****************************************************************************************

import raylib

const
  screenWidth = 800
  screenHeight = 450

proc normalizeKernel(kernel: var openArray[float32]) =
  var sum: float32 = 0
  for i in 0 .. kernel.high:
    sum += kernel[i]
  if sum != 0:
    for i in 0 .. kernel.high:
      kernel[i] = kernel[i] / sum

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  initWindow(screenWidth, screenHeight, "raylib [textures] example - image convolution")
  defer: closeWindow() # Close window and OpenGL context

  var texture: Texture2D
  var catSharpendTexture: Texture2D
  var catSobelTexture: Texture2D
  var catGaussianTexture: Texture2D

  block:
    var image = loadImage("resources/cat.png") # Loaded in CPU memory (RAM)
    var
      gaussiankernel: array[9, float32] = [
        1, 2, 1,
        2, 4, 2,
        1, 2, 1]
      sobelkernel: array[9, float32] = [
        1, 0, -1,
        2, 0, -2,
        1, 0, -1]
      sharpenkernel: array[9, float32] = [
       0, -1, 0,
       -1, 5, -1,
       0, -1, 0]
    normalizeKernel(gaussiankernel)
    normalizeKernel(sharpenkernel)
    normalizeKernel(sobelkernel)
    var catSharpend = image
    imageKernelConvolution(catSharpend, sharpenkernel)
    var catSobel = image
    imageKernelConvolution(catSobel, sobelkernel)
    var catGaussian = image
    for i in 0 ..< 6:
      imageKernelConvolution(catGaussian, gaussiankernel)

    imageCrop(image, Rectangle(x: 0, y: 0, width: 200, height: 450))
    imageCrop(catGaussian, Rectangle(x: 0, y: 0, width: 200, height: 450))
    imageCrop(catSobel, Rectangle(x: 0, y: 0, width: 200, height: 450))
    imageCrop(catSharpend, Rectangle(x: 0, y: 0, width: 200, height: 450))

    # Images converted to texture, GPU memory (VRAM)
    texture = loadTextureFromImage(image)
    catSharpendTexture = loadTextureFromImage(catSharpend)
    catSobelTexture = loadTextureFromImage(catSobel)
    catGaussianTexture = loadTextureFromImage(catGaussian)

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
    drawTexture(catSharpendTexture, 0, 0, White)
    drawTexture(catSobelTexture, 200, 0, White)
    drawTexture(catGaussianTexture, 400, 0, White)
    drawTexture(texture, 600, 0, White)
    endDrawing()
    # ------------------------------------------------------------------------------------

main()
