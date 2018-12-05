import 'package:cacao/cacao.dart';
import 'package:test/test.dart';

void main() {
  test('constants', () {
    expect(DEFAULT_HOST, '127.0.0.1');
    expect(DEFAULT_PORT, 8997);
  });

  test('findUri', () {
    String baseUrl = 'http://www.example.org/hello';

    Uri req = Uri.parse('http://localhost:8393/');
    expect(findUri(req, baseUrl).toString(), baseUrl + '/');

    Uri req2 = Uri.parse('http://localhost:8329');
    expect(findUri(req2, baseUrl).toString(), baseUrl);

    Uri req3 = Uri.parse('http://127.0.9.3/some/path');
    expect(findUri(req3, baseUrl).toString(), baseUrl + '/some/path');

    Uri req4 = Uri.parse('http://172.8.9.0/some?query=foo&blaz=bar');
    expect(findUri(req4, baseUrl).toString(),
      baseUrl + '/some?query=foo&blaz=bar');
  });
}
