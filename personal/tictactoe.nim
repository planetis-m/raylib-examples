# Nim + raylib Tic-Tac-Toe
# - Main thread: rendering + player input
# - Worker thread: computes AI move when signaled (mutex + condition variable)
# - Only the main thread touches raylib drawing calls (BeginDrawing/EndDrawing)

import raylib
import std/locks

# ----------------------------
# Small helpers and game model
# ----------------------------
type
  Cell = enum
    Empty, # 0
    X,     # 1 (human)
    O      # 2 (AI)
  Board = array[9, Cell]
  GameState = enum
    None,    # Game ongoing
    XWins,   # X wins
    OWins,   # O wins
    Draw     # Draw

const
  ScreenWidth: int32 = 480
  ScreenHeight: int32 = 520
  Margin = 30
  TopBar = 60
  CellSize = (ScreenWidth - Margin * 2) div 3
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

proc checkWinner(b: Board): GameState =
  # Returns: 0 = none, 1 = X, 2 = O, 3 = draw
  for line in Wins:
    let a = b[line[0]]
    if a != Empty and b[line[1]] == a and b[line[2]] == a:
      if a == X: return XWins
      else: return OWins
  for i in 0..8:
    if b[i] == Empty: return None
  return Draw

# ----------
# Minimax AI
# ----------
proc scoreState(b: Board, depth: int): int =
  # Favor quick wins (10 - depth) and delay losses (-10 + depth)
  case checkWinner(b)
  of OWins: 10 - depth   # O (AI) wins
  of XWins: depth - 10   # X (human) wins
  of Draw: 0             # draw
  of None: 0             # non-terminal; not used directly

proc minimax(b: var Board, player: Cell, depth: int): int =
  let state = checkWinner(b)
  if state != GameState.None:
    return scoreState(b, depth)

  if player == O: # AI's turn: maximize
    var best = -1_000
    for i in 0..8:
      if b[i] == Empty:
        b[i] = O
        let val = minimax(b, X, depth + 1)
        b[i] = Empty
        if val > best: best = val
    return best
  else:           # Human's turn: minimize
    var best = 1_000
    for i in 0..8:
      if b[i] == Empty:
        b[i] = X
        let val = minimax(b, O, depth + 1)
        b[i] = Empty
        if val < best: best = val
    return best

proc aiChooseMove(b: Board): int =
  # Pick the move with the best Minimax score for O (AI)
  var work = b
  var bestScore = -1_000
  var bestMove = -1
  for i in 0..8:
    if work[i] == Empty:
      work[i] = O
      let sc = minimax(work, X, 1)
      work[i] = Empty
      if sc > bestScore:
        bestScore = sc
        bestMove = i
  return bestMove

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

proc aiWorker() {.nimcall.} =
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

    let move = aiChooseMove(b)    # compute AI move

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
    drawLine(vec2(x, GridY.float32), vec2(x, float32(GridY + GridSize)), t, DarkGray)   # vertical
    drawLine(vec2(GridX.float32, y), vec2(float32(GridX + GridSize), y), t, DarkGray)   # horizontal

proc drawX(cx, cy: float32, size: float32, thick: float32) =
  let h = size * 0.45'f32
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
    if b[i] == X:
      drawX(cx, cy, CellSize.float32, 8.0'f32)
    elif b[i] == O:
      drawO(cx, cy, CellSize.float32 * 0.40'f32, 8.0'f32)

proc idxFromMouse(mx, my: float32): int =
  if mx < GridX.float32 or mx >= (GridX + GridSize).float32: return -1
  if my < GridY.float32 or my >= (GridY + GridSize).float32: return -1
  let col = int((mx - GridX.float32) / CellSize.float32)
  let row = int((my - GridY.float32) / CellSize.float32)
  return row * 3 + col

# ------------------
# Game loop function
# ------------------
proc runGameLoop =
  var board = default(Board)
  var current = X # X = player, O = AI

  setTargetFPS(60)
  while not windowShouldClose():
    # Input (main thread only)
    let state = checkWinner(board)
    if state == None and current == X:
      if isMouseButtonPressed(Left):
        let pos = getMousePosition()
        let idx = idxFromMouse(pos.x, pos.y)
        if idx >= 0 and board[idx] == Empty:
          board[idx] = X
          # If game isn't over, ask AI to move (wake worker thread)
          if checkWinner(board) == None:
            acquire(gLock)
            aiInput = board
            aiHasJob = true
            aiHasResult = false
            signal(gCond)   # wake the worker
            release(gLock)
            current = O

    # Collect AI result (non-blocking; main loop keeps rendering)
    if current == O:
      acquire(gLock)
      if aiHasResult:
        let move = aiOutput
        aiHasResult = false
        release(gLock)
        if move >= 0 and board[move] == Empty:
          board[move] = O
        current = X
      else:
        release(gLock)

    # (Optional) restart with R
    if isKeyPressed(R):
      board = default(Board)
      current = X
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
    of XWins: msg = "X wins! Press R to restart."
    of OWins: msg = "O wins! Press R to restart."
    of Draw: msg = "Draw! Press R to restart."
    of None:
      if current == X: msg = "Your turn (X)."
      else: msg = "AI is thinking..."

    let fontSize: int32 = 24
    let tw = measureText(msg, fontSize)
    drawText(msg, (ScreenWidth - tw) div 2, 16, fontSize, Black)

    endDrawing()

# ----------------------------
# Main program
# ----------------------------
proc main =
  initLock(gLock)
  initCond(gCond)

  var worker: Thread[void]
  try: createThread(worker, aiWorker)
  except: quit("Failed to start AI thread")

  setConfigFlags(flags(WindowHighDPI))
  initWindow(ScreenWidth, ScreenHeight, "Tic-Tac-Toe")
  try:
    runGameLoop()
  finally:
    closeWindow()

  # Cleanup
  acquire(gLock)
  quitting = true
  signal(gCond)
  release(gLock)
  joinThread(worker)

  deinitCond(gCond)
  deinitLock(gLock)

main()

