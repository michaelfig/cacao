import 'resolve.dart';

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