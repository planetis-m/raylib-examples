# Package
version       = "1.2.3"
author        = "Antonis Geralis"
description   = "Raylib examples"
license       = "Public Domain"

# Dependencies
requires "naylib"

# Tasks
import std/[os, strutils]

task test, "Runs the test suite":
  for dir in ["audio", "core", "games", "models", "others",
              "personal", "shaders", "shapes", "text", "textures"]:
    for f in listFiles(thisDir().quoteShell / dir):
      if f.endsWith("maploader.nim"): continue # skip import
      if f.endsWith(".nim"):
        echo "Compiling example: ", f
        exec "nim c -d:release --verbosity:0 --hints:off " & quoteShell(f)
requires "https://github.com/planetis-m/mimalloc_nim"

