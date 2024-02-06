# ****************************************************************************************
#
#   naylib example - raylib perceptron
#
#   The example is inspired by Chapter 10 of The Nature of Code
#   by Daniel Shiffman (http://natureofcode.com/book/chapter-10-neural-networks/).
#
#   Example originally created with naylib 5.1
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2024 Antonis Geralis (@planetis-m)
#
# ****************************************************************************************

import raylib, std/random

const
  screenWidth = 800
  screenHeight = 450

  NumPoints = 2000

type
  Perceptron = object
    weights: array[3, float32] # The perceptron has three inputs (including bias)
    lr: float32 # The learning rate

proc initPerceptron(lr: float32): Perceptron =
  # Initialize the perceptron with random weights and a given learning rate
  result = Perceptron(lr: lr)
  for i in 0 ..< 3:
    result.weights[i] = rand(-100'f32..100'f32) / 100'f32

proc feedForward(p: Perceptron, input: array[3, float32]): int32 =
  # Feedforward the input and get the output (1 or -1)
  var sum = 0'f32
  for i in 0 ..< 3:
    sum += input[i] * p.weights[i]
  result = if sum >= 0: 1 else: -1

proc train(p: var Perceptron, input: array[3, float32], desired: int32) =
  # Train the perceptron with one input and the desired output
  let guess = p.feedForward(input)
  let error = desired - guess
  for i in 0 ..< 3:
    p.weights[i] += error.float32*input[i]*p.lr

func f(x: float32): float32 =
  # The formula for a line
  0.5'f32*x + 1

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  # Set up the raylib window
  setConfigFlags(flags(Msaa4xHint))
  initWindow(screenWidth, screenHeight, "raylib - perceptron")
  let camera = Camera2D(
    offset: Vector2(x: screenWidth div 2, y: screenHeight div 2),
    zoom: -1
  )
  randomize()
  var perceptron = initPerceptron(0.0001) # The perceptron with a learning rate of 0.0001
  var training: array[NumPoints, array[3, float32]] # An array for training data
  var count: int32 = 0 # A counter to track training data points one by one
  # Make 2,000 training data points
  for i in 0 ..< NumPoints:
    let x = rand(-screenWidth/2'f32..screenWidth/2'f32)
    let y = rand(-screenHeight/2'f32..screenHeight/2'f32)
    training[i] = [x, y, 1]
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # ------------------------------------------------------------------------------------
    # Get the current (x, y) of the training data
    let x = training[count][0]
    let y = training[count][1]
    # What is the desired output?
    let desired: int32 = if y > f(x): 1 else: -1
    # Train the perceptron
    perceptron.train(training[count], desired)
    # For animation, train one point at a time
    count = (count + 1) mod NumPoints
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    drawing():
      clearBackground(RayWhite)
      # Reorient the canvas to match a traditional Cartesian plane
      mode2D(camera):
        # Draw the line
        drawLine(Vector2(x: -screenWidth/2'f32, y: f(-screenWidth/2'f32)),
            Vector2(x: screenWidth/2'f32, y: f(screenWidth/2'f32)), 2, Black)
        # Draw all the points and color according to the output of the perceptron
        for dataPoint in training.items:
          let guess = perceptron.feedForward(dataPoint)
          let pos = Vector2(x: dataPoint[0], y: dataPoint[1])
          drawCircle(pos, 6, DarkGray)
          drawCircle(pos, 4, if guess > 0: LightGray else: White)
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context

main()
