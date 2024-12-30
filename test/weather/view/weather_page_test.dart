import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather/weather/weather.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_repository/weather_repository.dart'
    show WeatherRepository;

import '../../helpers/hydrated_bloc.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

class MockWeatherCubit extends MockCubit<WeatherState>
    implements WeatherCubit {}

void main() {
  initHydratedStorage();

  group('WeatherPage', () {
    final weather = Weather(
      temperature: const Temperature(value: 4.2),
      condition: WeatherCondition.cloudy,
      lastUpdated: DateTime(2024),
      location: 'London',
    );
    late WeatherCubit weatherCubit;

    setUp(() {
      weatherCubit = MockWeatherCubit();
    });

    testWidgets('renders WeatherEmpty for WeatherStatus.initial',
        (tester) async {
      when(() => weatherCubit.state).thenReturn(WeatherState());
      await tester.pumpWidget(BlocProvider.value(
        value: weatherCubit,
        child: const MaterialApp(
          home: WeatherPage(),
        ),
      ));
      expect(find.byType(WeatherEmpty), findsOneWidget);
    });

    testWidgets('renders WeatherLoading for WeatherStatus.loading',
        (tester) async {
      when(() => weatherCubit.state)
          .thenReturn(WeatherState(status: WeatherStatus.loading));
      await tester.pumpWidget(BlocProvider.value(
        value: weatherCubit,
        child: const MaterialApp(
          home: WeatherPage(),
        ),
      ));
      expect(find.byType(WeatherLoading), findsOneWidget);
    });

    testWidgets('renders WeatherError for WeatherStatus.failure',
        (tester) async {
      when(() => weatherCubit.state)
          .thenReturn(WeatherState(status: WeatherStatus.failure));
      await tester.pumpWidget(BlocProvider.value(
        value: weatherCubit,
        child: const MaterialApp(
          home: WeatherPage(),
        ),
      ));
      expect(find.byType(WeatherError), findsOneWidget);
    });

    testWidgets('renders WeatherPopulated for WeatherStatus.success',
        (tester) async {
      when(() => weatherCubit.state).thenReturn(WeatherState(
        status: WeatherStatus.success,
        weather: weather,
      ));
      await tester.pumpWidget(BlocProvider.value(
        value: weatherCubit,
        child: const MaterialApp(
          home: WeatherPage(),
        ),
      ));
      expect(find.byType(WeatherPopulated), findsOneWidget);
    });

    testWidgets('state is cached', (tester) async {
      when(() => hydratedStorage.read('$WeatherCubit')).thenReturn(
        WeatherState(
          status: WeatherStatus.success,
          weather: weather,
          temperatureUnits: TemperatureUnits.fahrenheit,
        ).toJson(),
      );
      await tester.pumpWidget(BlocProvider.value(
        value: WeatherCubit(MockWeatherRepository()),
        child: const MaterialApp(
          home: WeatherPage(),
        ),
      ));
      expect(find.byType(WeatherPopulated), findsOneWidget);
    });

    testWidgets('navigates to SettingsPage when settings icon is tapped',
        (tester) async {
      when(() => weatherCubit.state).thenReturn(WeatherState());
      await tester.pumpWidget(BlocProvider.value(
        value: weatherCubit,
        child: const MaterialApp(
          home: WeatherPage(),
        ),
      ));
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('navigates to SearchPage when search button is tapped',
        (tester) async {
      when(() => weatherCubit.state).thenReturn(WeatherState());
      await tester.pumpWidget(BlocProvider.value(
        value: weatherCubit,
        child: const MaterialApp(
          home: WeatherPage(),
        ),
      ));
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      expect(find.byType(SearchPage), findsOneWidget);
    });

    testWidgets('triggers refreshWeather on pull to refresh', (tester) async {
      when(() => weatherCubit.state).thenReturn(WeatherState(
        status: WeatherStatus.success,
        weather: weather,
      ));
      when(() => weatherCubit.refreshWeather()).thenAnswer((_) async {});
      await tester.pumpWidget(BlocProvider.value(
        value: weatherCubit,
        child: const MaterialApp(
          home: WeatherPage(),
        ),
      ));
      await tester.fling(
        find.text('London'),
        const Offset(0, 500),
        1000,
      );
      await tester.pumpAndSettle();
      verify(() => weatherCubit.refreshWeather()).called(1);
    });

    testWidgets('triggers fetch on search pop', (tester) async {
      when(() => weatherCubit.state).thenReturn(WeatherState());
      when(() => weatherCubit.fetchWeather(any())).thenAnswer((_) async {});
      await tester.pumpWidget(
        BlocProvider.value(
          value: weatherCubit,
          child: const MaterialApp(
            home: WeatherPage(),
          ),
        ),
      );
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Chicago');
      await tester.tap(find.byKey(const Key('searchPage_search_iconButton')));
      await tester.pumpAndSettle();
      verify(() => weatherCubit.fetchWeather('Chicago')).called(1);
    });
  });
}
