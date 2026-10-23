// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../utils/weather_utils.dart';
import '../widgets/weather_info_card.dart';
import '../widgets/hourly_forecast_widget.dart';
import '../widgets/daily_forecast_widget.dart';
import '../widgets/search_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();

  CurrentWeather? _currentWeather;
  List<HourlyForecast> _hourlyForecast = [];
  List<ForecastDay> _dailyForecast = [];

  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  bool _showSearch = false;

  late AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _loadLocationWeather();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadLocationWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        await _fetchWeatherByCoords(position.latitude, position.longitude);
      } else {
        await _fetchWeatherByCity('London');
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWeatherByCoords(double lat, double lon) async {
    try {
      final weather = await _weatherService.getCurrentWeather(lat: lat, lon: lon);
      final hourly = await _weatherService.getHourlyForecast(lat: lat, lon: lon);
      final daily = await _weatherService.getDailyForecast(lat: lat, lon: lon);

      if (mounted) {
        setState(() {
          _currentWeather = weather;
          _hourlyForecast = hourly;
          _dailyForecast = daily;
          _isLoading = false;
          _isRefreshing = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _fetchWeatherByCity(String city) async {
    setState(() {
      _isLoading = _currentWeather == null;
      _error = null;
    });
    try {
      final weather = await _weatherService.getCurrentWeather(cityName: city);
      final hourly = await _weatherService.getHourlyForecast(
          lat: weather.lat, lon: weather.lon);
      final daily = await _weatherService.getDailyForecast(
          lat: weather.lat, lon: weather.lon);

      if (mounted) {
        setState(() {
          _currentWeather = weather;
          _hourlyForecast = hourly;
          _dailyForecast = daily;
          _isLoading = false;
          _showSearch = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    _refreshController.repeat();
    if (_currentWeather != null) {
      await _fetchWeatherByCoords(_currentWeather!.lat, _currentWeather!.lon);
    }
    _refreshController.stop();
    _refreshController.reset();
  }

  List<Color> get _gradientColors {
    if (_currentWeather == null) {
      return [
        const Color(0xFF1565C0),
        const Color(0xFF0D47A1),
        const Color(0xFF0A2472)
      ];
    }
    return WeatherUtils.getGradientColors(
        _currentWeather!.iconCode, WeatherUtils.isNightTime());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _gradientColors,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const _LoadingView()
              : _error != null && _currentWeather == null
                  ? _ErrorView(
                      error: _error!,
                      onRetry: _loadLocationWeather,
                      onSearch: () => setState(() => _showSearch = true),
                    )
                  : _buildMainContent(),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: _refresh,
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      color: Colors.white,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                if (_showSearch) _buildSearchBar() else _buildCityTitle(),
                if (_error != null) _buildErrorBanner(),
                if (_currentWeather != null) ...[
                  _buildCurrentWeather(),
                  const SizedBox(height: 24),
                  _buildWeatherDetails(),
                  const SizedBox(height: 24),
                  if (_hourlyForecast.isNotEmpty)
                    HourlyForecastWidget(hourlyData: _hourlyForecast),
                  const SizedBox(height: 24),
                  if (_dailyForecast.isNotEmpty)
                    DailyForecastWidget(forecastDays: _dailyForecast),
                  const SizedBox(height: 40),
                  _buildFooter(),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'WeatherNow',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          Row(
            children: [
              if (_isRefreshing)
                RotationTransition(
                  turns: _refreshController,
                  child: Icon(Icons.refresh_rounded,
                      color: Colors.white.withValues(alpha: 0.8), size: 20),
                )
              else
                IconButton(
                  icon: Icon(Icons.refresh_rounded,
                      color: Colors.white.withValues(alpha: 0.8)),
                  onPressed: _refresh,
                  iconSize: 22,
                ),
              IconButton(
                icon: Icon(
                  _showSearch ? Icons.close_rounded : Icons.search_rounded,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                onPressed: () => setState(() => _showSearch = !_showSearch),
                iconSize: 22,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: SearchWidget(
        onCitySelected: _fetchWeatherByCity,
        onLocationPressed: _loadLocationWeather,
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildCityTitle() {
    final w = _currentWeather!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_rounded,
                  color: Colors.white.withValues(alpha: 0.8), size: 16),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '${w.cityName}, ${w.country}',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            'Updated ${WeatherUtils.formatTime(w.lastUpdated)}',
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }

  Widget _buildCurrentWeather() {
    final w = _currentWeather!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main temperature
                Text(
                  '${w.temperature.round()}°',
                  style: GoogleFonts.outfit(
                    fontSize: 90,
                    fontWeight: FontWeight.w200,
                    color: Colors.white,
                    height: 1.0,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                // Description
                Text(
                  WeatherUtils.capitalizeWords(w.description),
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w400,
                  ),
                ).animate(delay: 100.ms).fadeIn(),

                const SizedBox(height: 8),

                // Feels like / H:L
                Text(
                  'Feels ${w.feelsLike.round()}°  •  H:${w.tempMax.round()}° L:${w.tempMin.round()}°',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ).animate(delay: 200.ms).fadeIn(),
              ],
            ),
          ),

          // Weather emoji  
          Column(
            children: [
              const SizedBox(height: 8),
              Text(
                WeatherUtils.getWeatherEmoji(w.iconCode),
                style: const TextStyle(fontSize: 80),
              )
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    curve: Curves.elasticOut,
                  )
                  .then()
                  .shimmer(duration: 2000.ms, color: Colors.white24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetails() {
    final w = _currentWeather!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          WeatherInfoCard(
            icon: Icons.water_drop_rounded,
            label: 'HUMIDITY',
            value: '${w.humidity}%',
            animDelay: 0,
          ),
          WeatherInfoCard(
            icon: Icons.air_rounded,
            label: 'WIND',
            value: '${w.windSpeed.round()} m/s',
            subValue: WeatherUtils.getWindDirection(w.windDegree),
            animDelay: 80,
          ),
          WeatherInfoCard(
            icon: Icons.visibility_rounded,
            label: 'VISIBILITY',
            value: '${(w.visibility / 1000).toStringAsFixed(1)} km',
            animDelay: 160,
          ),
          WeatherInfoCard(
            icon: Icons.compress_rounded,
            label: 'PRESSURE',
            value: '${w.pressure} hPa',
            animDelay: 240,
          ),
          WeatherInfoCard(
            icon: Icons.wb_sunny_rounded,
            label: 'SUNRISE',
            value: WeatherUtils.formatTime(w.sunrise),
            animDelay: 320,
          ),
          WeatherInfoCard(
            icon: Icons.nights_stay_rounded,
            label: 'SUNSET',
            value: WeatherUtils.formatTime(w.sunset),
            animDelay: 400,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.amber, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        'Powered by OpenWeatherMap',
        style: GoogleFonts.outfit(
          fontSize: 10,
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌤️', style: TextStyle(fontSize: 80))
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 2000.ms)
              .then()
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
                duration: 1000.ms,
                curve: Curves.easeInOut,
              )
              .then()
              .scale(
                begin: const Offset(1.1, 1.1),
                end: const Offset(0.9, 0.9),
                duration: 1000.ms,
                curve: Curves.easeInOut,
              ),
          const SizedBox(height: 24),
          Text(
            'Fetching weather...',
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final VoidCallback onSearch;

  const _ErrorView({
    required this.error,
    required this.onRetry,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 64))
                .animate()
                .fadeIn()
                .shake(),
            const SizedBox(height: 24),
            Text(
              'Oops!',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    foregroundColor: Colors.white,
                    side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: onSearch,
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    foregroundColor: Colors.blue.shade800,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
