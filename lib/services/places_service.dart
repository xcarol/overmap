import 'dart:convert';
import 'dart:developer';
import 'package:overmap/models/place.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

class PlacesService {
  static const String _osmSearchPlace =
      'https://nominatim.openstreetmap.org/search?format=json&q={SEARCH}';

  static const String _osmSearchDetails =
      'https://nominatim.openstreetmap.org/lookup?format=json&osm_ids={OSM_ID}&polygon_kml=1';

  List<String> getPlacePolygon(Map<String, dynamic> poligon) {
    if (poligon['geokml'] != null) {
      List<String> polygonCoordinates = [];

      XmlDocument geokml = XmlDocument.parse(poligon['geokml']);
      Iterable<XmlElement> coordinatesElements =
          geokml.findAllElements('coordinates');

      for (XmlElement element in coordinatesElements) {
        polygonCoordinates.add(element.innerText);
      }

      return polygonCoordinates;
    }

    return [];
  }

  Future<List<String>> getPlaceBoundaryPolygons(Place place) async {

    Map<String, dynamic> placeDetails = await getPlaceDetails(place.placeId);
    return getPlacePolygon(placeDetails);
  }

  Future<dynamic> searchPlaces(String search) async {
    try {
      final response = await http.get(Uri.parse(
        PlacesService._osmSearchPlace.replaceFirst('{SEARCH}', search),
      ));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error: ${response.statusCode} for a request of a place search');
      }
    } catch (e) {
      log('Error: $e \nIt might be due to CORS with Web Browser');
    }
  }

  Future<Map<String, dynamic>> getPlaceDetails(
    String osmId,
  ) async {
    final response = await http.get(Uri.parse(
      _osmSearchDetails.replaceFirst('{OSM_ID}', osmId),
    ));

    if (response.statusCode == 200) {
      List places = json.decode(response.body);
      if (places.length == 1) {
        var x = places.firstOrNull;
        return x;
      } else {
        return <String, dynamic>{};
      }
    } else {
      throw Exception('Error: ${response.statusCode} for a request of a place details');
    }
  }
}
