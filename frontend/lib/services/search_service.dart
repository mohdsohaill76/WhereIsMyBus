import '../models/bus_model.dart';
import '../models/route_model.dart';
import '../models/stop_model.dart';
import '../models/search_result.dart';

/// Intelligent Search Service providing multi-entity matching and relevance ordering
class SearchService {
  static final SearchService instance = SearchService._internal();

  factory SearchService() => instance;

  SearchService._internal();

  /// Performs an instant multi-entity search with relevance scoring and optional type filtering
  List<SearchResult> search({
    required String query,
    String typeFilter = 'all', // 'all' | 'buses' | 'routes' | 'stops'
    required List<BusModel> buses,
    required List<RouteModel> routes,
    required List<StopModel> stops,
  }) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return [];

    final List<SearchResult> results = [];
    final filter = typeFilter.toLowerCase();

    // 1. Search Buses
    if (filter == 'all' || filter == 'buses' || filter == 'bus') {
      for (final bus in buses) {
        final id = bus.id.toLowerCase();
        final num = bus.busNumber.toLowerCase();
        final route = bus.routeName.toLowerCase();

        double score = 0.0;
        if (num == cleanQuery || id == cleanQuery) {
          score = 100.0;
        } else if (num.startsWith(cleanQuery) || id.startsWith(cleanQuery)) {
          score = 80.0;
        } else if (num.contains(cleanQuery) || id.contains(cleanQuery)) {
          score = 60.0;
        } else if (route.contains(cleanQuery)) {
          score = 40.0;
        }

        if (score > 0) {
          results.add(
            SearchResult(
              type: 'bus',
              id: bus.id,
              title: bus.busNumber,
              subtitle: '${bus.routeName} • ${bus.status.toUpperCase()}',
              metadata: {
                'routeId': bus.routeId,
                'status': bus.status,
                'routeName': bus.routeName,
              },
              relevanceScore: score,
            ),
          );
        }
      }
    }

    // 2. Search Routes
    if (filter == 'all' || filter == 'routes' || filter == 'route') {
      for (final route in routes) {
        final id = route.id.toLowerCase();
        final name = route.name.toLowerCase();
        final matchedStop = route.stops.where((s) =>
            s.name.toLowerCase().contains(cleanQuery) ||
            s.shortName.toLowerCase().contains(cleanQuery));

        double score = 0.0;
        if (id == cleanQuery || name == cleanQuery) {
          score = 100.0;
        } else if (id.startsWith(cleanQuery) || name.startsWith(cleanQuery)) {
          score = 85.0;
        } else if (name.contains(cleanQuery)) {
          score = 65.0;
        } else if (matchedStop.isNotEmpty) {
          score = 45.0;
        }

        if (score > 0) {
          final stopNames = route.stops.map((s) => s.shortName.isNotEmpty ? s.shortName : s.name).join(' → ');
          results.add(
            SearchResult(
              type: 'route',
              id: route.id,
              title: route.name,
              subtitle: route.stops.isNotEmpty
                  ? '${route.stops.length} stops: $stopNames'
                  : 'Route corridor ${route.id}',
              metadata: {
                'route': route,
                'stopsCount': route.stops.length,
                'assignedBuses': route.assignedBusIds,
              },
              relevanceScore: score,
            ),
          );
        }
      }
    }

    // 3. Search Stops
    if (filter == 'all' || filter == 'stops' || filter == 'stop') {
      for (final stop in stops) {
        final id = stop.id.toLowerCase();
        final name = stop.name.toLowerCase();
        final shortName = stop.shortName.toLowerCase();

        double score = 0.0;
        if (name == cleanQuery || shortName == cleanQuery || id == cleanQuery) {
          score = 100.0;
        } else if (name.startsWith(cleanQuery) || shortName.startsWith(cleanQuery)) {
          score = 80.0;
        } else if (name.contains(cleanQuery) || shortName.contains(cleanQuery)) {
          score = 60.0;
        }

        if (score > 0) {
          results.add(
            SearchResult(
              type: 'stop',
              id: stop.id,
              title: stop.name,
              subtitle: stop.shortName.isNotEmpty
                  ? 'Code: ${stop.shortName} • Transit Station'
                  : 'Transit Station • ID: ${stop.id}',
              metadata: {
                'stop': stop,
                'lat': stop.latitude,
                'lng': stop.longitude,
                'shortName': stop.shortName,
              },
              relevanceScore: score,
            ),
          );
        }
      }
    }

    // Sort by relevance score descending, then alphabetically
    results.sort((a, b) {
      final scoreCmp = b.relevanceScore.compareTo(a.relevanceScore);
      if (scoreCmp != 0) return scoreCmp;
      return a.title.compareTo(b.title);
    });

    return results;
  }
}
