# AGENTS.md: AI Collaboration Guide

This document provides essential context for AI models interacting with this project. Adhering to these guidelines will ensure consistency and maintain code quality.

## 1. Project Overview & Purpose

* **Primary Goal:** This repository contains raylib examples ported to the Nim programming language, using the naylib wrapper. It serves as both a collection of educational examples and a showcase of naylib's capabilities for 2D/3D game and multimedia application development.
* **Business Domain:** Game development, multimedia applications, educational tools for programming graphics.

## 2. Core Technologies & Stack

* **Languages:** Nim (version 2.0.0 or higher), C (via naylib/raylib)
* **Frameworks & Runtimes:** Raylib (C library for game development via naylib), GLFW (for window management), OpenGL (for graphics rendering)
* **Key Libraries/Dependencies:** naylib (Nim wrapper for raylib)
* **Platforms:** Windows, Linux, macOS, WebAssembly (via Emscripten) - inherited from naylib
* **Package Manager:** Nimble

## 3. Architectural Patterns

* **Overall Architecture:** Example repository demonstrating various raylib features through Nim implementations. Uses naylib as the core binding layer to access raylib functionality with Nim idioms.
* **Directory Structure Philosophy:**
    * `/core`: Basic window and system examples
    * `/audio`: Audio-related examples
    * `/shapes`: 2D shape rendering examples
    * `/textures`: Texture manipulation and rendering examples
    * `/text`: Text rendering and font examples
    * `/models`: 3D model rendering examples
    * `/shaders`: Shader programming examples
    * `/games`: Complete game implementations
    * `/others`: Miscellaneous examples
    * `/personal`: Unique examples created specifically for this repository
    * `/deps`: External dependencies managed by Atlas
    * `/media`: Media assets and screenshots
* **Module Organization:** Each example is a self-contained Nim file that imports raylib and any required standard library modules. Examples follow a consistent structure with initialization, main game loop, and de-initialization sections.

## 4. Coding Conventions & Style Guide

* **Formatting:** Follows Nim's standard style conventions with 2-space indentation.
* **Naming Conventions:** 
    * Variables, procedures: camelCase (`screenWidth`, `initWindow`, `drawRectangle`)
    * Types: PascalCase (`Rectangle`, `Vector2`)
    * Constants: PascalCase (`MaxFrameSpeed`, `MinFrameSpeed`)
    * Files: snake_case for Nim files (`basic_window.nim`, `sprite_button.nim`)
* **API Design:** 
    * Uses naylib's Nim-idiomatic wrappers around raylib C functions
    * Employs proc overloading instead of C-style suffixed function names
    * Uses destructors for automatic resource management where applicable
    * Maps C enums to Nim enums with shortened names
    * Abstracts raw pointers with `openArray[T]` and `cstring` with `string`
    * Provides syntactic sugar for begin-end pairs (templates like `drawing`, `mode3D`)
* **Common Patterns & Idioms:**
    * **Metaprogramming:** Uses templates like `drawing()` and `mode3D()` for scoped operations
    * **Memory Management:** Relies on Nim's destructors
    * **Type Safety:** Uses distinct types where appropriate (e.g., `SpotIdx`)
    * **Concurrency:** Limited use, primarily single-threaded game loops
* **Error Handling:** 
    * Uses Nim's exception system
    * Uses `assert` for precondition checking

## 5. Key Files & Entrypoints

* **Main Entrypoint:** Each example file is a standalone entrypoint (e.g., `core/basic_window.nim`)
* **Configuration:** 
    * `nim.cfg` - Compiler configuration with dependency paths
    * `config.nims` - Build configuration with defines
    * `raylib_examples.nimble` - Package definition and tasks
* **CI/CD Pipeline:** `.github/workflows/ci.yml` for continuous integration

## 6. Development & Testing Workflow

* **Local Development Environment:** 
    To set up the project locally, you need Nim installed.
    * **Install Nim**
      ```bash
      wget https://codeberg.org/janAkali/grabnim/raw/branch/master/misc/install.sh
      sh install.sh
      grabnim
      ```
    * **Setting up the project**
      1. Clone the repository
      2. Run `nimble test` to verify setup
* **Task Configuration:** 
    * **Nimble Tasks:** Run `nimble tasks` to list all available tasks in the .nimble file
    * **Custom .nims Tasks:** Build configuration in `config.nims`
* **Testing:** Run tests via `nimble test`. The test task compiles all examples to verify they build correctly.
* **CI/CD Process:** GitHub Actions workflow that tests on Ubuntu for native builds. Also includes Dependabot for GitHub Actions updates.

## 7. Specific Instructions for AI Collaboration

* **Contribution Guidelines:**
    * Follow the existing code style and naming conventions
    * Ensure examples are self-contained and well-commented
    * Submit pull requests against the `main` branch
* **Security:**
    * Be mindful of security when handling file I/O and external resources
    * Do not hardcode secrets or keys
* **Dependencies:**
    * When adding new dependencies, use Nimble for management
    * Core raylib functionality should go through naylib
* **Commit Messages:** Follow conventional commit messages with clear, descriptive summaries of changes
