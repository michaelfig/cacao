import 'package:cacao/cacao.dart' as cacao;
import 'package:args/args.dart';

const port = 'port';
const host = 'host';

Future<void> main(List<String> arguments) async {
  final parser = new ArgParser()
    ..addOption(port, abbr: 'p', defaultsTo: cacao.DEFAULT_PORT.toString())
    ..addOption(host, abbr: 'h', defaultsTo: cacao.DEFAULT_HOST);
  
  var argResults = parser.parse(arguments);
  if (argResults.rest.length != 1) {
    throw new ArgParserException('Need exactly one BASEURL');
  }
  final baseUrl = argResults.rest[0];
  await cacao.serve(baseUrl, host: argResults[host], port: int.parse(argResults[port]));
}
