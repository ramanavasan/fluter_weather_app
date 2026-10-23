// lib/widgets/daily_forecast_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_model.dart';
import '../utils/weather_utils.dart';

class DailyForecastWidget extends StatelessWidget {
  final List<ForecastDay> forecastDays;

  const DailyForecastWidget({super.key, required this.forecastDays});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 16, color: Colors.white.withValues(alpha: 0.7)),
              const SizedBox(width: 6),
              Text(
                '${forecastDays.length}-DAY FORECAST',
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
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: forecastDays.asMap().entries.map((entry) {
              final index = entry.key;
              final day = entry.value;
              return _DayRow(
                day: day,
                index: index,
                isLast: index == forecastDays.length - 1,
              );
            }).toList(),
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  final ForecastDay day;
  final int index;
  final bool isLast;

  const _DayRow({
    required this.day,
    required this.index,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    const double overallMin = -5;
    const double overallMax = 40;
    const double range = overallMax - overallMin;
    final double minFraction = (day.tempMin - overallMin) / range;
    final double maxFraction = (day.tempMax - overallMin) / range;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Day name
              SizedBox(
                width: 90,
                child: Text(
                  WeatherUtils.formatDate(day.date, short: true),
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),

              // Weather emoji + rain
              SizedBox(
                width: 52,
                child: Row(
                  children: [
                    Text(
                      WeatherUtils.getWeatherEmoji(day.iconCode),
                      style: const TextStyle(fontSize: 22),
                    ),
                    if (day.pop > 20)
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Text(
                          '${day.pop}%',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.lightBlue.shade200,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Min temp
              SizedBox(
                width: 36,
                child: Text(
                  WeatherUtils.formatTemperature(day.tempMin),
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),

              const SizedBox(width: 8),

              // Temperature bar
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Positioned(
                            left: constraints.maxWidth *
                                minFraction.clamp(0.0, 1.0),
                            width: constraints.maxWidth *
                                (maxFraction - minFraction).clamp(0.0, 1.0),
                            top: 0,
                            bottom: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.lightBlue.shade300,
                                    Colors.orange.shade400,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Max temp
              SizedBox(
                width: 36,
                child: Text(
                  WeatherUtils.formatTemperature(day.tempMax),
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            color: Colors.white.withValues(alpha: 0.08),
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
