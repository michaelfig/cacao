import "dart:io";

Future<void> serveFile(HttpRequest request, Uri uri) async {
  request.response.headers.contentType = new ContentType("text", "html");
  request.response.headers.set('Access-Control-Allow-Origin', '*');
  new File(uri.path).openRead().pipe(request.response);
}