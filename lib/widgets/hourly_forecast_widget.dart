// lib/widgets/hourly_forecast_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_model.dart';
import '../utils/weather_utils.dart';

class HourlyForecastWidget extends StatelessWidget {
  final List<HourlyForecast> hourlyData;

  const HourlyForecastWidget({super.key, required this.hourlyData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.access_time_rounded,
                  size: 16, color: Colors.white.withValues(alpha: 0.7)),
              const SizedBox(width: 6),
              Text(
                'HOURLY FORECAST',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: hourlyData.length > 12 ? 12 : hourlyData.length,
              itemBuilder: (context, index) {
                final item = hourlyData[index];
                final isNow = index == 0;
                return _HourlyItem(item: item, isNow: isNow);
              },
            ),
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }
}

class _HourlyItem extends StatelessWidget {
  final HourlyForecast item;
  final bool isNow;

  const _HourlyItem({required this.item, required this.isNow});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: isNow
          ? BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.4)),
            )
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            isNow ? 'Now' : WeatherUtils.formatTime(item.time),
            style: GoogleFonts.outfit(
              fontSize: 10,
              color: isNow
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.7),
              fontWeight: isNow ? FontWeight.w700 : FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            WeatherUtils.getWeatherEmoji(item.iconCode),
            style: const TextStyle(fontSize: 22),
          ),
          Text(
            WeatherUtils.formatTemperature(item.temperature),
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (item.pop > 10)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.water_drop,
                    size: 8, color: Colors.lightBlue.shade200),
                const SizedBox(width: 1),
                Text(
                  '${item.pop}%',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.lightBlue.shade200,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
