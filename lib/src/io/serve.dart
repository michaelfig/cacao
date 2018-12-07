import '../findUri.dart';
import '../defaults.dart';
import 'types.dart';
import 'dart:io';

Future<void> serve(Map<String, String> pathMap, Map<String, CacaoServer> schemeMap, {
  host: DEFAULT_HOST,
  port: DEFAULT_PORT,
}) async {
  print('Listening on http://$host:$port/');
  final server = await HttpServer.bind(host, port);
  await for (HttpRequest request in server) {
    final onError = (e) {
      print('Got an error $e');
      request.response.statusCode = 500;
      request.response.writeln('Cacao server error');
      request.response.close();
    };
    try {
      final uri = findUri(request.requestedUri, pathMap);
      print('${request.requestedUri} -> $uri');
      var scheme = schemeMap[uri.scheme];
      if (scheme == null) {
        scheme = schemeMap[null];
      }
      if (scheme == null) {
        throw 'No default scheme to serve ${uri.scheme}';
      }
      scheme(request, uri).catchError(onError);
    }
    catch (e) {
      onError(e);
    }
  }
}