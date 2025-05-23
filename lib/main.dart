import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/dashboard.dart';
import 'screens/train_finder_screen.dart';
import 'screens/train_list_screen.dart';
import 'screens/food_booking_screen.dart';
import 'screens/train_details_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TrainBuddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF86A3C),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF86A3C),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const DashboardScreen()),
        GetPage(name: '/train-finder', page: () => const TrainFinderScreen()),
        GetPage(name: '/train-list', page: () => const TrainListScreen()),
        GetPage(name: '/train-details', page: () => const TrainDetailsScreen()),
        GetPage(name: '/food-booking', page: () =>  FoodBookingScreen()),
      ],
    );
  }
}
