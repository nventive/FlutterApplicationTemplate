import 'package:app/presentation/diagnostic/bugsee_configuration_widget.dart';
import 'package:app/presentation/diagnostic/device_info_widget.dart';
import 'package:app/presentation/diagnostic/environment_diagnostic_widget.dart';
import 'package:app/presentation/diagnostic/logger_diagnostic_widget.dart';
import 'package:app/presentation/diagnostic/mocking_diagnostic_widget.dart';
import 'package:app/presentation/diagnostic/navigation_diagnostic_widget.dart';
import 'package:flutter/material.dart';

/// A page in the expanded diagnosticoverlay that holds other diagnostic widgets.
final class ExpandedDiagnosticPage extends StatefulWidget {
  const ExpandedDiagnosticPage({super.key});

  @override
  State<ExpandedDiagnosticPage> createState() => _ExpandedDiagnosticPageState();
}

final class _ExpandedDiagnosticPageState extends State<ExpandedDiagnosticPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Widget> expandedDiagnosticWidgets = <Widget>[
    const NavigationDiagnosticWidget(),
    const DeviceInfoWidget(),
    EnvironmentDiagnosticWidget(),
    LoggerDiagnosticWidget(),
    const MockingDiagnosticWidget(),
    const BugseeConfigurationWidget(),
  ];

  int _selectedIndex = 0;

  @override
  void initState() {
    _tabController =
        TabController(length: expandedDiagnosticWidgets.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                    Tab(
                      text: "Mocking",
                    ),
                    Tab(
                      text: "Bugsee",
                    ),
                  ],
                  controller: _tabController,
                ),
              ),
              expandedDiagnosticWidgets[_selectedIndex],
            ],
          ),
        ],
      ),
    );
  }
}
