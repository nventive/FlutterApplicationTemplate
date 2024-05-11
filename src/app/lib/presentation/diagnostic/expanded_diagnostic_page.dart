import 'package:app/presentation/diagnostic/device_info_widget.dart';
import 'package:app/presentation/diagnostic/environment_diagnostic_widget.dart';
<<<<<<< Updated upstream
import 'package:app/presentation/diagnostic/logger_diagnostic_widget.dart';
=======
import 'package:app/presentation/diagnostic/mocking_diagnostic_widget.dart';
>>>>>>> Stashed changes
import 'package:app/presentation/diagnostic/navigation_diagnostic_widget.dart';
import 'package:flutter/material.dart';

/// A page in the expanded diagnosticoverlay that holds other diagnostic widgets.
final class ExpandedDiagnosticPage extends StatefulWidget {
  const ExpandedDiagnosticPage({super.key});

  @override
  State<ExpandedDiagnosticPage> createState() => _ExpandedDiagnosticPageState();
}

class _ExpandedDiagnosticPageState extends State<ExpandedDiagnosticPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  final List<Widget> expandedDiagnosticWidgets = <Widget>[
    const NavigationDiagnosticWidget(),
    const DeviceInfoWidget(),
    const EnvironmentDiagnosticWidget(),
<<<<<<< Updated upstream
    LoggerDiagnosticWidget(),
=======
    const MockingDiagnosticWidget(),
>>>>>>> Stashed changes
  ];

  int _selectedIndex = 0;

  @override
  void initState() {
    tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Column(
            children: [
              Material(
                color: const Color.fromARGB(170, 0, 0, 0),
                child: TabBar(
                  labelColor: Colors.green,
                  unselectedLabelColor: Colors.white,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: Colors.green,
                  isScrollable: true,
                  onTap: (value) => setState(
                    () {
                      _selectedIndex = value;
                    },
                  ),
<<<<<<< Updated upstream
                  tabs: const [
                    Tab(
                      text: "Navigation",
                    ),
                    Tab(
                      text: "Device Info",
                    ),
                    Tab(
                      text: "Environment",
                    ),
                    Tab(
                      text: "Logger",
                    ),
                  ],
                  controller: tabController,
                ),
=======
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
              Row(
                children: <Widget>[
                  SelectableDiagnosticButton(
                    label: 'Mocking',
                    isSelected: _selectedIndex == 3,
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 3;
                      });
                    },
                  ),
                ],
>>>>>>> Stashed changes
              ),
              expandedDiagnosticWidgets[_selectedIndex],
            ],
          ),
        ],
      ),
    );
  }
}
