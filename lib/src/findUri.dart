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