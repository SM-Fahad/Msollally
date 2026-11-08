import 'package:get/get.dart';
import 'package:msollaally/core/const/images_path.dart';
import 'package:msollaally/feature/furza_zone/model/fursa_zone_model.dart';

class FursaZoneController extends GetxController {
  List<FursaZoneModel> quizCompetitions = [];

  FursaZoneController() {
    fetchQuizCompetitions();
  }

  void fetchQuizCompetitions() {
    // This would typically be an API call
    quizCompetitions = [
      FursaZoneModel(
        title: 'CRDB Bank Student Quiz Competition',
        imagePath: ImagesPath.quizCompetiton,
        status: QuizStatus.completed,
        registeredUsers: 889,
        endDate: 'Final: 16th January, 2026',
        price: null,
      ),
      FursaZoneModel(
        title: 'Vodacom Digital Skills Contest',
        imagePath: ImagesPath
            .quizCompetiton, // replace with a different image if available
        status: QuizStatus.ongoing,
        registeredUsers: 1200,
        endDate: 'Ends: 28th February, 2026',
        price: 5.00,
        rightText: '',
      ),
    ];
    update();
  }
}
