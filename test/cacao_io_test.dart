import 'package:cacao/cacao_io.dart';
import 'package:test/test.dart';

void main() {
  test('constants', () {
    expect(DEFAULT_HOST, '127.0.0.1');
    expect(DEFAULT_PORT, 8997);
    expect(DEFAULT_SCHEME_MAP[null], new TypeMatcher<CacaoServer>());
    expect(DEFAULT_SCHEME_MAP['file'], new TypeMatcher<CacaoServer>());
    expect(DEFAULT_SCHEME_MAP['unknown'], isNull);
  });
}
