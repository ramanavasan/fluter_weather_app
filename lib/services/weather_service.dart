// lib/services/weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  // Exactly reads compile-time environment variable OPENWEATHER_API_KEY
  static final String _apiKey =
      const String.fromEnvironment('OPENWEATHER_API_KEY')
          .trim()
          .replaceAll("'", '')
          .replaceAll('"', '');

  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _units = 'metric';

  Future<CurrentWeather> getCurrentWeather({
    double? lat,
    double? lon,
    String? cityName,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception(
          'OpenWeatherMap API key is missing. Please provide it via --dart-define=OPENWEATHER_API_KEY=your_key.');
    }

    String url;
    if (lat != null && lon != null) {
      url =
          '$_baseUrl/weather?lat=$lat&lon=$lon&units=$_units&appid=$_apiKey';
    } else if (cityName != null) {
      url =
          '$_baseUrl/weather?q=${Uri.encodeComponent(cityName)}&units=$_units&appid=$_apiKey';
    } else {
      throw Exception('Either lat/lon or cityName must be provided');
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return CurrentWeather.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      String detail = '';
      try {
        final decoded = json.decode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          detail = ' (${decoded['message']})';
        }
      } catch (_) {}
      throw Exception(
          'Invalid API key. Please configure your OpenWeatherMap API key$detail.');
    } else if (response.statusCode == 404) {
      throw Exception('City not found. Please check the city name.');
    } else {
      throw Exception('Failed to load weather: ${response.statusCode}');
    }
  }

  Future<List<HourlyForecast>> getHourlyForecast({
    required double lat,
    required double lon,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception(
          'OpenWeatherMap API key is missing. Please provide it via --dart-define=OPENWEATHER_API_KEY=your_key.');
    }
    final url =
        '$_baseUrl/forecast?lat=$lat&lon=$lon&units=$_units&cnt=24&appid=$_apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List list = data['list'];
      return list.map((item) => HourlyForecast.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load hourly forecast: ${response.statusCode}');
    }
  }

  Future<List<ForecastDay>> getDailyForecast({
    required double lat,
    required double lon,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception(
          'OpenWeatherMap API key is missing. Please provide it via --dart-define=OPENWEATHER_API_KEY=your_key.');
    }
    // Note: daily forecast requires 'forecast/daily' endpoint which needs
    // paid subscription. We simulate it from 5-day/3-hour forecast data.
    final url =
        '$_baseUrl/forecast?lat=$lat&lon=$lon&units=$_units&cnt=40&appid=$_apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List list = data['list'];
      return _groupByDay(list);
    } else {
      throw Exception('Failed to load forecast: ${response.statusCode}');
    }
  }

  List<ForecastDay> _groupByDay(List items) {
    final Map<String, List<dynamic>> grouped = {};
    for (var item in items) {
      final dt = DateTime.fromMillisecondsSinceEpoch((item['dt'] as int) * 1000);
      final key = '${dt.year}-${dt.month}-${dt.day}';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(item);
    }

    final days = grouped.entries.skip(1).take(7).map((entry) {
      final dayItems = entry.value;
      final temps =
          dayItems.map((i) => (i['main']['temp'] as num).toDouble()).toList();
      final midItem = dayItems[dayItems.length ~/ 2];
      return ForecastDay(
        date: DateTime.fromMillisecondsSinceEpoch(
            (dayItems[0]['dt'] as int) * 1000),
        tempMin: temps.reduce((a, b) => a < b ? a : b),
        tempMax: temps.reduce((a, b) => a > b ? a : b),
        tempMorn: temps.first,
        tempDay: temps[temps.length ~/ 2],
        tempEve: temps[temps.length * 2 ~/ 3],
        tempNight: temps.last,
        description: midItem['weather'][0]['description'] ?? '',
        iconCode: midItem['weather'][0]['icon'] ?? '01d',
        humidity: midItem['main']['humidity'] as int,
        windSpeed: (midItem['wind']['speed'] as num).toDouble(),
        pop: (((dayItems
                    .map((i) => (i['pop'] ?? 0.0) as num)
                    .reduce((a, b) => a > b ? a : b)) *
                100))
            .round(),
        pressure: midItem['main']['pressure'] as int,
      );
    }).toList();
    return days;
  }

  Future<List<String>> searchCities(String query) async {
    if (query.length < 2 || _apiKey.isEmpty) return [];
    final url =
        'https://api.openweathermap.org/geo/1.0/direct?q=${Uri.encodeComponent(query)}&limit=5&appid=$_apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((item) {
        final state = item['state'] != null ? ', ${item['state']}' : '';
        return '${item['name']}$state, ${item['country']}';
      }).toList();
    }
    return [];
  }
}
