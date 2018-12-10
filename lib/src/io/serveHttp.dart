import 'dart:io';

Future<void> serveHttp(HttpRequest request, Uri uri) async {
  // Proxy the request.
  final client = new HttpClient();
  final targetRequest = await client.openUrl(request.method, uri);
  bool clientClosed = false;
  request.response.done
    .then((_) => clientClosed = true)
    .catchError((_) => clientClosed = true);

  // Add the required headers to the request.
  request.headers.forEach((hdr, val) {
    // print('$hdr: $val');
    if (hdr.toLowerCase() == 'connection') {
      val = val.first.toLowerCase() == 'upgrade' ? val : ['close'];
    }
    targetRequest.headers.set(hdr, val);
  });

  // Make sure we request the right host.
  targetRequest.headers.set('Host', uri.host);
  await targetRequest.flush();
      
  if (true) {
    // Stream the request.
    targetRequest
      ..bufferOutput = false
      ..addStream(request)
      .then((_) => targetRequest.close());
  }
  else {
    targetRequest.close();
  }

  final targetResponse = await targetRequest.done;

  bool sentHeaders = false;
  await for (final event in targetResponse) {
    if (clientClosed) {
      final sock = await targetResponse.detachSocket();
      await sock.close();
      break;
    }
    if (!sentHeaders){
      sentHeaders = true;
      request.response.statusCode = targetResponse.statusCode;

      // Add the content-type header to the response.
      request.response.headers.contentType = targetResponse.headers.contentType;

      // Do the magic: add the allow origin.
      request.response.headers.set('Access-Control-Allow-Origin', '*');
      request.response.headers.set('Cache-Control', 'no-cache');
      await request.response.flush();
    }
    request.response.add(event);
  }

  await request.response.close();
}
