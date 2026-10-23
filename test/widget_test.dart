import 'package:flutter_test/flutter_test.dart';
import 'package:weather_forecast_app/models/weather_model.dart';

void main() {
  group('WeatherModel Tests', () {
    test('CurrentWeather parses valid JSON correctly', () {
      final json = {
        'name': 'London',
        'sys': {
          'country': 'GB',
          'sunrise': 1600000000,
          'sunset': 1600040000,
        },
        'main': {
          'temp': 15.5,
          'feels_like': 14.2,
          'temp_min': 12.0,
          'temp_max': 18.0,
          'humidity': 75,
          'pressure': 1012,
        },
        'wind': {
          'speed': 4.5,
          'deg': 180,
        },
        'visibility': 10000,
        'weather': [
          {
            'description': 'broken clouds',
            'icon': '04d',
          }
        ],
        'clouds': {
          'all': 75,
        },
        'dt': 1600010000,
        'coord': {
          'lat': 51.5074,
          'lon': -0.1278,
        },
      };

      final weather = CurrentWeather.fromJson(json);

      expect(weather.cityName, 'London');
      expect(weather.country, 'GB');
      expect(weather.temperature, 15.5);
      expect(weather.feelsLike, 14.2);
      expect(weather.humidity, 75);
      expect(weather.windSpeed, 4.5);
      expect(weather.description, 'broken clouds');
      expect(weather.iconCode, '04d');
    });
  });
}
