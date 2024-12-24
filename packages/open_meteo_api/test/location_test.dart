import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:test/test.dart';

void main() {
  group('Location', () {
    group('fromJson', () {
      test('return correct Location object', () {
        expect(
            Location.fromJson(<String, dynamic>{
              'id': 1827409,
              'name': 'Udhampur',
              'latitude': 32.9160,
              'longitude': 75.1416,
            }),
            isA<Location>()
                .having((w) => w.id, 'id', 1827409)
                .having((w) => w.name, 'name', 'Udhampur')
                .having((w) => w.latitude, 'latitude', 32.9160)
                .having((w) => w.longitude, 'longitude', 75.1416));
      });
    });
  });
}
