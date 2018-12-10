import 'package:cacao/cacao_io.dart' as cacao_io;
import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
//import 'dart:convert';

const port = 'port';
const host = 'host';
const help = 'help';
const version = 'version';

final progname = Platform.script.pathSegments.last;
final VERSION = String.fromEnvironment('version', defaultValue: 'prerelease');

void usage() {
  stderr.write("Type `$progname --help' for more information\n");
}

Future<void> main(List<String> arguments) async {
  final parser = new ArgParser()
    ..addFlag(help, negatable: false,
      help: 'display this message and exit')
    ..addOption(host, abbr: 'h', defaultsTo: cacao_io.DEFAULT_HOST,
      help: 'local address to bind to', valueHelp: 'HOST')
    ..addOption(port, abbr: 'p', defaultsTo: cacao_io.DEFAULT_PORT.toString(),
      help: 'local port to bind to', valueHelp: 'PORT')
    ..addFlag(version, negatable: false,
      help: 'print version information');
  
  var argResults = parser.parse(arguments);
  if (argResults[help]) {
    print('''
Usage: $progname [OPTION...] [ROOT-URL] /PATH=URL...

Cacao proxies requests via "http://<HOST>:<PORT>" to <ROOT-URL>
and "http://<HOST>:<PORT>/<PATH>/..." to "<URL>/...", adding an
"Access-Control-Allow-Origin: *" header to the result.

${parser.usage}''');
    return;
  }

  if (argResults[version]) {
    print('Cacao Proxy $VERSION');
    return;
  }

  final pathMap = new Map<String, String>();
  final re = new RegExp(r'^((/[^:=]*)=)?(.*)$');
  argResults.rest.forEach((pathUrl) {
    final match = re.firstMatch(pathUrl);
    final path = match.group(2);
    final url = match.group(3);
    final furl = p.split(url).first;
    if (furl == '.' || furl == '..') {
      // Get the path relative to the executing script.
      final thisdir = p.canonicalize(p.join(p.dirname(Platform.script.path), url));
      pathMap[path] = Uri.file(thisdir).toString();
    }
    else {
      pathMap[path] = url;
    }
  });

  if (pathMap.isEmpty) {
    stderr.writeln('$progname: You must specify at least one PATH=URL');
    usage();
    return;
  }

  final hst = argResults[host];
  final prt = int.parse(argResults[port]);
  print('Listening on http://$hst:$prt/');
  final server = await HttpServer.bind(hst, prt);

  await cacao_io.serve(server, pathMap, cacao_io.DEFAULT_SCHEME_MAP);
}
