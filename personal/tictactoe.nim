# ttt.nim
# Nim + raylib Tic-Tac-Toe (single file, minimal, with a worker AI thread)
# - Main thread: rendering + player input
# - Worker thread: computes AI move when signaled (mutex + condition variable)
# - Only the main thread touches raylib drawing calls (BeginDrawing/EndDrawing)

import raylib
import std/locks

# ----------------------------
# Small helpers and game model
# ----------------------------
type
  Board = array[9, int] # 0 empty, 1 = X (human), 2 = O (AI)

const
  W = 480
  H = 520
  Margin = 30
  TopBar = 60
  CellSize = (W - Margin * 2) div 3
  GridSize = CellSize * 3
  GridX = Margin
  GridY = TopBar

  # All winning triples (indices)
  Wins = [
    [0,1,2], [3,4,5], [6,7,8],     # rows
    [0,3,6], [1,4,7], [2,5,8],     # cols
    [0,4,8], [2,4,6]               # diagonals
  ]

func vec2(x, y: float32): Vector2 =
  Vector2(x: x, y: y)

proc checkWinner(b: Board): int =
  # Returns: 0 = none, 1 = X, 2 = O, 3 = draw
  for line in Wins:
    let a = b[line[0]]
    if a != 0 and b[line[1]] == a and b[line[2]] == a:
      return a
  for i in 0..8:
    if b[i] == 0: return 0
  return 3

proc findWinningMove(b: Board, p: int): int =
  for i in 0..8:
    if b[i] == 0:
      var tmp = b
      tmp[i] = p
      if checkWinner(tmp) == p:
        return i
  return -1

proc aiChooseMove(b: Board): int =
  # Simple rule-based AI: win -> block -> center -> corners -> sides
  let mine = 2
  let opp = 1

  var m = findWinningMove(b, mine)
  if m != -1: return m

  m = findWinningMove(b, opp)
  if m != -1: return m

  let order = [4, 0, 2, 6, 8, 1, 3, 5, 7]
  for idx in order:
    if b[idx] == 0: return idx

  for i in 0..8:
    if b[i] == 0: return i
  return -1

# ----------------------------
# Shared state for AI thread
# ----------------------------
var
  gLock: Lock        # protects the shared state below
  gCond: Cond        # AI sleeps here until signaled
  aiHasJob = false
  aiHasResult = false
  aiInput: Board
  aiOutput: int = -1
  quitting = false

proc aiWorker() {.thread.} =
  # Worker AI thread:
  # - Sleeps on condition var
  # - Wakes only when main thread posts a job
  # - Computes move and posts result back
  while true:
    acquire(gLock)
    while not aiHasJob and not quitting:
      wait(gCond, gLock)          # releases lock while waiting, re-acquires on wake
    if quitting:
      release(gLock)
      break
    let b = aiInput               # copy job locally
    aiHasJob = false
    release(gLock)

    let move = aiChooseMove(b)    # compute AI move (no drawing here)

    acquire(gLock)
    aiOutput = move
    aiHasResult = true
    release(gLock)

# ----------------------------
# Drawing helpers (main thread)
# ----------------------------
proc drawGrid() =
  let t = 6.0'f32
  for i in 1..2:
    let x = (GridX + i * CellSize).float32
    let y = (GridY + i * CellSize).float32
    drawLine(vec2(x, GridY), vec2(x, GridY + GridSize), t, DarkGray)   # vertical
    drawLine(vec2(GridX, y), vec2(GridX + GridSize, y), t, DarkGray)   # horizontal

proc drawX(cx, cy: float32, size: float32, thick: float32) =
  let h = size * 0.45
  drawLine(vec2(cx - h, cy - h), vec2(cx + h, cy + h), thick, Black)
  drawLine(vec2(cx - h, cy + h), vec2(cx + h, cy - h), thick, Black)

proc drawO(cx, cy: float32, radius: float32, thick: float32) =
  # Draw a ring: outer filled circle - inner filled circle (background color)
  drawCircle(cx.int32, cy.int32, radius, Black)
  drawCircle(cx.int32, cy.int32, radius - thick, RayWhite)

proc drawBoard(b: Board) =
  drawGrid()
  for i in 0..8:
    let r = i div 3
    let c = i mod 3
    let cx = (GridX + c * CellSize + CellSize div 2).float32
    let cy = (GridY + r * CellSize + CellSize div 2).float32
    if b[i] == 1:
      drawX(cx, cy, CellSize, 8.0)
    elif b[i] == 2:
      drawO(cx, cy, CellSize.float32 * 0.40, 8.0)

proc idxFromMouse(mx, my: float32): int =
  if mx < GridX.float32 or mx >= (GridX + GridSize).float32: return -1
  if my < GridY.float32 or my >= (GridY + GridSize).float32: return -1
  let col = int((mx - GridX.float32) / CellSize.float32)
  let row = int((my - GridY.float32) / CellSize.float32)
  return row * 3 + col

# ----------------------------
# Main program
# ----------------------------
proc main =
  initLock(gLock)
  initCond(gCond)

  var worker: Thread[void]
  createThread(worker, aiWorker)

  var board: Board
  var current = 1 # 1 = player(X), 2 = AI(O)

  initWindow(W, H, "Nim + raylib: Tic-Tac-Toe")
  setTargetFPS(60)

  while not windowShouldClose():
    # Input (main thread only)
    let state = checkWinner(board)
    if state == 0 and current == 1:
      if isMouseButtonPressed(Left):
        let pos = getMousePosition()
        let idx = idxFromMouse(pos.x, pos.y)
        if idx >= 0 and board[idx] == 0:
          board[idx] = 1
          # If game isn't over, ask AI to move (wake worker thread)
          if checkWinner(board) == 0:
            acquire(gLock)
            aiInput = board
            aiHasJob = true
            aiHasResult = false
            signal(gCond)   # wake the worker
            release(gLock)
            current = 2

    # Collect AI result (non-blocking; main loop keeps rendering)
    if current == 2:
      acquire(gLock)
      if aiHasResult:
        let move = aiOutput
        aiHasResult = false
        release(gLock)
        if move >= 0 and board[move] == 0:
          board[move] = 2
        current = 1
      else:
        release(gLock)

    # (Optional) restart with R
    if isKeyPressed(R):
      board = [0,0,0,0,0,0,0,0,0]
      current = 1
      acquire(gLock)
      aiHasJob = false
      aiHasResult = false
      release(gLock)

    # Rendering (main thread only)
    beginDrawing()
    clearBackground(RayWhite)

    drawBoard(board)

    var msg = ""
    let s = checkWinner(board)
    case s
    of 1: msg = "X wins! Press R to restart."
    of 2: msg = "O wins! Press R to restart."
    of 3: msg = "Draw! Press R to restart."
    else:
      if current == 1: msg = "Your turn (X)."
      else: msg = "AI is thinking..."

    let fontSize: int32 = 24
    let tw = measureText(msg, fontSize)
    drawText(msg, (W - tw) div 2, 16, fontSize, Black)

    endDrawing()
  # Cleanup
  acquire(gLock)
  quitting = true
  signal(gCond)
  release(gLock)
  joinThread(worker)

  deinitCond(gCond)
  deinitLock(gLock)
  closeWindow()

main()

