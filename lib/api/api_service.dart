import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/train.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'http://traindelaybackend-production.up.railway.app/api/';

  Future<Train> getTrainsBetweenStations({
    required String sourceName,
    required String sourceCode,
    required String destinationName,
    required String destinationCode,
    required String date,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/trains-between?source_name=$sourceName&source_code=$sourceCode&destination_name=$destinationName&destination_code=$destinationCode&date=$date'
      );

      debugPrint(' API Request URL: $url');
      debugPrint(' Request Parameters:');
      debugPrint('   Source Name: $sourceName');
      debugPrint('   Source Code: $sourceCode');
      debugPrint('   Destination Name: $destinationName');
      debugPrint('   Destination Code: $destinationCode');
      debugPrint('   Date: $date');

      final response = await http.get(url);
      
      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint(' Response Headers: ${response.headers}');
      debugPrint(' Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          debugPrint(' Successfully parsed JSON response');
          return Train.fromJson(jsonResponse);
        } catch (e) {
          debugPrint(' JSON Parsing Error: $e');
          throw Exception('Sorry, we could not process the train data. Please try again.');
        }
      } else if (response.statusCode == 404) {
        debugPrint(' API Error: No trains found for the given route');
        throw Exception('No trains found for the selected route.');
      } else if (response.statusCode == 400) {
        debugPrint(' API Error: Invalid request parameters');
        throw Exception('Invalid station details. Please check your input.');
      } else if (response.statusCode >= 500) {
        debugPrint(' API Error: Server error occurred');
        throw Exception('Some Error Occured. Or no Trains for the route Specified.');
      } else {
        debugPrint(' API Error: Unexpected status code ${response.statusCode}');
        throw Exception('Unexpected error: ${response.statusCode}. Please try again.');
      }
    } on http.ClientException catch (e) {
      debugPrint(' Network Error (ClientException): $e');
      throw Exception('Network error: Unable to connect to the server. Please check your internet connection.');
    } on FormatException catch (e) {
      debugPrint(' Format Error: $e');
      throw Exception('Received invalid data from the server. Please try again.');
    } catch (e) {
      debugPrint(' Unknown Error: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<Map<String, dynamic>> fetchTrainDelaySchedule({
    required String trainName,
    required String trainNumber,
    required String date,
  }) async {
    final String url =
        'http://traindelaybackend-production.up.railway.app/api/train-schedule?train_name=${Uri.encodeComponent(trainName)}&train_number=$trainNumber&date=$date';
    try {
      debugPrint(' Delay API Request URL: $url');
      final response = await http.get(Uri.parse(url));
      debugPrint(' Delay API Response Status Code: ${response.statusCode}');
      debugPrint(' Delay API Response Body: ${response.body}');
      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          if (jsonResponse['status'] == 'success') {
            return {
              'schedule': jsonResponse['data']['schedule'] as List<dynamic>,
              'train_name': trainName,
              'train_number': trainNumber,
              'train_info': jsonResponse['data']['train_info']
            };
          } else {
            throw Exception('Failed to fetch delay data.');
          }
        } catch (e) {
          debugPrint(' Delay JSON Parsing Error: $e');
          throw Exception('Sorry, we could not process the delay data. Please try again.');
        }
      } else if (response.statusCode == 404) {
        throw Exception('No delay data found for this train.');
      } else {
        throw Exception('Failed to fetch delay data: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: Unable to connect to the delay server.');
    } on FormatException catch (e) {
      debugPrint(' Format Error: $e');
      throw Exception('Received invalid delay data from the server.');
    } catch (e) {
      throw Exception('An unexpected error occurred while fetching delay data.');
    }
  }
}
