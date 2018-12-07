import 'src/io/serveHttp.dart';
import 'src/io/serveFile.dart';
import 'src/io/types.dart';

export 'src/io/types.dart';
export 'src/io/serve.dart';
export 'src/defaults.dart';

const Map<String, CacaoServer> DEFAULT_SCHEME_MAP = {
  'file': serveFile,
  null: serveHttp,
};
