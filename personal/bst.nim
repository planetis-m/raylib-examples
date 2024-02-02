# ****************************************************************************************
#
#   naylib example - binary search tree
#
#   Example originally created with naylib 5.1
#
#   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
#   BSD-like license that allows static linking with closed source software
#
#   Copyright (c) 2024 Antonis Geralis (@planetis-m)
#
# ****************************************************************************************

import raylib, std/[random, lenientops]

const
  screenWidth = 800
  screenHeight = 450

type
  Node = ref object
    key: int
    left, right: Node

proc insertNode(root: Node, key: int): Node =
  # Insert a new node into the binary search tree
  if root == nil:
    return Node(key: key)
  if key < root.key:
    root.left = insertNode(root.left, key)
  else:
    root.right = insertNode(root.right, key)
  return root

proc drawNode(node: Node, x, y, radius, depth, horizontal, vertical: int32) =
  # Draw a node and its children on the screen
  if node != nil:
    # Draw the node as a circle
    drawCircle(x, y, radius.float32, Black)
    drawCircle(x, y, radius - 2'f32, White)
    # Draw the key as a text inside the circle
    let keyStr = $node.key
    let keyWidth = measureText(keyStr, 20)
    drawText(keyStr, x - keyWidth div 2, y - 10, 20, Black)
    # Draw the children with a smaller radius and a line to the parent
    if node.left != nil:
      # Calculate the coordinates of the center of the left child
      let leftX = x - horizontal div (depth + 1)
      let leftY = y + vertical
      drawLine(x, y + radius, leftX, leftY - radius, Black)
      drawNode(node.left, leftX, leftY, radius, depth + 1, horizontal, vertical - 10)
    if node.right != nil:
      # Calculate the coordinates of the center of the right child
      let rightX = x + horizontal div (depth + 1)
      let rightY = y + vertical
      drawLine(x, y + radius, rightX, rightY - radius, Black)
      drawNode(node.right, rightX, rightY, radius, depth + 1, horizontal, vertical - 10)

# ----------------------------------------------------------------------------------------
# Program main entry point
# ----------------------------------------------------------------------------------------

proc main =
  # Initialization
  # --------------------------------------------------------------------------------------
  # Set up the raylib window
  setConfigFlags(flags(Msaa4xHint))
  initWindow(screenWidth, screenHeight, "raylib [core] example - binary search tree")
  randomize()
  # Create the binary search tree and insert some nodes
  var root: Node = nil
  for i in 0 ..< 10:
    let key = rand(10..99) # Generate a random key between 10 and 99
    root = insertNode(root, key) # Insert the key into the BST
  setTargetFPS(60)
  # --------------------------------------------------------------------------------------
  # Main game loop
  while not windowShouldClose():
    # Update
    # ------------------------------------------------------------------------------------
    # Check if the user presses the space key
    if isKeyPressed(Space):
      # Insert a new random key into the BST
      let key = rand(10..99)
      root = insertNode(root, key)
    # ------------------------------------------------------------------------------------
    # Draw
    # ------------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    drawText("Press SPACE to insert a new node", 10, 10, 20, DarkGray)
    # Draw the binary search tree
    drawNode(root, screenWidth div 2, 40, 20, 1, screenWidth div 4, 80)
    endDrawing()
    # ------------------------------------------------------------------------------------
  # De-Initialization
  # --------------------------------------------------------------------------------------
  closeWindow() # Close window and OpenGL context

main()
