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
