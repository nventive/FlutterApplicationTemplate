import 'package:app/presentation/diagnostic/device_info_widget.dart';
import 'package:app/presentation/diagnostic/environment_diagnostic_widget.dart';
import 'package:app/presentation/diagnostic/navigation_diagnostic_widget.dart';
import 'package:app/presentation/diagnostic/selectable_diagnostic_button.dart';
import 'package:flutter/material.dart';

/// A page in the expanded diagnosticoverlay that holds other diagnostic widgets.
final class ExpandedDiagnosticPage extends StatefulWidget {
  const ExpandedDiagnosticPage({super.key});

  @override
  State<ExpandedDiagnosticPage> createState() => _ExpandedDiagnosticPageState();
}

class _ExpandedDiagnosticPageState extends State<ExpandedDiagnosticPage> {
  final List<Widget> expandedDiagnosticWidgets = <Widget>[
    const NavigationDiagnosticWidget(),
    const DeviceInfoWidget(),
    EnvironmentDiagnosticWidget(),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SelectableDiagnosticButton(
                    label: 'Navigation',
                    isSelected: _selectedIndex == 0,
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                  ),
                  SelectableDiagnosticButton(
                    label: 'Device Info',
                    isSelected: _selectedIndex == 1,
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                  ),
                  SelectableDiagnosticButton(
                    label: 'Environment',
                    isSelected: _selectedIndex == 2,
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                  ),
                ],
              ),
              expandedDiagnosticWidgets[_selectedIndex],
            ],
          ),
        ],
      ),
    );
  }
}
