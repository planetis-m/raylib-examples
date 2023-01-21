const AndroidApi = 29
const AndroidNdk = "/opt/android-ndk"
when defined(windows):
  const AndroidToolchain = AndroidNdk & "/toolchains/llvm/prebuilt/windows-x86_64"
elif defined(linux):
  const AndroidToolchain = AndroidNdk & "/toolchains/llvm/prebuilt/linux-x86_64"
elif defined(macosx):
  const AndroidToolchain = AndroidNdk & "/toolchains/llvm/prebuilt/darwin-x86_64"
const AndroidSysroot = AndroidToolchain & "/sysroot"

switch("arm.android.clang.path", AndroidToolchain & "/bin")
switch("arm.android.clang.exe", "armv7a-linux-androideabi" & $AndroidApi & "-clang")
switch("arm.android.clang.cpp.exe", "armv7a-linux-androideabi" & $AndroidApi & "-clang++")
switch("arm.android.clang.linkerexe", "llvm-ar")

switch("arm64.android.clang.path", AndroidToolchain & "/bin")
switch("arm64.android.clang.exe", "aarch64-linux-android" & $AndroidApi & "-clang")
switch("arm64.android.clang.cpp.exe", "aarch64-linux-android" & $AndroidApi & "-clang++")
switch("arm64.android.clang.linkerexe", "llvm-ar")

switch("i386.android.clang.path", AndroidToolchain & "/bin")
switch("i386.android.clang.exe", "i686-linux-android" & $AndroidApi & "-clang")
switch("i386.android.clang.cpp.exe", "i686-linux-android" & $AndroidApi & "-clang++")
switch("i386.android.clang.linkerexe", "llvm-ar")

switch("amd64.android.clang.path", AndroidToolchain & "/bin")
switch("amd64.android.clang.exe", "x86_64-linux-android" & $AndroidApi & "-clang")
switch("amd64.android.clang.cpp.exe", "x86_64-linux-android" & $AndroidApi & "-clang++")
switch("amd64.android.clang.linkerexe", "llvm-ar")

when defined(android):
  --define:GraphicsApiOpenGlEs2

  switch("define", "AndroidApi=" & $AndroidApi)
  switch("define", "AndroidNdk=" & AndroidNdk)

  --cpu:arm64
  --cc:clang

  switch("passC", "-I" & AndroidSysroot & "/usr/include")
  when hostCPU == "arm":
    switch("passC", "-march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16")
    switch("passC", "-I" & AndroidSysroot & "/usr/include/arm-linux-androideabi")
  elif hostCPU == "arm64":
    switch("passC", "-target aarch64 -mfix-cortex-a53-835769")
    switch("passC", "-I" & AndroidSysroot & "/usr/include/aarch64-linux-android")
  elif hostCPU == "i386":
    switch("passC", "-march=i686")
    switch("passC", "-I" & AndroidSysroot & "/usr/include/i686-linux-android")
  elif hostCPU == "amd64":
    switch("passC", "-march=x86-64")
    switch("passC", "-I" & AndroidSysroot & "/usr/include/x86_64-linux-android")
  # --define:androidNDK
  --mm:orc
  # --threads:off
  --panics:on
  --define:noSignalHandler
