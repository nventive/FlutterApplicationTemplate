import 'package:flutter/material.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'dart:developer' as developer;

/// Page to display Firebase App Check status and token information.
/// This is useful for verifying App Check configuration during development.
final class AppCheckStatusPage extends StatefulWidget {
  const AppCheckStatusPage({super.key});

  @override
  State<AppCheckStatusPage> createState() => _AppCheckStatusPageState();
}

class _AppCheckStatusPageState extends State<AppCheckStatusPage> {
  String _status = "Initializing App Check...";
  String? _token;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAppCheck();
  }

  Future<void> _initializeAppCheck() async {
    setState(() {
      _isLoading = true;
      _status = "Fetching App Check token...";
    });

    try {
      // Try to get the token
      final token = await FirebaseAppCheck.instance.getToken();

      developer.log('=== APP CHECK TOKEN FETCH ===');
      developer.log('Token: ${token ?? "null"}');
      developer.log('============================');

      if (token == null) {
        setState(() {
          _status = "❌ No token received\n\n"
              "App Check may not be properly configured.\n\n"
              "Debug Steps:\n"
              "1. Check logcat/console for debug token\n"
              "2. Register token in Firebase Console\n"
              "3. Enable App Check for your app";
          _token = null;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _status = "✅ App Check is working!\n\n"
            "Token received successfully.\n"
            "App Check tokens are automatically attached to all Firebase requests.";
        _token = token;
        _isLoading = false;
      });
    } catch (e) {
      developer.log('=== APP CHECK TOKEN ERROR ===');
      developer.log('Error: $e');
      developer.log('Check Android logcat for "Firebase App Check debug token"');
      developer.log('Register at: Firebase Console > App Check');
      developer.log('============================');

      setState(() {
        _status = "❌ Error getting App Check token\n\n"
            "${e.toString()}\n\n"
            "If using debug provider:\n"
            "1. Check logcat for debug token message\n"
            "2. Register token in Firebase Console > App Check > Manage debug tokens\n"
            "3. Restart the app";
        _token = null;
        _isLoading = false;
      });
    }

    // Listen for token changes
    FirebaseAppCheck.instance.onTokenChange.listen((token) {
      developer.log('=== APP CHECK TOKEN CHANGED ===');
      developer.log('New Token: $token');
      developer.log('===============================');

      if (mounted) {
        setState(() {
          _token = token;
          _status = "✅ App Check token refreshed\n\n"
              "Token updated at ${DateTime.now().toLocal()}";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase App Check Status"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Status",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        Text(
                          _status,
                          style: const TextStyle(fontSize: 14),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Token Card (if available)
              if (_token != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Token Preview",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: SelectableText(
                            _token!.length > 150
                                ? '${_token!.substring(0, 150)}...'
                                : _token!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Token length: ${_token!.length} characters',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Full token logged to console',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "About App Check",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Firebase App Check protects your backend resources from abuse. "
                        "When configured, tokens are automatically attached to all Firebase requests.",
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Current Configuration:",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "• Provider: Debug (for development)\n"
                        "• Platform: Android\n"
                        "• Auto-refresh: Enabled",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _initializeAppCheck,
        icon: const Icon(Icons.refresh),
        label: const Text("Refresh Token"),
      ),
    );
  }
}
