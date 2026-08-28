import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/bus_model.dart';
import '../models/live_location.dart';
import '../models/route_model.dart';
import '../models/stop_model.dart';

class TransitApiException implements Exception {
  final String message;
  final int? statusCode;
  TransitApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class TransitApiService {
  static final TransitApiService instance = TransitApiService();

  /// Centralized API Base URL for backend connection.
  /// Overridable at compile time via: --dart-define=API_BASE_URL=https://your-backend-domain.com
  static String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// Standard HTTP timeout duration (10s prevents false connection timeouts on browser cold-start)
  static const Duration _requestTimeout = Duration(seconds: 10);

  /// Internal cache for stops lookup
  List<StopModel>? _cachedStops;

  Future<List<BusModel>> getAllBuses() => fetchBuses();
  Future<List<RouteModel>> getAllRoutes() => fetchRoutes();
  Future<List<StopModel>> getAllStops() => fetchStops();

  /// Fetches registered buses from GET /api/buses.
  Future<List<BusModel>> fetchBuses() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/buses'))
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final dynamic rawData = body['data'] ?? body;

        List<BusModel> buses = [];
        if (rawData is Map<String, dynamic>) {
          rawData.forEach((key, val) {
            if (val is Map<String, dynamic>) {
              buses.add(BusModel.fromJson(key, val));
            }
          });
        } else if (rawData is List) {
          for (int i = 0; i < rawData.length; i++) {
            if (rawData[i] is Map<String, dynamic>) {
              final item = rawData[i] as Map<String, dynamic>;
              final key = item['id'] ?? 'BUS${i + 1}';
              buses.add(BusModel.fromJson(key, item));
            }
          }
        }
        return buses;
      }
      throw TransitApiException('Server returned status ${response.statusCode}', response.statusCode);
    } on SocketException {
      throw TransitApiException('Unable to connect to server');
    } on TimeoutException {
      throw TransitApiException('Connection timed out. Server unavailable.');
    } catch (e) {
      if (e is TransitApiException) rethrow;
      throw TransitApiException('Failed to load buses from server');
    }
  }

  /// Fetches registered routes from GET /api/routes.
  Future<List<RouteModel>> fetchRoutes() async {
    try {
      // Pre-fetch stops for lookup
      final stopsList = await fetchStops().catchError((_) => <StopModel>[]);
      final stopsLookup = {for (var s in stopsList) s.id: s};

      final response = await http
          .get(Uri.parse('$baseUrl/api/routes'))
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final dynamic rawData = body['data'] ?? body;

        List<RouteModel> routes = [];
        if (rawData is Map<String, dynamic>) {
          rawData.forEach((key, val) {
            if (val is Map<String, dynamic>) {
              routes.add(RouteModel.fromJson(key, val, stopsLookup));
            }
          });
        } else if (rawData is List) {
          for (int i = 0; i < rawData.length; i++) {
            if (rawData[i] is Map<String, dynamic>) {
              final item = rawData[i] as Map<String, dynamic>;
              final key = item['id'] ?? 'ROUTE${i + 1}';
              routes.add(RouteModel.fromJson(key, item, stopsLookup));
            }
          }
        }
        return routes;
      }
      throw TransitApiException('Server returned status ${response.statusCode}', response.statusCode);
    } on SocketException {
      throw TransitApiException('Unable to connect to server');
    } on TimeoutException {
      throw TransitApiException('Connection timed out. Server unavailable.');
    } catch (e) {
      if (e is TransitApiException) rethrow;
      throw TransitApiException('Failed to load routes from server');
    }
  }

  /// Fetches registered stops from GET /api/stops.
  Future<List<StopModel>> fetchStops() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/stops'))
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final dynamic rawData = body['data'] ?? body;

        List<StopModel> stops = [];
        if (rawData is Map<String, dynamic>) {
          int index = 0;
          rawData.forEach((key, val) {
            if (val is Map<String, dynamic>) {
              stops.add(StopModel.fromJson(key, val, index + 1));
              index++;
            }
          });
        } else if (rawData is List) {
          for (int i = 0; i < rawData.length; i++) {
            if (rawData[i] is Map<String, dynamic>) {
              stops.add(StopModel.fromJson(rawData[i], null, i + 1));
            }
          }
        }
        _cachedStops = stops;
        return stops;
      }
      throw TransitApiException('Server returned status ${response.statusCode}', response.statusCode);
    } on SocketException {
      throw TransitApiException('Unable to connect to server');
    } on TimeoutException {
      throw TransitApiException('Connection timed out');
    } catch (e) {
      if (e is TransitApiException) rethrow;
      throw TransitApiException('Failed to load stops');
    }
  }

  /// Fetches live location telemetry matching GET /api/live-location/:busId.
  Future<LiveLocation?> getLiveLocation(String busId) async {
    final cleanId = busId.replaceAll(' ', '');
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/live-location/$cleanId'))
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final dynamic data = body['data'] ?? body;
        if (data is Map<String, dynamic>) {
          return LiveLocation.fromJson(data);
        }
      } else if (response.statusCode == 404) {
        throw TransitApiException('Bus location not found', 404);
      }
      throw TransitApiException('Server returned status ${response.statusCode}', response.statusCode);
    } on SocketException {
      throw TransitApiException('Unable to connect to server');
    } on TimeoutException {
      throw TransitApiException('Connection timed out');
    } catch (e) {
      if (e is TransitApiException) rethrow;
      throw TransitApiException('Unable to load bus location');
    }
  }

  /// Resolves stop model coordinates by ID (e.g., "STOP002") or shortName/name (e.g., "Subedari").
  Future<StopModel?> resolveStop(String stopIdOrName) async {
    if (_cachedStops == null || _cachedStops!.isEmpty) {
      await fetchStops().catchError((_) => <StopModel>[]);
    }
    if (_cachedStops == null) return null;

    final query = stopIdOrName.trim().toLowerCase();
    for (final stop in _cachedStops!) {
      if (stop.id.toLowerCase() == query ||
          stop.shortName.toLowerCase() == query ||
          stop.name.toLowerCase() == query ||
          stop.name.toLowerCase().contains(query)) {
        return stop;
      }
    }
    return null;
  }

  /// Fetches the RouteModel assigned to a specific bus.
  Future<RouteModel?> getRouteForBus(String busId) async {
    try {
      final routes = await fetchRoutes();
      final cleanId = busId.replaceAll(' ', '').toUpperCase();
      for (final route in routes) {
        if (route.assignedBusIds.any((b) => b.toUpperCase() == cleanId)) {
          return route;
        }
      }
      if (routes.isNotEmpty) return routes.first;
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Returns the ordered stops for a specific bus route.
  Future<List<StopModel>> getStopsForBus(String busId) async {
    final route = await getRouteForBus(busId);
    if (route != null && route.stops.isNotEmpty) {
      return route.stops;
    }
    if (_cachedStops != null && _cachedStops!.isNotEmpty) {
      return _cachedStops!;
    }
    return await fetchStops().catchError((_) => <StopModel>[]);
  }

  /// Helper to convert route stop models to map structure
  List<Map<String, String>> getRouteStops([String? busId]) {
    if (_cachedStops != null && _cachedStops!.isNotEmpty) {
      return _cachedStops!.map((s) => {
        'id': s.id,
        'name': s.name,
        'shortName': s.shortName,
        'latitude': s.latitude.toString(),
        'longitude': s.longitude.toString(),
      }).toList();
    }
    return const [
      {
        'id': 'STOP001',
        'name': 'Warangal Bus Station',
        'shortName': 'Warangal',
        'latitude': '17.9784',
        'longitude': '79.5941',
      },
      {
        'id': 'STOP002',
        'name': 'Hanamkonda Chowrasta',
        'shortName': 'Hanamkonda',
        'latitude': '17.9820',
        'longitude': '79.5850',
      },
      {
        'id': 'STOP003',
        'name': 'Subedari Circle',
        'shortName': 'Subedari',
        'latitude': '17.9870',
        'longitude': '79.5890',
      },
      {
        'id': 'STOP004',
        'name': 'NIT Warangal Gate',
        'shortName': 'NIT Warangal',
        'latitude': '17.9826',
        'longitude': '79.5307',
      },
      {
        'id': 'STOP005',
        'name': 'Kazipet Junction',
        'shortName': 'Kazipet',
        'latitude': '17.9890',
        'longitude': '79.5180',
      },
    ];
  }
}
