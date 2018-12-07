import '../findUri.dart';
import 'types.dart';
import 'dart:io';

Future<void> serve(HttpServer server, Map<String, String> pathMap, Map<String, CacaoServer> schemeMap) async {
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