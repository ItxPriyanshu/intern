import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static Future<List<Map<String, dynamic>>> searchCity(String query) async{
    if(query.isEmpty) return [];

    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1",
    );

    final response = await http.get(url, headers: {
        "User-Agent": "flutter_app"
      });

      if(response.statusCode == 200){
        final data = jsonDecode(response.body);
        return List<Map<String,dynamic>>.from(data);
      }else{
        return[];
      }
  }
}