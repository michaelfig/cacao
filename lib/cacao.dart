import 'dart:io';

const DEFAULT_HOST = '127.0.0.1';
const DEFAULT_PORT = 8997;

Uri findUri(Uri requested, String baseUrl) {
  return Uri.parse(baseUrl + requested.path +
    (requested.hasQuery ? '?${requested.query}' : ''));
}

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
        
        request.response
          // Send the proxy response stream.
          ..bufferOutput = false
          ..addStream(targetResponse)
          // Close the response after it is complete.
          .then((dynamic) => request.response.close());
      });
}

Future<void> serve(String baseUrl, {host: DEFAULT_HOST, port: DEFAULT_PORT}) async {
  print('Listening for $baseUrl on http://$host:$port/');
  final server = await HttpServer.bind(host, port);
  await for (HttpRequest request in server) {
    try {
      final uri = findUri(request.requestedUri, baseUrl);
      print('Request for $uri');
      doProxy(request, uri);
    }
    catch (e) {
      print('Got an error $e');
      request.response.statusCode = 500;
      request.response.writeln('Cacao server error');
    }
  }
}