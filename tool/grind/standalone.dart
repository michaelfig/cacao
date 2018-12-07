// Copyright 2018 Google Inc. Use of this source code is governed by an
// MIT-style license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:grinder/grinder.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

import 'utils.dart';

/// Whether we're using a 64-bit Dart SDK.
bool get _is64Bit => Platform.version.contains("x64");

@Task('Build Dart script snapshot.')
snapshot() {
  ensureBuild();
  Dart.run('bin/$project.dart', vmArgs: ['--snapshot=build/$project.dart.snapshot']);
}

@Task('Build a dev-mode Dart application snapshot.')
appSnapshot() => _appSnapshot(release: false);

// Don't build in Dart 2 runtime mode for now because it's substantially slower
// than Dart 1 mode. See dart-lang/sdk#33257.
@Task('Build a release-mode Dart application snapshot.')
releaseAppSnapshot() => _appSnapshot(release: true);

/// Compiles project to an application snapshot.
///
/// If [release] is `true`, this compiles in checked mode. Otherwise, it
/// compiles in unchecked mode.
void _appSnapshot({@required bool release}) {
  var args = [
    '--snapshot=build/$project.dart.app.snapshot',
    '--snapshot-kind=app-jit'
  ];

  if (!release) args.add('--enable-asserts');

  ensureBuild();
  Dart.run('bin/$project.dart',
      arguments: snapshotArgs, vmArgs: args, quiet: true);
}

@Task('Build standalone packages for all OSes.')
@Depends(snapshot, releaseAppSnapshot)
package() async {
  var client = http.Client();
  await Future.wait(["linux", "macos", "windows"].expand((os) => [
        _buildPackage(client, os, x64: true),
        _buildPackage(client, os, x64: false)
      ]));
  client.close();
}

/// Builds a standalone project package for the given [os] and architecture.
///
/// The [client] is used to download the corresponding Dart SDK.
Future _buildPackage(http.Client client, String os, {bool x64 = true}) async {
  var architecture = x64 ? "x64" : "ia32";

  // TODO: Compile a single executable that embeds the Dart VM and the snapshot
  // when dart-lang/sdk#27596 is fixed.
  var channel = isDevSdk ? "dev" : "stable";
  var url = "https://storage.googleapis.com/dart-archive/channels/$channel/"
      "release/$dartVersion/sdk/dartsdk-$os-$architecture-release.zip";
  log("Downloading $url...");
  var response = await client.get(Uri.parse(url));
  if (response.statusCode ~/ 100 != 2) {
    throw "Failed to download package: ${response.statusCode} "
        "${response.reasonPhrase}.";
  }

  var dartExecutable = ZipDecoder().decodeBytes(response.bodyBytes).firstWhere(
      (file) => os == 'windows'
          ? file.name.endsWith("/bin/dart.exe")
          : file.name.endsWith("/bin/dart"));
  var executable = dartExecutable.content as List<int>;

  // Use the app snapshot when packaging for the current operating system.
  //
  // TODO: Use an app snapshot everywhere when dart-lang/sdk#28617 is fixed.
  var snapshot = os == Platform.operatingSystem && x64 == _is64Bit
      ? "build/$project.dart.app.snapshot"
      : "build/$project.dart.snapshot";

  var archive = Archive()
    ..addFile(fileFromBytes(
        "$project/src/dart${os == 'windows' ? '.exe' : ''}", executable,
        executable: true))
    ..addFile(
        file("$project/src/DART_LICENSE", p.join(sdkDir.path, 'LICENSE')))
    ..addFile(file("$project/src/$program.dart.snapshot", snapshot))
    ..addFile(file("$project/src/${PROGRAM}_LICENSE", "LICENSE"))
    ..addFile(fileFromString("$project/$program${os == 'windows' ? '.bat' : ''}",
        readAndReplaceVersion("package/boot.${os == 'windows' ? 'bat' : 'sh'}"),
        executable: true));

  if (new File("package/$project.${os == 'windows' ? 'bat' : 'sh'}").existsSync()) {
    archive
      ..addFile(fileFromString(
        "$project/$project${os == 'windows' ? '.bat' : ''}",
        readAndReplaceVersion(
            "package/$project.${os == 'windows' ? 'bat' : 'sh'}"),
        executable: true));
  }

  var prefix = 'build/$project-$version-$os-$architecture';
  if (os == 'windows') {
    var output = "$prefix.zip";
    log("Creating $output...");
    File(output).writeAsBytesSync(ZipEncoder().encode(archive));
  } else {
    var output = "$prefix.tar.gz";
    log("Creating $output...");
    File(output)
        .writeAsBytesSync(GZipEncoder().encode(TarEncoder().encode(archive)));
  }
}
