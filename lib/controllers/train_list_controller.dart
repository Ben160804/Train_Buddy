import 'package:get/get.dart';
import '../models/train.dart';

class TrainListController extends GetxController {
  final trainData = Rxn<Train>();
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    try {
      final arg = Get.arguments;
      if (arg == null || arg is! Train) {
        errorMessage.value = 'No train data found. Please try searching again.';
        trainData.value = null;
      } else if (arg.data.isEmpty) {
        errorMessage.value = 'No trains found for the selected route.';
        trainData.value = arg;
      } else {
        trainData.value = arg;
        errorMessage.value = null;
      }
    } catch (e) {
      errorMessage.value = 'An error occurred while loading train data.';
      trainData.value = null;
    }
  }
}
