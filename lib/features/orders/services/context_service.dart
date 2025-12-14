import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../utils/app_logger.dart';

/// Servicio para obtener datos de contexto (clima, feriados) desde APIs gratuitas
class ContextService {
  static final ContextService _instance = ContextService._internal();
  factory ContextService() => _instance;
  ContextService._internal();

  // Cache de feriados para evitar llamadas repetidas
  List<DateTime>? _cachedHolidays;
  int? _cachedYear;

  // Coordenadas por defecto (Lima, Perú)
  static const double _defaultLatitude = -12.0464;
  static const double _defaultLongitude = -77.0428;

  /// Obtiene el clima actual usando Open-Meteo API (gratis, sin registro)
  /// Retorna: "Sunny", "Cloudy" o "Rainy"
  Future<String> getCurrentWeather({
    double? latitude,
    double? longitude,
  }) async {
    final lat = latitude ?? _defaultLatitude;
    final lon = longitude ?? _defaultLongitude;

    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat&longitude=$lon&current_weather=true',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final weatherCode = data['current_weather']['weathercode'] as int;
        final weather = _mapWeatherCode(weatherCode);

        AppLogger.log(
          'Clima obtenido: $weather (código: $weatherCode)',
          prefix: 'CONTEXT:',
        );
        return weather;
      }
    } catch (e) {
      AppLogger.log(
        'Error obteniendo clima, usando default: $e',
        prefix: 'CONTEXT_ERROR:',
      );
    }

    return 'Sunny';
  }

  /// Mapea códigos WMO a categorías del modelo
  String _mapWeatherCode(int code) {
    // WMO Weather interpretation codes
    // https://open-meteo.com/en/docs
    if (code == 0) {
      return 'Sunny';
    } else if (code >= 1 && code <= 3) {
      return 'Cloudy';
    } else if (code >= 45 && code <= 48) {
      return 'Cloudy';
    } else if (code >= 51 && code <= 67) {
      return 'Rainy';
    } else if (code >= 71 && code <= 77) {
      return 'Rainy';
    } else if (code >= 80 && code <= 99) {
      return 'Rainy';
    }
    return 'Cloudy';
  }

  /// Verifica si hoy es feriado en Perú usando Nager.Date API (gratis, sin registro)
  Future<bool> isHolidayToday() async {
    final now = DateTime.now();
    return await isHoliday(now);
  }

  /// Verifica si una fecha específica es feriado en Perú
  Future<bool> isHoliday(DateTime date) async {
    try {
      final holidays = await _getHolidaysForYear(date.year);

      for (final holiday in holidays) {
        if (holiday.year == date.year &&
            holiday.month == date.month &&
            holiday.day == date.day) {
          AppLogger.log(
            'Fecha ${date.toIso8601String().split('T')[0]} es feriado',
            prefix: 'CONTEXT:',
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      AppLogger.log('Error verificando feriado: $e', prefix: 'CONTEXT_ERROR:');
      return false;
    }
  }

  /// Obtiene los feriados del año desde la API (con cache)
  Future<List<DateTime>> _getHolidaysForYear(int year) async {
    if (_cachedYear == year && _cachedHolidays != null) {
      return _cachedHolidays!;
    }

    try {
      final url = Uri.parse(
        'https://date.nager.at/api/v3/PublicHolidays/$year/PE',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        _cachedHolidays = data.map((holiday) {
          return DateTime.parse(holiday['date'] as String);
        }).toList();

        _cachedYear = year;

        AppLogger.log(
          'Feriados de Perú $year cargados: ${_cachedHolidays!.length}',
          prefix: 'CONTEXT:',
        );

        return _cachedHolidays!;
      }
    } catch (e) {
      AppLogger.log('Error obteniendo feriados: $e', prefix: 'CONTEXT_ERROR:');
    }

    return [];
  }

  /// Obtiene todo el contexto de una vez para optimizar
  Future<Map<String, dynamic>> getOrderContext({
    double? latitude,
    double? longitude,
    bool specialEvent = false,
  }) async {
    final results = await Future.wait([
      getCurrentWeather(latitude: latitude, longitude: longitude),
      isHolidayToday(),
    ]);

    return {
      'weather': results[0] as String,
      'holiday': results[1] as bool,
      'specialEvent': specialEvent,
    };
  }
}
