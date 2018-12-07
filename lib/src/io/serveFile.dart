import "dart:io";
import "dart:async";
import "package:mime/mime.dart";

Future<void> serveFile(HttpRequest request, Uri uri) async {

  var path = uri.path;
  if (path.substring(path.length-1) == '/'){
    path += "index.html";
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