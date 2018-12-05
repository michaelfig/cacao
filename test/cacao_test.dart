import 'package:cacao/cacao.dart';
import 'package:test/test.dart';

void main() {
  test('constants', () {
    expect(DEFAULT_HOST, '127.0.0.1');
    expect(DEFAULT_PORT, 8997);
  });

  test('findUri', () {
    final baseUrl = 'http://www.example.org/hello';
    final pathMap = {'': baseUrl};

    Uri req = Uri.parse('http://localhost:8393/');
    expect(findUri(req, pathMap).toString(), baseUrl + '/');

    Uri req2 = Uri.parse('http://localhost:8329');
    expect(findUri(req2, pathMap).toString(), baseUrl);

    Uri req3 = Uri.parse('http://127.0.9.3/some/path');
    expect(findUri(req3, pathMap).toString(), baseUrl + '/some/path');

    Uri req4 = Uri.parse('http://172.8.9.0/some?query=foo&blaz=bar');
    expect(findUri(req4, pathMap).toString(),
      baseUrl + '/some?query=foo&blaz=bar');
  });

  test('findUri multipath', () {
    final pathMap = {
      '/path/sub': 'http://a.example.com/foo',
      '/path': 'http://a.example.com/default',
      '/path2': 'http://b.example.com',
      '': 'http://example.com',
    };

    Uri req = Uri.parse('http://localhost:3939');
    expect(findUri(req, pathMap).toString(), 'http://example.com');

    Uri req2 = Uri.parse('http://localhost:3939/else');
    expect(findUri(req2, pathMap).toString(), 'http://example.com/else');

    Uri req3 = Uri.parse('http://localhost:3939/path/sub/');
    expect(findUri(req3, pathMap).toString(), 'http://a.example.com/foo/');

    Uri req3a = Uri.parse('http://localhost:3939/path/sub');
    expect(findUri(req3a, pathMap).toString(), 'http://a.example.com/foo');

    Uri req4 = Uri.parse('http://localhost:4499/path/sub2');
    expect(findUri(req4, pathMap).toString(), 'http://a.example.com/default/sub2');

    Uri req5 = Uri.parse('http://localhost:4499/path2/sub2');
    expect(findUri(req5, pathMap).toString(), 'http://b.example.com/sub2');

  });

  test('findUri query string', () {
    final pathMap = {
      '': 'http://example.com/?foo=bar&baz',
    };

    Uri req = Uri.parse('http://localhost:8929');
    expect(findUri(req, pathMap).toString(), 'http://example.com/?foo=bar&baz');

    Uri req2 = Uri.parse('http://localhost:2989/path2/sub2');
    expect(findUri(req2, pathMap).toString(), 'http://example.com/path2/sub2?foo=bar&baz');
  });
}
