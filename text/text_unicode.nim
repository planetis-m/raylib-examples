# ***************************************************************************************
#
# raylib [text] example - Using unicode with raylib
#
# This example has been created using raylib 2.5 (www.raylib.com)
# raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
#
# Example contributed by Vlad Adrian (@demizdor) and reviewed by Ramon Santamaria (@raysan5)
#
# Copyright (c) 2019 Vlad Adrian (@demizdor) and Ramon Santamaria (@raysan5)
#
# ***************************************************************************************

import raylib, std/[lenientops, unicode, random, strformat]

const
  screenWidth = 800
  screenHeight = 450

  EmojiPerWidth = 8
  EmojiPerHeight = 4

# String containing 180 emoji codepoints
const
  emojiCodepoints = "🌀😀😂🤣😃😆😉😋😎😍😘😗😙😚🙂🤗🤩🤔🤨😐😑😶🙄😏😣😥😮🤐😯😪😫😴😌😛😝🤤😒😕🙃🤑😲🙁😖😞😟😤😢😭😦😩🤯😬😰😱😳🤪😵😡😠🤬😷🤒🤕🤢🤮🤧😇🤠🤫🤭🧐🤓😈👿👹👺💀👻👽👾🤖💩😺😸😹😻😽🙀😿🌾🌿🍀🍃🍇🍓🥝🍅🥥🥑🍆🥔🥕🌽🌶🥒🥦🍄🥜🌰🍞🥐🥖🥨🥞🧀🍖🍗🥩🥓🍔🍟🍕🌭🥪🌮🌯🥙🥚🍳🥘🍲🥣🥗🍿🥫🍱🍘🍝🍠🍢🍥🍡🥟🥡🍦🍪🎂🍰🥧🍫🍯🍼🥛🍵🍶🍾🍷🍻🥂🥃🥤🥢👁👅👄💋💘💓💗💙💛🧡💜🖤💝💟💌💤💢💣"

type
  Message = object
    text: string
    language: string

template toMsg(a, b): untyped =
  Message(text: a, language: b)

# Array containing all of the emojis messages
const
  messages: array[47, Message] = [
    toMsg("Falsches Üben von Xylophonmusik quält jeden größeren Zwerg", "German"),
    toMsg("Beiß nicht in die Hand, die dich füttert.", "German"),
    toMsg("Außerordentliche Übel erfordern außerordentliche Mittel.", "German"),
    toMsg("Կրնամ ապակի ուտել և ինծի անհանգիստ չըներ", "Armenian"),
    toMsg("Երբ որ կացինը եկաւ անտառ, ծառերը ասացին... «Կոտը մերոնցից է:»", "Armenian"),
    toMsg("Գառը՝ գարնան, ձիւնը՝ ձմռան", "Armenian"),
    toMsg("Jeżu klątw, spłódź Finom część gry hańb!", "Polish"),
    toMsg("Dobrymi chęciami jest piekło wybrukowane.", "Polish"),
    toMsg("Îți mulțumesc că ai ales raylib.\nȘi sper să ai o zi bună!", "Romanian"),
    toMsg("Эх, чужак, общий съём цен шляп (юфть) вдрызг!", "Russian"),
    toMsg("Я люблю raylib!", "Russian"),
    toMsg("Молчи, скрывайся и таи\nИ чувства и мечты свои –\nПускай в душевной глубине\nИ всходят и зайдут оне\nКак звезды ясные в ночи-\nЛюбуйся ими – и молчи.", "Russian"),
    toMsg("Voix ambiguë d’un cœur qui au zéphyr préfère les jattes de kiwi", "French"),
    toMsg("Benjamín pidió una bebida de kiwi y fresa; Noé, sin vergüenza, la más exquisita champaña del menú.", "Spanish"),
    toMsg("Ταχίστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός", "Greek"),
    toMsg("Η καλύτερη άμυνα είναι η επίθεση.", "Greek"),
    toMsg("Χρόνια και ζαμάνια!", "Greek"),
    toMsg("Πώς τα πας σήμερα;", "Greek"),
    toMsg("我能吞下玻璃而不伤身体。", "Chinese"),
    toMsg("你吃了吗？", "Chinese"),
    toMsg("不作不死。", "Chinese"),
    toMsg("最近好吗？", "Chinese"),
    toMsg("塞翁失马，焉知非福。", "Chinese"),
    toMsg("千军易得, 一将难求", "Chinese"),
    toMsg("万事开头难。", "Chinese"),
    toMsg("风无常顺，兵无常胜。", "Chinese"),
    toMsg("活到老，学到老。", "Chinese"),
    toMsg("一言既出，驷马难追。", "Chinese"),
    toMsg("路遥知马力，日久见人心", "Chinese"),
    toMsg("有理走遍天下，无理寸步难行。", "Chinese"),
    toMsg("猿も木から落ちる", "Japanese"),
    toMsg("亀の甲より年の功", "Japanese"),
    toMsg("うらやまし  思ひ切る時  猫の恋", "Japanese"),
    toMsg("虎穴に入らずんば虎子を得ず。", "Japanese"),
    toMsg("二兎を追う者は一兎をも得ず。", "Japanese"),
    toMsg("馬鹿は死ななきゃ治らない。", "Japanese"),
    toMsg("枯野路に　影かさなりて　わかれけり", "Japanese"),
    toMsg("繰り返し麦の畝縫ふ胡蝶哉", "Japanese"),
    toMsg("아득한 바다 위에 갈매기 두엇 날아 돈다.\n너훌너훌 시를 쓴다. 모르는 나라 글자다.\n널따란 하늘 복판에 나도 같이 시를 쓴다.", "Korean"),
    toMsg("제 눈에 안경이다", "Korean"),
    toMsg("꿩 먹고 알 먹는다", "Korean"),
    toMsg("로마는 하루아침에 이루어진 것이 아니다", "Korean"),
    toMsg("고생 끝에 낙이 온다", "Korean"),
    toMsg("개천에서 용 난다", "Korean"),
    toMsg("안녕하세요?", "Korean"),
    toMsg("만나서 반갑습니다", "Korean"),
    toMsg("한국말 하실 줄 아세요?", "Korean")
  ]

# ---------------------------------------------------------------------------------------
# Global variables
# ---------------------------------------------------------------------------------------

type
  Emoji = object
    index: int32   # Index inside `emojiCodepoints`
    message: int32 # Message index
    color: Color  # Emoji color

var
  emoji: array[EmojiPerWidth*EmojiPerHeight, Emoji] # Arrays that holds the random emojis
  hovered, selected = -1

# ---------------------------------------------------------------------------------------
# Module functions declaration
# ---------------------------------------------------------------------------------------

proc randomizeEmoji() =
  # Fills the emoji array with random emoji (only those emojis present in fontEmoji)
  hovered = -1
  selected = -1
  let start = rand(45..360).int32
  for i in 0 ..< len(emoji):
    # 0-179 emoji codepoints (from emoji char array) each 4bytes
    emoji[i].index = rand(0..179).int32
    # Generate a random color for this emoji
    emoji[i].color = fade(colorFromHSV(float32(start * (i + 1) mod 360), 0.6, 0.85), 0.8)
    # Set a random message for this emoji
    emoji[i].message = rand(0..high(messages).int).int32

type
  State = enum
    Measure
    Draw

proc `not`(x: State): State = State(not x.bool)

proc drawTextBoxedSelectable(font: Font; text: string; rec: Rectangle;
    fontSize: float32; spacing: float32; wordWrap: bool;
    tint: Color; selectStart: int32; selectLength: int32;
    selectTint: Color; selectBackTint: Color) =
  # Draw text using font inside rectangle limits with support for text selection
  var selectStart = selectStart
  let length = len(text).int32 # Total length in bytes of the text, scanned by codepoints in loop
  var textOffsetY = 0'f32 # Offset between lines (on line break '\n')
  var textOffsetX = 0'f32 # Offset X to next character to draw
  let scaleFactor = fontSize / font.baseSize.float32 # Character rectangle scaling factor
  # Word/character wrapping mechanism variables
  var state = if wordWrap: Measure else: Draw
  var startLine = -1'i32
  # Index where to begin drawing (where a line begins)
  var endLine = -1'i32
  # Index where to stop drawing (where a line ends)
  var lastk = -1'i32
  # Holds last value of the character position
  var
    i = 0'i32
    k = 0'i32
  while i < length:
    # Get next codepoint from byte string and glyph index in font
    var codepoint = runeAt(text, i)
    var codepointByteCount = codepoint.size.int32
    var index = getGlyphIndex(font, codepoint)
    # NOTE: Normally we exit the decoding sequence as soon as a bad byte is found (and return 0xFFFD)
    # but we need to draw all of the bad bytes using the '?' symbol moving three bytes
    if codepoint == Rune(0xFFFD):
      codepointByteCount = 3
    inc(i, codepointByteCount - 1)
    var glyphWidth = 0'f32
    if codepoint != '\n'.Rune:
      glyphWidth = if font.glyphs[index].advanceX == 0: font.recs[index].width * scaleFactor
          else: font.glyphs[index].advanceX * scaleFactor
      if i + 1 < length:
        glyphWidth = glyphWidth + spacing
    if state == Measure:
      # TODO: There are multiple types of spaces in UNICODE, maybe use unicode.isWhiteSpace
      if codepoint == ' '.Rune or codepoint == '\t'.Rune or codepoint == '\n'.Rune:
        endLine = i
      if textOffsetX + glyphWidth > rec.width:
        endLine = if endLine < 1: i else: endLine
        if i == endLine:
          dec(endLine, codepointByteCount)
        if startLine + codepointByteCount == endLine:
          endLine = i - codepointByteCount
        state = not state
      elif i + 1 == length:
        endLine = i
        state = not state
      elif codepoint == '\n'.Rune:
        state = not state
      if state == Draw:
        textOffsetX = 0
        i = startLine
        glyphWidth = 0
        # Save character position when we switch states
        var tmp = lastk
        lastk = k - 1
        k = tmp
    else:
      if codepoint == '\n'.Rune:
        if not wordWrap:
          textOffsetY += (font.baseSize + font.baseSize div 2) * scaleFactor
          textOffsetX = 0
      else:
        if not wordWrap and textOffsetX + glyphWidth > rec.width:
          textOffsetY += (font.baseSize + font.baseSize div 2) * scaleFactor
          textOffsetX = 0
        if textOffsetY + font.baseSize * scaleFactor > rec.height:
          break
        var isGlyphSelected = false
        if selectStart >= 0 and k >= selectStart and k < selectStart + selectLength:
          drawRectangleRec(Rectangle(x: rec.x + textOffsetX - 1, y: rec.y + textOffsetY,
              width: glyphWidth, height: font.baseSize * scaleFactor), selectBackTint)
          isGlyphSelected = true
        if codepoint != ' '.Rune and codepoint != '\t'.Rune:
          drawTextCodepoint(font, codepoint, Vector2(x: rec.x + textOffsetX,
              y: rec.y + textOffsetY), fontSize, if isGlyphSelected: selectTint else: tint)
      if wordWrap and i == endLine:
        textOffsetY += (font.baseSize + font.baseSize div 2) * scaleFactor
        textOffsetX = 0
        startLine = endLine
        endLine = -1
        glyphWidth = 0
        inc(selectStart, lastk - k)
        k = lastk
        state = not state
    textOffsetX += glyphWidth
    inc(i)
    inc(k)

proc drawTextBoxed(font: Font; text: string; rec: Rectangle; fontSize: float32;
    spacing: float32; wordWrap: bool; tint: Color) {.inline.} =
  # Draw text using font inside rectangle limits
  drawTextBoxedSelectable(font, text, rec, fontSize, spacing, wordWrap, tint, 0, 0, White, White)

# ---------------------------------------------------------------------------------------
# Main entry point
# ---------------------------------------------------------------------------------------

proc main =
  # Initialization
  # -------------------------------------------------------------------------------------
  randomize()
  setConfigFlags(flags(FlagMsaa4xHint, FlagVsyncHint))
  initWindow(screenWidth, screenHeight, "raylib [text] example - unicode")
  defer: closeWindow() # Close window and OpenGL context
  # Load the font resources
  # NOTE: fontAsian is for asian languages,
  # fontEmoji is the emojis and fontDefault is used for everything else
  let fontDefault = loadFont("resources/dejavu.fnt")
  let fontAsian = loadFont("resources/noto_cjk.fnt")
  let fontEmoji = loadFont("resources/symbola.fnt")
  var hoveredPos = Vector2(x: 0, y: 0)
  var selectedPos = Vector2(x: 0, y: 0)
  # Set a random set of emojis when starting up
  randomizeEmoji()
  setTargetFPS(60) # Set our game to run at 60 frames-per-second
  # -------------------------------------------------------------------------------------
  # Main loop
  while not windowShouldClose(): # Detect window close button or ESC key
    # Update
    # -----------------------------------------------------------------------------------
    # Add a new set of emojis when SPACE is pressed
    if isKeyPressed(KeySpace):
      randomizeEmoji()
    if isMouseButtonPressed(MouseButtonLeft) and hovered != -1 and
        hovered != selected:
      selected = hovered
      selectedPos = hoveredPos
      setClipboardText(messages[emoji[selected].message].text)
    let mouse = getMousePosition()
    var pos = Vector2(x: 28.8, y: 10)
    hovered = -1
    # -----------------------------------------------------------------------------------
    # Draw
    # -----------------------------------------------------------------------------------
    beginDrawing()
    clearBackground(RayWhite)
    # Draw random emojis in the background
    # -----------------------------------------------------------------------------------
    for i in 0 ..< len(emoji):
      # Assume that the size of each emoji is one Rune (4 bytes)
      let txt = runeSubStr(emojiCodepoints, emoji[i].index, 1)
      var emojiRect = Rectangle(x: pos.x, y: pos.y, width: fontEmoji.baseSize.float32,
          height: fontEmoji.baseSize.float32)
      if not checkCollisionPointRec(mouse, emojiRect):
        drawTextEx(fontEmoji, txt, pos, fontEmoji.baseSize.float32, 1,
            if selected == i: emoji[i].color else: fade(LightGray, 0.4))
      else:
        drawTextEx(fontEmoji, txt, pos, fontEmoji.baseSize.float32, 1, emoji[i].color)
        hovered = i
        hoveredPos = pos
      if i != 0 and i mod EmojiPerWidth == 0:
        pos.y += fontEmoji.baseSize + 24.25'f32
        pos.x = 28.8'f32
      else:
        pos.x += fontEmoji.baseSize + 28.8'f32
    # -----------------------------------------------------------------------------------
    # Draw the message when a emoji is selected
    # -----------------------------------------------------------------------------------
    if selected != -1:
      let
        message = emoji[selected].message
        horizontalPadding = 20'i32
        verticalPadding = 30'i32
      var font {.cursor.} = fontDefault
      # Set correct font for asian languages
      if messages[message].language in ["Chinese", "Korean", "Japanese"]:
        font = fontAsian
      var sz = measureTextEx(font, messages[message].text, font.baseSize.float32, 1)
      if sz.x > 300:
        sz.y = sz.y * (sz.x / 300)
        sz.x = 300
      elif sz.x < 160:
        sz.x = 160
      var msgRect = Rectangle(x: selectedPos.x - 38.8f, y: selectedPos.y,
          width: 2 * horizontalPadding + sz.x, height: 2 * verticalPadding + sz.y)
      msgRect.y -= msgRect.height
      # Coordinates for the chat bubble triangle
      var
        a = Vector2(x: selectedPos.x, y: msgRect.y + msgRect.height)
        b = Vector2(x: a.x + 8, y: a.y + 10)
        c = Vector2(x: a.x + 10, y: a.y)
      # Don't go outside the screen
      if msgRect.x < 10:
        msgRect.x += 28
      if msgRect.y < 10:
        msgRect.y = selectedPos.y + 84
        a.y = msgRect.y
        c.y = a.y
        b.y = a.y - 10
        # Swap values so we can actually render the triangle :(
        swap(a, b)
      if msgRect.x + msgRect.width > screenWidth:
        msgRect.x -= (msgRect.x + msgRect.width) - screenWidth + 10
      drawRectangleRec(msgRect, emoji[selected].color)
      drawTriangle(a, b, c, emoji[selected].color)
      # Draw the main text message
      let textRect = Rectangle(x: msgRect.x + horizontalPadding div 2,
          y: msgRect.y + verticalPadding div 2,
          width: msgRect.width - horizontalPadding, height: msgRect.height)
      drawTextBoxed(font, messages[message].text, textRect,
          font.baseSize.float32, 1, true, White)
      # Draw the info text below the main message
      let size = len(messages[message].text)
      let length = runeLen(messages[message].text)
      let info = &"{messages[message].language} {length} characters {size} bytes"
      sz = measureTextEx(getFontDefault(), info, 10, 1)
      let pos = Vector2(x: textRect.x + textRect.width - sz.x,
          y: msgRect.y + msgRect.height - sz.y - 2)
      drawText(info, pos.x.int32, pos.y.int32, 10, RayWhite)
    drawText("These emojis have something to tell you, click each to find out!",
        (screenWidth - 650) div 2, screenHeight - 40, 20, Gray)
    drawText("Each emoji is a unicode character from a font, not a texture... Press [SPACEBAR] to refresh",
        (screenWidth - 484) div 2, screenHeight - 16, 10, Gray)
    endDrawing()
    # -----------------------------------------------------------------------------------

main()
