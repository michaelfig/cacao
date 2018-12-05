import 'dart:io';

const DEFAULT_HOST = '127.0.0.1';
const DEFAULT_PORT = 8997;

String buildQuery(String a, String b) {
  final prefix = (a.isEmpty && b.isEmpty) ? '' : '?';
  final sep = (a.isNotEmpty && b.isNotEmpty) ? '&' : '';
  return prefix + a + sep + b;
}

Uri resolve(Uri requested, String prepend, String add) {
  final pre = Uri.parse(prepend);
  String path;
  if (pre.path.endsWith('/')) {
    if (add.startsWith('/')) {
      path = pre.path + add.substring(1);
    }
    else {
      path = pre.path + add;
    }
  }
  else if (add.isEmpty || add.startsWith('/'))  {
    path = pre.path + add;
  }
  else {
    path = pre.path + '/' + add;
  }
  final addQuery = buildQuery(pre.query, requested.query);
  return pre.resolve(path + addQuery);
}

Uri findUri(Uri requested, Map<String, String> pathMap) {
  // Use the longest matching pathMap.
  final segs = requested.pathSegments;
  final trailSlash = segs.length > 0 && segs.last == '';
  for (var i = segs.length - (trailSlash ? 1 : 0); i >= 0; --i) {
    final toMatch = '/' + segs.take(i).join('/');
    final toPrepend = pathMap[toMatch];
    if (toPrepend != null) {
      final toAdd = segs
        .skip(i)
        .map((s) => Uri.encodeComponent(s))
        .join('/');
      final suffix = trailSlash ? '/' : '';
      return resolve(requested, toPrepend, toAdd + suffix);
    }
  }
  // Do the default mapping, if there is one.
  final defaultUrl = pathMap[null];
  if (defaultUrl == null) {
    throw 'No default Url in pathMap';
  }
  final toAdd = requested.path == '/' ? '' : requested.path;
  return resolve(requested, defaultUrl, toAdd);
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

Future<void> serve(Map<String, String> pathMap, {host: DEFAULT_HOST, port: DEFAULT_PORT}) async {
  print('Listening on http://$host:$port/');
  final server = await HttpServer.bind(host, port);
  await for (HttpRequest request in server) {
    try {
      final uri = findUri(request.requestedUri, pathMap);
      print('${request.requestedUri} -> $uri');
      doProxy(request, uri);
    }
    catch (e) {
      print('Got an error $e');
      request.response.statusCode = 500;
      request.response.writeln('Cacao server error');
    }
  }
}
