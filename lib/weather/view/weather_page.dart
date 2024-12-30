import 'package:flutter/material.dart';
import 'package:flutter_weather/weather/weather.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).push<void>(SettingsPage.route()),
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: Center(
        child: BlocBuilder<WeatherCubit, WeatherState>(
          builder: (context, state) {
            return switch (state.status) {
              WeatherStatus.initial => const WeatherEmpty(),
              WeatherStatus.loading => const WeatherLoading(),
              WeatherStatus.failure => const WeatherError(),
              WeatherStatus.success => WeatherPopulated(
                  weather: state.weather,
                  temperatureUnits: state.temperatureUnits,
                  onRefresh: context.read<WeatherCubit>().refreshWeather,
                ),
            };
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Search',
        child: const Icon(Icons.search, semanticLabel: 'Search'),
        onPressed: () async {
          final city =
              await Navigator.of(context).push<String?>(SearchPage.route());
          if (!context.mounted) return;
          await context.read<WeatherCubit>().fetchWeather(city);
        },
      ),
    );
  }
}
