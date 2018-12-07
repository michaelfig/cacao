import 'package:cacao/cacao_io.dart' as cacao_io;
import 'package:args/args.dart';
import 'dart:io';
//import 'dart:convert';

const VERSION = '0.2.0';

const port = 'port';
const host = 'host';
const help = 'help';
const version = 'version';

final progname = Platform.script.pathSegments.last;

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
    print('Cacao Proxy v' + VERSION);
    return;
  }

  final pathMap = new Map<String, String>();
  final re = new RegExp(r'^((/[^:=]*)=)?(.*)$');
  argResults.rest.forEach((pathUrl) {
    final match = re.firstMatch(pathUrl);
    final path = match.group(2);
    final url = match.group(3);
    pathMap[path] = url;
  });

  if (pathMap.isEmpty) {
    stderr.writeln('$progname: You must specify at least one PATH=URL');
    usage();
    return;
  }

  final h = argResults[host];
  final p = int.parse(argResults[port]);
  print('Listening on http://$h:$p/');
  final server = await HttpServer.bind(h, p);

  await cacao_io.serve(server, pathMap, cacao_io.DEFAULT_SCHEME_MAP);
}
