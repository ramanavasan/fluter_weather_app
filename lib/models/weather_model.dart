// lib/models/weather_model.dart

class CurrentWeather {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final int windDegree;
  final int visibility;
  final int pressure;
  final String description;
  final String iconCode;
  final int cloudiness;
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime lastUpdated;
  final double lat;
  final double lon;

  CurrentWeather({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.windDegree,
    required this.visibility,
    required this.pressure,
    required this.description,
    required this.iconCode,
    required this.cloudiness,
    required this.sunrise,
    required this.sunset,
    required this.lastUpdated,
    required this.lat,
    required this.lon,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      cityName: json['name'] ?? 'Unknown',
      country: json['sys']?['country'] ?? '',
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      windDegree: (json['wind']['deg'] ?? 0) as int,
      visibility: (json['visibility'] ?? 10000) as int,
      pressure: json['main']['pressure'] as int,
      description: json['weather'][0]['description'] ?? '',
      iconCode: json['weather'][0]['icon'] ?? '01d',
      cloudiness: json['clouds']?['all'] ?? 0,
      sunrise: DateTime.fromMillisecondsSinceEpoch(
          (json['sys']['sunrise'] as int) * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(
          (json['sys']['sunset'] as int) * 1000),
      lastUpdated: DateTime.now(),
      lat: (json['coord']?['lat'] ?? 0.0 as num).toDouble(),
      lon: (json['coord']?['lon'] ?? 0.0 as num).toDouble(),
    );
  }
}

class ForecastDay {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final double tempMorn;
  final double tempDay;
  final double tempEve;
  final double tempNight;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final int pop; // Probability of precipitation (0-100)
  final double? rain;
  final int pressure;

  ForecastDay({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.tempMorn,
    required this.tempDay,
    required this.tempEve,
    required this.tempNight,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.pop,
    this.rain,
    required this.pressure,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      date: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      tempMin: (json['temp']['min'] as num).toDouble(),
      tempMax: (json['temp']['max'] as num).toDouble(),
      tempMorn: (json['temp']['morn'] as num).toDouble(),
      tempDay: (json['temp']['day'] as num).toDouble(),
      tempEve: (json['temp']['eve'] as num).toDouble(),
      tempNight: (json['temp']['night'] as num).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      iconCode: json['weather'][0]['icon'] ?? '01d',
      humidity: json['humidity'] as int,
      windSpeed: (json['speed'] as num).toDouble(),
      pop: ((json['pop'] ?? 0.0) * 100).round(),
      rain: json['rain'] != null ? (json['rain'] as num).toDouble() : null,
      pressure: json['pressure'] as int,
    );
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final String iconCode;
  final String description;
  final int humidity;
  final double windSpeed;
  final int pop;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.iconCode,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.pop,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      temperature: (json['main']['temp'] as num).toDouble(),
      iconCode: json['weather'][0]['icon'] ?? '01d',
      description: json['weather'][0]['description'] ?? '',
      humidity: json['main']['humidity'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      pop: (((json['pop'] ?? 0.0) as num) * 100).round(),
    );
  }
}
