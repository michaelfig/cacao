import 'src/serveHttp.dart';
import 'src/serveFile.dart';

export 'cacao.dart';
export 'src/serve.dart';

const DEFAULT_SCHEME_MAP = {
  'file': serveFile,
  null: serveHttp,
};
