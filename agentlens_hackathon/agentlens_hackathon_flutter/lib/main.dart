import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'client.dart';
import 'screens/dashboard_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeClient();
  runApp(
    const ProviderScope(
      child: AgentLensApp(),
    ),
  );
}

class AgentLensApp extends StatelessWidget {
  const AgentLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgentLens — Collaborative AI Agent Debugging',
      debugShowCheckedModeBanner: false,
      theme: AgentLensTheme.darkTheme,
      darkTheme: AgentLensTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const DashboardScreen(),
    );
  }
}
