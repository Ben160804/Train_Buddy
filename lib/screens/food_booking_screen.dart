import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trainbuddy/controllers/food_booking_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import '../models/station.dart';

class FoodBookingScreen extends StatefulWidget {
  @override
  State<FoodBookingScreen> createState() => _FoodBookingScreenState();
}

class _FoodBookingScreenState extends State<FoodBookingScreen> with SingleTickerProviderStateMixin {
  final controller = Get.put(FoodBookingController());
  late final AnimationController _animController;
  final ValueNotifier<double> _scrollProgress = ValueNotifier(0.0);
  final ScrollController _scrollController = ScrollController();
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    WebViewPlatform.instance = AndroidWebViewPlatform();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      upperBound: 1.0,
      lowerBound: 0.0,
    );

    _animController.addListener(() {
      if (!mounted) return;
      if (_animController.value == 1.0 && !_hasAnimated && mounted) {
        setState(() => _hasAnimated = true);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_hasAnimated) {
        _animController.forward();
      }
    });

    _scrollController.addListener(() {
      if (!mounted) return;
      if (_scrollController.position.hasContentDimensions) {
        final progress = _scrollController.offset / 100;
        _scrollProgress.value = progress.clamp(0.0, 1.0);
      }
    });
  }

  @override
  void dispose() {
    _animController.removeListener(() {});
    _animController.stop();
    _animController.dispose();
    _scrollController.removeListener(() {});
    _scrollController.dispose();
    _scrollProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: _buildCustomAppBar(),
      body: Stack(
        children: [
          Positioned.fill(
            child: _AnimatedBackground(scrollProgress: _scrollProgress),
          ),
          Obx(() {
            if (controller.showWebView.value && controller.finalUrl.value != null) {
              debugPrint("Creating WebView with URL: ${controller.finalUrl.value}");
              final webViewController = WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..setBackgroundColor(const Color(0x00000000))
                ..setNavigationDelegate(
                  NavigationDelegate(
                    onProgress: (int progress) {
                      debugPrint('WebView loading progress: $progress%');
                    },
                    onPageStarted: (String url) {
                      debugPrint('WebView page started loading: $url');
                    },
                    onPageFinished: (String url) {
                      debugPrint('WebView page finished loading: $url');
                    },
                    onWebResourceError: (WebResourceError error) {
                      debugPrint('WebView error: ${error.description}');
                    },
                    onNavigationRequest: (NavigationRequest request) {
                      debugPrint('WebView navigation to: ${request.url}');
                      return NavigationDecision.navigate;
                    },
                  ),
                )
                ..loadRequest(Uri.parse(controller.finalUrl.value!));

              return Column(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                        color: Colors.white,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: WebViewWidget(controller: webViewController),
                    ),
                  ),
                ],
              ).animate()
                  .fadeIn(duration: 400.ms, curve: Curves.easeOutQuint)
                  .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
            }

            return Stack(
              children: [
                Positioned(
                  top: 120,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                  ).animate(controller: _animController)
                      .slideY(begin: 0.2, end: 0, duration: 800.ms, curve: Curves.easeOutQuart),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 180,
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/trainn_food.jpg'),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 20,
                                left: 20,
                                child: const Text(
                                  'Order delicious meals\nfor your journey',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate(controller: _animController)
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuint),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _hasAnimated
                                  ? Text(
                                'Journey Details',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFF86A3C),
                                ),
                              )
                                  : Text(
                                'Journey Details',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFF86A3C),
                                ),
                              ).animate(controller: _animController)
                                  .fadeIn(delay: 200.ms, duration: 600.ms)
                                  .slideX(begin: -0.1, end: 0, curve: Curves.easeOutQuint),
                              const SizedBox(height: 6),
                              _hasAnimated
                                  ? Text(
                                'Enter your train information to order food',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              )
                                  : Text(
                                'Enter your train information to order food',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ).animate(controller: _animController)
                                  .fadeIn(delay: 300.ms, duration: 600.ms)
                                  .slideX(begin: -0.1, end: 0, curve: Curves.easeOutQuint),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF86A3C).withOpacity(0.1),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  _buildAnimatedInputField(
                                    controller: controller.trainController,
                                    label: 'Train Number',
                                    hint: 'Enter your train number',
                                    icon: Icons.train,
                                    keyboardType: TextInputType.number,
                                    animationDelay: 400,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildStationInputField(
                                    nameController: controller.stationController,
                                    codeController: TextEditingController(),
                                    label: 'Boarding Station',
                                    hint: 'e.g. HWH, NDLS, BPL',
                                    icon: Icons.location_on,
                                    suggestions: controller.stationSuggestions,
                                    onSuggestionSelected: (station) {
                                      controller.stationController.text = station.name;
                                    },
                                    animationDelay: 500,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildDatePickerButton(animationDelay: 600),
                                  const SizedBox(height: 30),
                                  _buildProceedButton(animationDelay: 700),
                                ],
                              ),
                            ),
                          ).animate(controller: _animController)
                              .fadeIn(delay: 400.ms, duration: 600.ms)
                              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuint),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.amber[200]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.amber[800],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'We are not affiliated directly to IRCTC.',
                                    style: TextStyle(
                                      color: Colors.amber[900],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate(controller: _animController)
                              .fadeIn(delay: 800.ms, duration: 600.ms)
                              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuint),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStationInputField({
    required TextEditingController nameController,
    required TextEditingController codeController,
    required String label,
    required String hint,
    required IconData icon,
    required RxList<Station> suggestions,
    required Function(Station) onSuggestionSelected,
    int animationDelay = 0,
  }) {
    Timer? _debounceTimer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFF86A3C).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(80, 8, 16, 8),
                child: TextField(
                  style: const TextStyle(color: Color(0xFF1F2937)),
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: label,
                    labelStyle: const TextStyle(
                      color: Color(0xFF1F2937),
                      fontWeight: FontWeight.w500,
                    ),
                    hintText: hint,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                   onChanged: (value) {
                     _debounceTimer?.cancel();
                     if (value.isEmpty) {
                       suggestions.clear();
                     } else {
                       _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                         controller.fetchStationSuggestions(value);
                       });
                     }
                   },
                 ),
               ),
               Positioned(
                 left: 0,
                 top: 0,
                 bottom: 0,
                 child: Container(
                   width: 60,
                   decoration: BoxDecoration(
                     color: const Color(0xFFF86A3C).withOpacity(0.1),
                     borderRadius: BorderRadius.only(
                       topLeft: Radius.circular(16),
                       bottomLeft: Radius.circular(16),
                     ),
                   ),
                   child: Icon(icon, color: const Color(0xFFF86A3C)),
                 ),
               ),
             ],
           ),
         ),
        Obx(() {
          if (suggestions.isEmpty) return const SizedBox.shrink();
          return ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final station = suggestions[index];
                  return ListTile(
                    title: Text(station.name),
                    subtitle: Text(station.code),
                    onTap: () {
                      nameController.text = station.name;
                      codeController.text = station.code;
                      onSuggestionSelected(station);
                      suggestions.clear();
                    },
                  );
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAnimatedInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int animationDelay = 0,
  }) {
    final inputField = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF86A3C).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(80, 8, 16, 8),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.w500,
                ),
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                ),
                border: InputBorder.none,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
              keyboardType: keyboardType,
              textCapitalization: textCapitalization,
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFF86A3C).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFF86A3C),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );

    if (!_hasAnimated) {
      return inputField.animate(controller: _animController)
          .fadeIn(delay: Duration(milliseconds: animationDelay), duration: 400.ms)
          .slideX(begin: -0.1, end: 0, curve: Curves.easeOutQuint);
    }

    return inputField;
  }

  Widget _buildDatePickerButton({required int animationDelay}) {
    final dateButton = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFF86A3C).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => controller.pickDate(context),
          splashColor: const Color(0xFFF86A3C).withOpacity(0.1),
          highlightColor: const Color(0xFFF86A3C).withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF86A3C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: const Color(0xFFF86A3C),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Journey Date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                      controller.selectedDate.value == null
                          ? 'Select date'
                          : DateFormat('EEE, dd MMM yyyy').format(controller.selectedDate.value!),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: controller.selectedDate.value == null
                            ? Colors.grey[500]
                            : const Color(0xFF1F2937),
                      ),
                    )),
                  ],
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!_hasAnimated) {
      return dateButton.animate(controller: _animController)
          .fadeIn(delay: Duration(milliseconds: animationDelay), duration: 400.ms)
          .slideX(begin: -0.1, end: 0, curve: Curves.easeOutQuint);
    }

    return dateButton;
  }

  Widget _buildProceedButton({required int animationDelay}) {
    final proceedButton = SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => controller.proceedToWebView(context),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color(0xFFF86A3C),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Find Restaurants',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );

    if (!_hasAnimated) {
      return proceedButton.animate(controller: _animController)
          .fadeIn(delay: Duration(milliseconds: animationDelay), duration: 400.ms)
          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
    }

    return proceedButton;
  }

  PreferredSizeWidget _buildCustomAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF86A3C), Color(0xFFF86A3C)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                  splashColor: Colors.white.withOpacity(0.1),
                  highlightColor: Colors.white.withOpacity(0.1),
                ),
                Row(
                  children: [
                    _hasAnimated
                        ? const Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 28,
                    )
                        : const Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 28,
                    ).animate(controller: _animController).slide(
                        begin: const Offset(-1, 0),
                        end: const Offset(0, 0),
                        curve: Curves.easeOutQuint),
                    const SizedBox(width: 8),
                    _hasAnimated
                        ? const Text(
                      'Food Booking',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    )
                        : const Text(
                      'Food Booking',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    )
                        .animate(controller: _animController)
                        .fadeIn(duration: 600.ms, curve: Curves.easeOutQuint)
                        .slideX(begin: -0.2, end: 0, curve: Curves.easeOutQuint),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.white),
                  onPressed: () {
                    // Favorites action
                  },
                  splashColor: Colors.white.withOpacity(0.1),
                  highlightColor: Colors.white.withOpacity(0.1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedBackground extends StatelessWidget {
  final ValueNotifier<double> scrollProgress;
  const _AnimatedBackground({required this.scrollProgress});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: scrollProgress,
      builder: (context, value, child) {
        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: const [Color(0xFFF86A3C), Color(0xFFF86A3C)],
                    stops: [0.0 - (0.2 * value), 1.0 - (0.3 * value)],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -50 + (value * 20),
              left: -20 + (value * 10),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              top: 50 - (value * 30),
              right: -80 + (value * 20),
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}