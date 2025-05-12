import 'package:app/access/app_review/app_review_repository.dart';
import 'package:logger/logger.dart';

import 'package:review_service/src/review_service/review_service.dart';
import 'package:review_service/src/review_service/logging_review_prompter.dart';
import 'package:review_service/src/review_service/memory_review_settings_source.dart';
import 'package:review_service/src/review_service/review_condition_builder.dart';
import 'package:review_service/src/review_service/review_conditions_builder.extensions.dart';
import 'package:review_service/src/review_service/review_settings.dart';
import 'package:review_service/src/review_service/review_prompter.dart';

abstract interface class AppReviewService {
  factory AppReviewService(
    AppReviewRepository appReviewRepository,
    Logger logger,
  ) = _AppReviewService;
  Future<void> promptForReview();
}

final class _AppReviewService implements AppReviewService {
  final AppReviewRepository _appReviewRepository;
  final Logger _logger;

  _AppReviewService(
    AppReviewRepository appReviewRepository,
    Logger logger,
  )   : _appReviewRepository = appReviewRepository,
        _logger = logger;

  Future<ReviewService<ReviewSettings>> _promptForReview() async {
    var reviewConditionsBuilder = ReviewConditionsBuilderImplementation.empty()
        .minimumPrimaryActionsCompleted(1);

    var reviewPrompter = ReviewPrompter(logger: _logger);
    var reviewSettingsSource = MemoryReviewSettingsSource<ReviewSettings>(
      () => const ReviewSettings(),
    );

    return ReviewService<ReviewSettings>(
      logger: _logger,
      reviewPrompter: reviewPrompter,
      reviewSettingsSource: reviewSettingsSource,
      reviewConditionsBuilder: reviewConditionsBuilder,
    );
  }

  @override
  Future<void> promptForReview() async {
    try {
      final lastPromptDate = await _appReviewRepository.getLastPromptDate();
      final now = DateTime.now();

      // Only prompt if more than 30 days have passed since the last prompt.
      if (lastPromptDate != null &&
          now.difference(lastPromptDate).inDays < 30) {
        return;
      }
      final promptForReview = await _promptForReview();
      var isReady = await promptForReview.getAreConditionsSatisfied();
    } catch (e) {
      // Handle any errors gracefully, e.g., log them.
      print('Error prompting for review: $e');
    }
  }
}
