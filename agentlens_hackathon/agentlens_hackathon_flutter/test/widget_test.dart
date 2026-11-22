import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agentlens_hackathon/screens/dashboard_screen.dart';
import 'package:agentlens_hackathon/theme.dart';

void main() {
  testWidgets('DashboardScreen renders hero banner and action cards', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AgentLensTheme.darkTheme,
          home: const DashboardScreen(),
        ),
      ),
    );

    // Verify HackBriven Track 1 banner
    expect(find.textContaining('HackBriven Track 1'), findsOneWidget);

    // Verify Title and Subtitle
    expect(find.textContaining('Agent'), findsWidgets);
    expect(find.textContaining('Lens'), findsWidgets);
    expect(find.textContaining('Live War Room'), findsOneWidget);

    // Verify Action cards
    expect(find.text('Host New Debug Room'), findsOneWidget);
    expect(find.text('Join Collaborative Session'), findsOneWidget);
    expect(find.text('Create Room'), findsOneWidget);
    expect(find.text('Join Room Stream'), findsOneWidget);

    // Verify Feature pills
    expect(find.text('Serverpod 4.1.2 Typed Streams'), findsOneWidget);
    expect(find.text('Automatic Secret Redaction'), findsOneWidget);
    expect(find.text('5 Deterministic Failure Rules'), findsOneWidget);
  });
}
