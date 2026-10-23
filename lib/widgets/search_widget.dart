// lib/widgets/search_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/weather_service.dart';

class SearchWidget extends StatefulWidget {
  final Function(String) onCitySelected;
  final VoidCallback onLocationPressed;

  const SearchWidget({
    super.key,
    required this.onCitySelected,
    required this.onLocationPressed,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _controller = TextEditingController();
  final WeatherService _service = WeatherService();
  List<String> _suggestions = [];
  bool _isSearching = false;
  bool _showSuggestions = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onChanged(String value) async {
    if (value.length >= 2) {
      setState(() => _isSearching = true);
      final results = await _service.searchCities(value);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _isSearching = false;
          _showSuggestions = results.isNotEmpty;
        });
      }
    } else {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Search city...',
                    hintStyle: GoogleFonts.outfit(
                        color: Colors.white.withValues(alpha: 0.5)),
                    prefixIcon: _isSearching
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          )
                        : Icon(Icons.search_rounded,
                            color: Colors.white.withValues(alpha: 0.7)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 4),
                  ),
                  onChanged: _onChanged,
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      widget.onCitySelected(value);
                      setState(() => _showSuggestions = false);
                    }
                  },
                ),
              ),
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.7)),
                  onPressed: () {
                    _controller.clear();
                    setState(() => _showSuggestions = false);
                  },
                ),
              Container(
                height: 30,
                width: 1,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              IconButton(
                icon: Icon(Icons.my_location_rounded,
                    color: Colors.white.withValues(alpha: 0.9)),
                onPressed: widget.onLocationPressed,
                tooltip: 'Use my location',
              ),
            ],
          ),
        ),
        if (_showSuggestions)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A3A5C),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: _suggestions.asMap().entries.map((entry) {
                return ListTile(
                  dense: true,
                  leading: Icon(Icons.location_on_rounded,
                      color: Colors.white.withValues(alpha: 0.6), size: 18),
                  title: Text(
                    entry.value,
                    style:
                        GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    _controller.text = entry.value;
                    setState(() => _showSuggestions = false);
                    widget.onCitySelected(
                        entry.value.split(',').first.trim());
                  },
                );
              }).toList(),
            ),
          ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1, end: 0),
      ],
    );
  }
}
