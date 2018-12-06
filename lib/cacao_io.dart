import 'src/serveHttp.dart';
import 'src/serveFile.dart';

export 'src/serve.dart';
export 'src/defaults.dart';

const DEFAULT_SCHEME_MAP = {
  'file': serveFile,
  null: serveHttp,
};
