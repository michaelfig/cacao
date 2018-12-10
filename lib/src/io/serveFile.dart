import "dart:io";
import "dart:async";
import "package:mime/mime.dart";
import "package:path/path.dart" as p;

Future<void> serveFile(HttpRequest request, Uri uri) async {

  var path = uri.path;
  if (await FileSystemEntity.isDirectory(path)) {
    path = p.join(path, 'index.html');
  }

  if (!await FileSystemEntity.isFile(path)) {
    request.response.statusCode = 404;
    request.response.writeln('Not Found');
    await request.response.close();
    return;
  }
  var file = new File(path).openRead();

  bool sentHeaders = false;
  await for (final event in file) {
    if (!sentHeaders){
      sentHeaders = true;
      final contentTypeList = lookupMimeType(path,headerBytes:event).split('/');
      //final contentType = new ContentType(contentTypeList.split('/')[1],);
      request.response.headers.contentType = new ContentType(contentTypeList[0],contentTypeList[1]);
      request.response.headers.set('Access-Control-Allow-Origin', '*');
    }
    request.response.add(event);
  }
  await request.response.close();
}