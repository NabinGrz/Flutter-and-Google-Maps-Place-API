import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/string_constants.dart';
import '../model/place_model/place_model.dart';

class Repo {
  Repo._();
  static Future<PredictionModel?> placeAutoComplete(
      {required String placeInput}) async {
    try {
      Map<String, dynamic> querys = {
        'input': placeInput,
        'key': AppString.google_map_api_key
      };
      final url = Uri.https(
          "maps.googleapis.com", "maps/api/place/autocomplete/json", querys);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return PredictionModel.fromJson(jsonDecode(response.body));
      } else {
        response.body;
      }
    } on Exception catch (e) {
      print(e.toString());
    }
    return null;
  }
}
