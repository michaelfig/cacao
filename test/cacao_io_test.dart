import 'package:cacao/cacao_io.dart';
import 'package:test/test.dart';

void main() {
  test('constants', () {
    expect(DEFAULT_HOST, '127.0.0.1');
    expect(DEFAULT_PORT, 8997);
    expect(DEFAULT_SCHEME_MAP[null], (srv) => srv != null);
    expect(DEFAULT_SCHEME_MAP['file'], (srv) => srv != null);
  });
}
