import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

import '../models/station.dart';

class FoodBookingController extends GetxController {
  final trainController = TextEditingController();
  final stationController = TextEditingController(); // Added station controller
  final selectedDate = Rxn<DateTime>();
  final finalUrl = RxnString();
  final showWebView = false.obs;
  final isLoading = true.obs; // Added loading state for WebView
  final stationSuggestions = <Station>[].obs;

  @override
  void onClose() {
    // Clean up controllers when the controller is disposed
    trainController.dispose();
    stationController.dispose(); // Dispose station controller
    super.onClose();
  }

  void pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  void fetchStationSuggestions(String query) async {
    if (query.isEmpty) {
      stationSuggestions.value = [];
      return;
    }
    
    try {
      final jsonString = await rootBundle.loadString('stationcode.json');
      final jsonData = json.decode(jsonString);
      final allStations = (jsonData['stations'] as List<dynamic>)
          .map((station) => Station.fromJson(station))
          .toList();
          
      stationSuggestions.value = allStations.where((station) =>
        station.name.toLowerCase().contains(query.toLowerCase()) ||
        station.code.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      debugPrint('Error loading stations: $e');
      stationSuggestions.value = [];
    }
  }

  void proceedToWebView(BuildContext context) {
    final train = trainController.text.trim();
    final station = stationController.text.trim(); // Get station value
    final date = selectedDate.value;

    // Validate all fields
    if (train.isEmpty || station.isEmpty || date == null) {
      Get.snackbar(
        'Missing Information',
        'Please enter train number, boarding station, and select date.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
        icon: const Icon(Icons.error_outline, color: Colors.red),
      );
      return;
    }

    // Reset loading state
    isLoading.value = true;

    // Format the date properly for the URL
    final formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final url = 'https://ecatering.irctc.co.in/train/$train/${station.toUpperCase()}?boardingDate=$formattedDate';

    // Debug output
    debugPrint('Loading WebView with URL: $url');

    finalUrl.value = url;
    showWebView.value = true;

    // Simulate loading finishing after page loads
    Future.delayed(const Duration(seconds: 3), () {
      isLoading.value = false;
    });
  }
}
