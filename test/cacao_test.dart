import 'package:cacao/cacao.dart';
import 'package:test/test.dart';

void main() {
  test('constants', () {
    expect(DEFAULT_HOST, 'localhost');
    expect(DEFAULT_PORT, 8997);
  });
}
