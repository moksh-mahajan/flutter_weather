import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_meteo_api/open_meteo_api.dart' as open_meteo_api;
import 'package:weather_repository/weather_repository.dart';

class MockOpenMeteoApiClient extends Mock
    implements open_meteo_api.OpenMeteoApiClient {}

class MockLocation extends Mock implements open_meteo_api.Location {}

class MockWeather extends Mock implements open_meteo_api.Weather {}

void main() {
  late open_meteo_api.OpenMeteoApiClient weatherApiClient;
  late WeatherRepository weatherRepository;

  setUp(() {
    weatherApiClient = MockOpenMeteoApiClient();
    weatherRepository = WeatherRepository(
      weatherApiClient: weatherApiClient,
    );
  });

  group('constructor', () {
    test('initializes correctly if the weatherApiClient is not injected', () {
      expect(WeatherRepository(), isNotNull);
    });
  });

  group('getWeather', () {
    const city = 'chicago';
    const latitude = 41.85003;
    const longitude = -87.6500;

    test('calls location search with correct city', () async {
      try {
        await weatherRepository.getWeather(city);
      } catch (_) {}

      verify(() => weatherApiClient.locationSearch(city)).called(1);
    });

    test('throws when location search fails', () async {
      final exception = Exception('OOPS!');
      when(() => weatherApiClient.locationSearch(city)).thenThrow(exception);
      expect(
        () => weatherRepository.getWeather(city),
        throwsA(exception),
      );
    });

    test('calls getWeather with correct latitude and longitude', () async {
      final location = MockLocation();
      when(() => location.latitude).thenReturn(latitude);
      when(() => location.longitude).thenReturn(longitude);
      when(() => weatherApiClient.locationSearch(any()))
          .thenAnswer((_) async => location);

      try {
        await weatherRepository.getWeather(city);
      } catch (_) {}

      verify(() => weatherApiClient.getWeather(
          latitude: latitude, longitude: longitude)).called(1);
    });

    test('throws when getWeather fails', () async {
      final location = MockLocation();
      when(() => location.latitude).thenReturn(latitude);
      when(() => location.longitude).thenReturn(longitude);
      when(() => weatherApiClient.locationSearch(any()))
          .thenAnswer((_) async => location);
      final exception = Exception('OOPS!');
      when(() => weatherApiClient.getWeather(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          )).thenThrow(exception);
      expect(() => weatherRepository.getWeather(city), throwsA(exception));
    });

    test('returns correct weather on success (clear)', () async {
      final location = MockLocation();
      final weather = MockWeather();
      when(() => location.name).thenReturn(city);
      when(() => location.latitude).thenReturn(latitude);
      when(() => location.longitude).thenReturn(longitude);
      when(() => weather.temperature).thenReturn(42.42);
      when(() => weather.weathercode).thenReturn(0);
      when(() => weatherApiClient.locationSearch(any())).thenAnswer(
        (_) async => location,
      );
      when(
        () => weatherApiClient.getWeather(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenAnswer((_) async => weather);
      final actual = await weatherRepository.getWeather(city);
      expect(
        actual,
        const Weather(
          temperature: 42.42,
          location: city,
          condition: WeatherCondition.clear,
        ),
      );
    });

    test('returns correct weather on success (cloudy)', () async {
      final location = MockLocation();
      final weather = MockWeather();
      when(() => location.name).thenReturn(city);
      when(() => location.latitude).thenReturn(latitude);
      when(() => location.longitude).thenReturn(longitude);
      when(() => weather.temperature).thenReturn(42.42);
      when(() => weather.weathercode).thenReturn(1);
      when(() => weatherApiClient.locationSearch(any())).thenAnswer(
        (_) async => location,
      );
      when(
        () => weatherApiClient.getWeather(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenAnswer((_) async => weather);
      final actual = await weatherRepository.getWeather(city);
      expect(
        actual,
       const Weather(
          temperature: 42.42,
          location: city,
          condition: WeatherCondition.cloudy,
        ),
      );
    });

    test('returns correct weather on success (rainy)', () async {
      final location = MockLocation();
      final weather = MockWeather();
      when(() => location.name).thenReturn(city);
      when(() => location.latitude).thenReturn(latitude);
      when(() => location.longitude).thenReturn(longitude);
      when(() => weather.temperature).thenReturn(42.42);
      when(() => weather.weathercode).thenReturn(51);
      when(() => weatherApiClient.locationSearch(any())).thenAnswer(
        (_) async => location,
      );
      when(
        () => weatherApiClient.getWeather(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenAnswer((_) async => weather);
      final actual = await weatherRepository.getWeather(city);
      expect(
        actual,
        const Weather(
          temperature: 42.42,
          location: city,
          condition: WeatherCondition.rainy,
        ),
      );
    });

    test('returns correct weather on success (snowy)', () async {
      final location = MockLocation();
      final weather = MockWeather();
      when(() => location.name).thenReturn(city);
      when(() => location.latitude).thenReturn(latitude);
      when(() => location.longitude).thenReturn(longitude);
      when(() => weather.temperature).thenReturn(42.42);
      when(() => weather.weathercode).thenReturn(71);
      when(() => weatherApiClient.locationSearch(any())).thenAnswer(
        (_) async => location,
      );
      when(
        () => weatherApiClient.getWeather(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenAnswer((_) async => weather);
      final actual = await weatherRepository.getWeather(city);
      expect(
        actual,
        const Weather(
          temperature: 42.42,
          location: city,
          condition: WeatherCondition.snowy,
        ),
      );
    });

    test('returns correct weather on success (unknown)', () async {
      final location = MockLocation();
      final weather = MockWeather();
      when(() => location.name).thenReturn(city);
      when(() => location.latitude).thenReturn(latitude);
      when(() => location.longitude).thenReturn(longitude);
      when(() => weather.temperature).thenReturn(42.42);
      when(() => weather.weathercode).thenReturn(-1);
      when(() => weatherApiClient.locationSearch(any())).thenAnswer(
        (_) async => location,
      );
      when(
        () => weatherApiClient.getWeather(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenAnswer((_) async => weather);
      final actual = await weatherRepository.getWeather(city);
      expect(
        actual,
        const Weather(
          temperature: 42.42,
          location: city,
          condition: WeatherCondition.unknown,
        ),
      );
    });
  });
}
