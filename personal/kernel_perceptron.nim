# ****************************************************************************************
#
#   naylib example - raylib kernel perceptron
#
#   The example is inspired by "Test Run: Kernel Perceptrons using C#"
#   by James McCaffrey (https://msdn.microsoft.com/en-us/magazine/mt797653).
#
#   Example originally created with naylib 5.5
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2024 Antonis Geralis (@planetis-m)
#
# ****************************************************************************************

import raylib, rlgl, std/[random, math, strformat]

const
  screenWidth = 800
  screenHeight = 450

  NumPoints = 2000
  SplineSampleCount = 15 # Number of points to generate for the spline
  NumFeatures = 2
  Budget = 50
  Gamma = 0.00005

type
  Perceptron = object
    supportVectors: seq[array[3, float32]] = @[]
    budget = Budget
    params: RBFParams

  RBFParams = object
    gamma: float32

proc rbfKernel(x1, x2: array[3, float32], params: RBFParams): float32 =
  # RBF/Gaussian Kernel: K(x, y) = exp(-||x-y||^2 * gamma)
  var sum: float32 = 0.0
  for i in 0 ..< NumFeatures:
    sum += (x1[i] - x2[i])*(x1[i] - x2[i])
  result = exp(-sum*params.gamma)

proc predict(p: Perceptron, input: array[3, float32]): float32 =
  var y: float32 = 0.0
  # Use existing support vectors for prediction
  for sv in p.supportVectors:
    y += sv[NumFeatures]*rbfKernel(sv, input, p.params)
  result = y

proc isMisclassified(p: Perceptron, input: array[3, float32]): bool =
  result = p.predict(input)*input[NumFeatures] <= 0

proc train(p: var Perceptron, input: array[3, float32]) =
  # If prediction is wrong, add this vector as a support vector
  if p.isMisclassified(input):
    p.supportVectors.add(input)
  if p.supportVectors.len == p.budget + 1:
    p.supportVectors.del(rand(0..p.budget))

proc accuracy(p: Perceptron; data: openarray[array[3, float32]]): float32 =
  var numCorrect = 0
  var numWrong = 0
  for i in 0..<data.len:
    if p.isMisclassified(data[i]):
      inc numWrong
    else:
      inc numCorrect
  result = (1*numCorrect)/(numCorrect + numWrong)

func f(x: float32): float32 =
  # The formula for a quadratic curve
  0.001'f32*x*x + 0.05'f32*x + 1

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  # Set up the raylib window
  setConfigFlags(flags(Msaa4xHint))
  initWindow(screenWidth, screenHeight, "raylib example - kernel perceptron")
  let camera = Camera2D(zoom: 1)
  randomize()

  var accuracy: float32 = 0
  var perceptron = Perceptron(
    params: RBFParams(gamma: Gamma)
  )
  var training = newSeq[array[3, float32]](NumPoints) # An array for training data
  var count: int32 = 0

  # Make 2,000 training data points
  for i in 0 ..< NumPoints:
    let x = rand(-screenWidth/2'f32..screenWidth/2'f32)
    let y = rand(-screenHeight/2'f32..screenHeight/2'f32)
    training[i] = [x, y, if y > f(x): 1 else: -1]

  # Generate points for the spline
  var points = newSeq[Vector2](SplineSampleCount)
  let xStep = screenWidth.float32/(SplineSampleCount.float32 - 1)
  for i in 0 ..< SplineSampleCount:
    let x = (i.float32*xStep) - screenWidth.float32/2 # Centered x coordinates
    points[i] = Vector2(x: x, y: f(x))

  setTargetFPS(25) # Set our game to run at 25 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    # Train the perceptron
    perceptron.train(training[count])
    # For animation, train one point at a time
    count = (count + 1) mod NumPoints
    # Update accuracy perdiodically
    if count mod 400 == 0:
      accuracy = accuracy(perceptron, training)
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    drawing():
      clearBackground(RayWhite)
      mode2D(camera):
        setCullFace(FaceFront)
        pushMatrix()
        translatef(screenWidth/2'f32, screenHeight/2'f32, 0)
        scalef(1, -1, 1)

        # Draw the quadratic curve
        drawSplineLinear(points, 2, Black)
        # Draw all the points and color according to the output of the perceptron
        for dataPoint in training.items:
          let guess = perceptron.predict(dataPoint)
          let (x, y) = (dataPoint[0].int32, dataPoint[1].int32)
          drawCircle(x, y, 6, DarkGray)
          drawCircle(x, y, 4, if guess > 0: LightGray else: White)

        popMatrix()
        setCullFace(FaceBack)
      drawText(&"Accuracy: {accuracy * 100:.2f}%", 10, 10, 20, DarkGray)
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context

main()
