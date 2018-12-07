import 'dart:io';

Future<void> serveHttp(HttpRequest request, Uri uri) async {
  // Proxy the request.
  final client = new HttpClient();
  final targetRequest = await client.openUrl(request.method, uri);

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

  final targetResponse = await targetRequest.done;

  // Add the content-type header to the response.
  request.response.headers.contentType = targetResponse.headers.contentType;
  request.response.statusCode = targetResponse.statusCode;

  // Do the magic: add the allow origin.
  request.response.headers.set('Access-Control-Allow-Origin', '*');
  
  // Send the proxy response stream.
  final subscription = targetResponse.listen(
    (event) => request.response.add(event),
    onDone: () => request.response.close()
  );
      
  // Cancel the request if we crash.
  request.response.done.then((_) {
    // print('Client closed');
    subscription.cancel();
  });
}
