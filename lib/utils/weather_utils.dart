// lib/utils/weather_utils.dart
import 'package:flutter/material.dart';

class WeatherUtils {
  static String getWeatherDescription(String iconCode) {
    final Map<String, String> descriptions = {
      '01d': 'Clear Sky',
      '01n': 'Clear Night',
      '02d': 'Few Clouds',
      '02n': 'Few Clouds Night',
      '03d': 'Scattered Clouds',
      '03n': 'Scattered Clouds',
      '04d': 'Broken Clouds',
      '04n': 'Broken Clouds',
      '09d': 'Shower Rain',
      '09n': 'Shower Rain',
      '10d': 'Rain',
      '10n': 'Rain Night',
      '11d': 'Thunderstorm',
      '11n': 'Thunderstorm',
      '13d': 'Snow',
      '13n': 'Snow',
      '50d': 'Mist',
      '50n': 'Mist',
    };
    return descriptions[iconCode] ?? 'Unknown';
  }

  static String getWeatherEmoji(String iconCode) {
    final Map<String, String> emojis = {
      '01d': '☀️',
      '01n': '🌙',
      '02d': '🌤️',
      '02n': '🌤️',
      '03d': '⛅',
      '03n': '⛅',
      '04d': '☁️',
      '04n': '☁️',
      '09d': '🌧️',
      '09n': '🌧️',
      '10d': '🌦️',
      '10n': '🌧️',
      '11d': '⛈️',
      '11n': '⛈️',
      '13d': '❄️',
      '13n': '❄️',
      '50d': '🌫️',
      '50n': '🌫️',
    };
    return emojis[iconCode] ?? '🌡️';
  }

  static List<Color> getGradientColors(String iconCode, bool isNight) {
    if (isNight || iconCode.endsWith('n')) {
      return [
        const Color(0xFF0D1B2A),
        const Color(0xFF1B2D4F),
        const Color(0xFF1E3A5F),
      ];
    }

    switch (iconCode.replaceAll('d', '').replaceAll('n', '')) {
      case '01':
        return [
          const Color(0xFF1565C0),
          const Color(0xFF1976D2),
          const Color(0xFF42A5F5),
        ];
      case '02':
      case '03':
        return [
          const Color(0xFF1565C0),
          const Color(0xFF2196F3),
          const Color(0xFF64B5F6),
        ];
      case '04':
        return [
          const Color(0xFF455A64),
          const Color(0xFF607D8B),
          const Color(0xFF90A4AE),
        ];
      case '09':
      case '10':
        return [
          const Color(0xFF263238),
          const Color(0xFF37474F),
          const Color(0xFF455A64),
        ];
      case '11':
        return [
          const Color(0xFF1A1A2E),
          const Color(0xFF16213E),
          const Color(0xFF0F3460),
        ];
      case '13':
        return [
          const Color(0xFF4FC3F7),
          const Color(0xFF81D4FA),
          const Color(0xFFB3E5FC),
        ];
      case '50':
        return [
          const Color(0xFF78909C),
          const Color(0xFF90A4AE),
          const Color(0xFFB0BEC5),
        ];
      default:
        return [
          const Color(0xFF1565C0),
          const Color(0xFF1976D2),
          const Color(0xFF42A5F5),
        ];
    }
  }

  static String formatTemperature(double temp, {bool showUnit = true}) {
    final rounded = temp.round();
    return showUnit ? '$rounded°C' : '$rounded°';
  }

  static String formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  static String formatDate(DateTime date, {bool short = false}) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const shortMonths = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    const shortDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final weekday = date.weekday - 1;
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
    final isTomorrow = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day + 1;

    if (isToday) return short ? 'Today' : 'Today';
    if (isTomorrow) return short ? 'Tomorrow' : 'Tomorrow';

    if (short) return shortDays[weekday];
    return '${days[weekday]}, ${(short ? shortMonths : months)[date.month - 1]} ${date.day}';
  }

  static String getWindDirection(int degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  static String getUVLevel(double uv) {
    if (uv < 3) return 'Low';
    if (uv < 6) return 'Moderate';
    if (uv < 8) return 'High';
    if (uv < 11) return 'Very High';
    return 'Extreme';
  }

  static bool isNightTime() {
    final hour = DateTime.now().hour;
    return hour < 6 || hour >= 20;
  }

  static String iconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  static String capitalizeWords(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join(' ');
  }
}
