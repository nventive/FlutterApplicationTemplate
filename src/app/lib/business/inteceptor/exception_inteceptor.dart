import 'package:app/business/bugsee/bugsee_manager.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

abstract interface class ExceptionInteceptor {
  factory ExceptionInteceptor({
    required BugseeManager bugseeManager,
    required Logger logger,
  }) = _ExceptionInteceptor;

  /// Intecepts exceptions, logs them and sends them to Bugsee.
  void inteceptException(Object exception, StackTrace stackTrace);

  /// Intecepts rendering exceptions, logs them and sends them to Bugsee.
  Future<void> inteceptRenderingExceptions(FlutterErrorDetails error);
}

final class _ExceptionInteceptor implements ExceptionInteceptor {
  final BugseeManager bugseeManager;
  final Logger logger;

  _ExceptionInteceptor({
    required this.bugseeManager,
    required this.logger,
  });

  @override
  void inteceptException(Object exception, StackTrace stackTrace) {
    logger.e(
      exception,
      stackTrace: stackTrace,
    );
    bugseeManager.inteceptExceptions(exception, stackTrace);
  }

  @override
  Future<void> inteceptRenderingExceptions(FlutterErrorDetails error) async {
    logger.e(
      error,
    );
    bugseeManager.inteceptRenderingExceptions(error);
  }
}
