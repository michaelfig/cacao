import "dart:io";
import "package:mime/mime.dart";

Future<void> serveFile(HttpRequest request, Uri uri) async {

  var path = uri.path;
  if (path.substring(path.length-1) == '/'){
    path += "index.html";
  }
  var file = new File(path).openRead();

  bool sentHeaders = false;
  final subscription = file.listen(
          //Check MIME type and make sure we only send the HTTP headers once
          (event) {
              if (!sentHeaders){
                sentHeaders = true;
                final contentTypeList = lookupMimeType(path,headerBytes:event).split('/');
                //final contentType = new ContentType(contentTypeList.split('/')[1],);
                request.response.headers.contentType = new ContentType(contentTypeList[0],contentTypeList[1]);
                request.response.headers.set('Access-Control-Allow-Origin', '*');
              }
              request.response.add(event);
          },
          //We have all the data we need for the response
          onDone: () => request.response.close(),
          //Bubble up to serve.dart error handler
          onError: (e) => request.response.addError(e)
        );
        //Cancel the subscription after we are done
        await request.response.done.then((_) {
          subscription.cancel();
        });
}