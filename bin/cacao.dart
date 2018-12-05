import 'package:cacao/cacao.dart' as cacao;
import 'package:args/args.dart';
import 'dart:io';

const port = 'port';
const host = 'host';
const help = 'help';

final progname = Platform.script.pathSegments.last;

void usage() {
  stderr.write("Type `$progname --help' for more information\n");
}

Future<void> main(List<String> arguments) async {
  final parser = new ArgParser()
    ..addFlag(help, negatable: false,
      help: 'display this message and exit')
    ..addOption(host, abbr: 'h', defaultsTo: cacao.DEFAULT_HOST,
      help: 'local address to bind to', valueHelp: 'HOST')
    ..addOption(port, abbr: 'p', defaultsTo: cacao.DEFAULT_PORT.toString(),
      help: 'local port to bind to', valueHelp: 'PORT');
  
  var argResults = parser.parse(arguments);
  if (argResults[help]) {
    print('Usage: $progname [OPTION...] BASE-URL\n\n'
      'Cacao proxies requests via "http://<HOST>:<PORT>/..." to "BASE-URL/..."\n'
      'adding an "Access-Control-Allow-Origin: *" header to the result.\n\n'
      '${parser.usage}');
    return;
  }

  if (argResults.rest.length != 1) {
    stderr.writeln('$progname: You must specify exactly one BASE-URL');
    usage();
    return;
  }

  final baseUrl = argResults.rest[0];
  await cacao.serve(baseUrl, host: argResults[host], port: int.parse(argResults[port]));
}