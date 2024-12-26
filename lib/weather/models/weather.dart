import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_repository/weather_repository.dart'
    as weather_repository;
import 'package:weather_repository/weather_repository.dart' hide Weather;

part 'weather.g.dart';

enum TemperatureUnits { fahrenheit, celsius }

extension TemperatureUnitsX on TemperatureUnits {
  bool get isFahrenheit => this == TemperatureUnits.fahrenheit;
  bool get isCelsius => this == TemperatureUnits.celsius;
}

@JsonSerializable()
class Temperature extends Equatable {
  const Temperature({required this.value});

  factory Temperature.fromJson(Map<String, dynamic> json) =>
      _$TemperatureFromJson(json);

  Map<String, dynamic> toJson() => _$TemperatureToJson(this);

  final double value;

  @override
  List<Object?> get props => [value];
}

@JsonSerializable()
class Weather extends Equatable {
  const Weather({
    required this.temperature,
    required this.lastUpdated,
    required this.location,
    required this.condition,
  });

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherToJson(this);

  factory Weather.fromRepository(weather_repository.Weather weather) {
    return Weather(
      temperature: Temperature(value: weather.temperature),
      lastUpdated: DateTime.now(),
      location: weather.location,
      condition: weather.condition,
    );
  }

  static final empty = Weather(
    temperature: const Temperature(value: 0.0),
    lastUpdated: DateTime(0),
    location: '--',
    condition: WeatherCondition.unknown,
  );

  final Temperature temperature;
  final DateTime lastUpdated;
  final String location;
  final WeatherCondition condition;

  @override
  List<Object?> get props => [
        temperature,
        lastUpdated,
        location,
        condition,
      ];

  Weather copyWith(
      {Temperature? temperature,
      DateTime? lastUpdated,
      String? location,
      WeatherCondition? condition}) {
    return Weather(
      temperature: temperature ?? this.temperature,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      location: location ?? this.location,
      condition: condition ?? this.condition,
    );
  }
}
