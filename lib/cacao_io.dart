import 'src/io/serveHttp.dart';
import 'src/io/serveFile.dart';
import 'dart:io';

export 'src/io/serve.dart';
export 'src/defaults.dart';

typedef void CacaoServer(HttpRequest request, Uri uri);

const Map<String, CacaoServer> DEFAULT_SCHEME_MAP = {
  'file': serveFile,
  null: serveHttp,
};
