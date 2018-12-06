import 'findUri.dart';
import 'defaults.dart';
import 'serveFile.dart';
import 'dart:io';
void doProxy(HttpRequest request, Uri uri) {
  // Proxy the request.
  new HttpClient()
    ..openUrl(request.method, uri)
      .then((HttpClientRequest targetRequest) async {
        // Add the required headers to the request.
        request.headers.forEach((hdr, val) =>
          targetRequest.headers.set(hdr, val));

        // Make sure we request the right host.
        targetRequest.headers.set('Host', uri.host);
        await targetRequest.flush();
        
        // Stream the request.
        targetRequest
          ..bufferOutput = false
          ..addStream(request)
          .then((_) => targetRequest.close());
        return targetRequest.done;
      })
      .then((HttpClientResponse targetResponse) {
        // Add the content-type header to the response.
        request.response.headers.contentType =        targetResponse.headers.contentType;
        request.response.statusCode = targetResponse.statusCode;

        // Do the magic: add the allow origin.
        request.response.headers.set('Access-Control-Allow-Origin', '*');
        
        // Send the proxy response stream.
        final subscription = targetResponse.listen(
          (event) => request.response.add(event),
          onDone: () => request.response.close()
        );
        
        request.response.done.then((_) {
          // print('Client closed');
          subscription.cancel();
        });
      });
}

Future<void> serve(Map<String, String> pathMap, {host: DEFAULT_HOST, port: DEFAULT_PORT}) async {
  print('Listening on http://$host:$port/');
  final server = await HttpServer.bind(host, port);
  await for (HttpRequest request in server) {
    try {
      final uri = findUri(request.requestedUri, pathMap);
      print('${request.requestedUri} -> $uri');
      final schemeMap = {
        null : doProxy,
        "file": serveFile,
      };
      var scheme = schemeMap[uri.scheme];
      if (scheme == null) {
        scheme = schemeMap[null];
      }
      scheme(request, uri);
    }
    catch (e) {
      print('Got an error $e');
      request.response.statusCode = 500;
      request.response.writeln('Cacao server error');
      request.response.close();
    }
  }
}