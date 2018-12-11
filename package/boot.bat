@echo off
REM Copyright 2016 Google Inc. Use of this source code is governed by an
REM MIT-style license that can be found in the LICENSE file or at
REM https://opensource.org/licenses/MIT.

REM This script drives a standalone package, which bundles together a
REM Dart executable and a snapshot of the package. It can be created with `pub run
REM grinder package`.

set SCRIPTPATH=%~dp0
set arguments=%*
"%SCRIPTPATH%\src\dart.exe" "-Dversion=PROJECT_VERSION" "%SCRIPTPATH%\src\PROJECT_NAME.dart.snapshot" %arguments%
