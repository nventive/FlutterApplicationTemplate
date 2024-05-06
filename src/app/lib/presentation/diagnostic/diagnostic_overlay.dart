import 'dart:async';

import 'package:app/business/diagnostics/diagnostics_service.dart';
import 'package:app/presentation/diagnostic/diagnostic_button.dart';
import 'package:app/presentation/diagnostic/expanded_diagnostic_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// A diagnostic overlay that can be used to display diagnostic information.
final class DiagnosticOverlay extends StatefulWidget {
  const DiagnosticOverlay({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DiagnosticOverlay();
  }
}

final class _DiagnosticOverlay extends State<DiagnosticOverlay> {
  final _diagnosticService = GetIt.instance.get<DiagnosticsService>();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final dismissed = await _diagnosticService.checkDiagnosticDismissal();
    if (!dismissed) {
      setState(() {
        _showOverlay = true;
      });
    }
  }

  bool _showOverlay = false;
  bool _isRight = true;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (!_showOverlay) {
      return Container();
    }

    return Positioned(
      right: _expanded || _isRight ? 0 : null,
      left: _expanded || !_isRight ? 0 : null,
      bottom: _expanded ? 0 : null,
      top: 150,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(170, 0, 0, 0),
          border: Border.all(
            color: Colors.black,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: _expanded ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_expanded) const ExpandedDiagnosticPage(),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DiagnosticButton(label: 'Move', onPressed: _moveOverlay),
                  DiagnosticButton(
                    label: _expanded ? 'Minimize' : 'Expand',
                    onPressed: _expandOverlay,
                  ),
                  DiagnosticButton(label: 'X', onPressed: _closeOverlay),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _closeOverlay() async {
    setState(() {
      _showOverlay = false;
    });
    await _diagnosticService.dismissDiagnostics();
  }

  void _moveOverlay() {
    setState(() {
      _isRight = !_isRight;
    });
  }

  void _expandOverlay() {
    setState(() {
      _expanded = !_expanded;
    });
  }
}
