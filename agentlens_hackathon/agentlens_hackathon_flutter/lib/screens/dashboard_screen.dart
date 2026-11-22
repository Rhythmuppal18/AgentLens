import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/room_state.dart';
import '../theme.dart';
import 'debug_room_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _joinCodeController = TextEditingController();
  final _joinNameController = TextEditingController();

  final _createRoomNameController = TextEditingController(text: 'Customer Checkout Agent Debug');
  final _createCreatorNameController = TextEditingController(text: 'Alice (Lead SRE)');

  @override
  void dispose() {
    _joinCodeController.dispose();
    _joinNameController.dispose();
    _createRoomNameController.dispose();
    _createCreatorNameController.dispose();
    super.dispose();
  }

  void _showCreateRoomDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AgentLensTheme.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AgentLensTheme.border),
        ),
        title: const Row(
          children: [
            Icon(Icons.add_circle_outline_rounded, color: AgentLensTheme.primary),
            SizedBox(width: 10),
            Text('Create Debug War Room'),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Room Name / Incident Title', style: TextStyle(fontSize: 13, color: AgentLensTheme.textSecondary)),
              const SizedBox(height: 6),
              TextField(
                controller: _createRoomNameController,
                decoration: const InputDecoration(
                  hintText: 'e.g. LLM Order Router Failure',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Your Handle / Engineer Name', style: TextStyle(fontSize: 13, color: AgentLensTheme.textSecondary)),
              const SizedBox(height: 6),
              TextField(
                controller: _createCreatorNameController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Alice (Lead SRE)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AgentLensTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _handleCreateRoom();
            },
            child: const Text('Create & Generate Credentials'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreateRoom() async {
    try {
      await ref.read(roomProvider.notifier).createRoom(
        roomName: _createRoomNameController.text.trim(),
        creatorName: _createCreatorNameController.text.trim(),
      );

      final state = ref.read(roomProvider);
      if (state.room != null && state.ingestToken != null) {
        if (!mounted) return;
        _showIngestCredentialDialog(
          roomCode: state.room!.roomCode,
          ingestToken: state.ingestToken!,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AgentLensTheme.error, content: Text('Error creating room: $e')),
      );
    }
  }

  void _showIngestCredentialDialog({
    required String roomCode,
    required String ingestToken,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AgentLensTheme.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AgentLensTheme.border),
        ),
        title: const Row(
          children: [
            Icon(Icons.vpn_key_rounded, color: AgentLensTheme.warning),
            SizedBox(width: 10),
            Text('Room Credentials & Ingest Key'),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warning Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AgentLensTheme.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AgentLensTheme.warning.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AgentLensTheme.warning, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'SECURITY NOTICE: Copy the ingestion token below now! For security, only its cryptographic SHA-256 hash is stored on the server. This token will NEVER be shown again.',
                          style: TextStyle(color: AgentLensTheme.warning, fontSize: 12, height: 1.4, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Room Code & QR
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: QrImageView(
                        data: 'agentlens://room/$roomCode',
                        version: QrVersions.auto,
                        size: 90.0,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ROOM CODE (FOR COLLABORATORS):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AgentLensTheme.textMuted)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                roomCode,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2, color: AgentLensTheme.primary),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy_rounded, size: 18),
                                tooltip: 'Copy Room Code',
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: roomCode));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Room Code copied to clipboard')),
                                  );
                                },
                              ),
                            ],
                          ),
                          const Text('Share this code with teammates to debug simultaneously.', style: TextStyle(fontSize: 12, color: AgentLensTheme.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Ingest Token Box
                const Text('SECRET INGESTION CREDENTIAL (FOR AGENT SDK):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AgentLensTheme.textMuted)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AgentLensTheme.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AgentLensTheme.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          ingestToken,
                          style: AgentLensTheme.monoTextStyle.copyWith(color: AgentLensTheme.success, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 16, color: AgentLensTheme.textSecondary),
                        tooltip: 'Copy Ingest Token',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: ingestToken));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Secret Ingest Token copied to clipboard')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Set this as AGENTLENS_INGEST_TOKEN in your AI agent framework or Python SDK to stream telemetry.',
                  style: TextStyle(fontSize: 11.5, color: AgentLensTheme.textSecondary.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.login_rounded, size: 18),
            label: const Text('Enter War Room'),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DebugRoomScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleJoinRoom() async {
    final code = _joinCodeController.text.trim().toUpperCase();
    final name = _joinNameController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 7-character room code (e.g. AL-XXXX)')),
      );
      return;
    }

    try {
      await ref.read(roomProvider.notifier).joinRoom(
        roomCode: code,
        participantName: name.isEmpty ? 'Collaborator' : name,
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DebugRoomScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AgentLensTheme.error, content: Text('Could not join room: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roomProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Hackathon Track Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AgentLensTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AgentLensTheme.primary.withValues(alpha: 0.4)),
                    ),
                    child: const Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(Icons.hub_rounded, size: 16, color: AgentLensTheme.primary),
                        SizedBox(width: 8),
                        Text(
                          'HackBriven Track 1: Here, Together — Multi-Engineer AI Debugging',
                          style: TextStyle(
                            color: AgentLensTheme.primary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Hero Title
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                      children: [
                        const TextSpan(text: 'Agent', style: TextStyle(color: Colors.white)),
                        const TextSpan(text: 'Lens', style: TextStyle(color: AgentLensTheme.primary)),
                        const TextSpan(text: ' Live War Room', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Real-time collaborative AI agent observability, failure detection and incident investigation.\nBuilt with Serverpod 4.1.2 typed streaming, PostgreSQL, and Flutter.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: AgentLensTheme.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 36),

                  if (state.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    )
                  else
                    // Dual Cards Grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 640;
                        return Flex(
                          direction: isWide ? Axis.horizontal : Axis.vertical,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card 1: Create Room
                            Expanded(
                              flex: isWide ? 1 : 0,
                              child: _buildActionCard(
                                title: 'Host New Debug Room',
                                description: 'Create an incident war room, generate a unique room code, and receive your secret agent telemetry ingestion credential.',
                                buttonLabel: 'Create Room',
                                icon: Icons.sensors_rounded,
                                isPrimary: true,
                                onTap: _showCreateRoomDialog,
                              ),
                            ),
                            if (isWide) const SizedBox(width: 24) else const SizedBox(height: 20),

                            // Card 2: Join Existing Room
                            Expanded(
                              flex: isWide ? 1 : 0,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.group_add_rounded, color: AgentLensTheme.info, size: 28),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Text('Join Collaborative Session', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Enter an active room code or scan a QR code to jump into a live debugging stream with your team.',
                                        style: TextStyle(fontSize: 13, color: AgentLensTheme.textSecondary, height: 1.4),
                                      ),
                                      const SizedBox(height: 16),
                                      TextField(
                                        controller: _joinCodeController,
                                        textCapitalization: TextCapitalization.characters,
                                        decoration: const InputDecoration(
                                          hintText: 'Room Code (e.g. AL-XXXX)',
                                          prefixIcon: Icon(Icons.tag_rounded, size: 20),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      TextField(
                                        controller: _joinNameController,
                                        decoration: const InputDecoration(
                                          hintText: 'Your Name (e.g. Bob DevOps)',
                                          prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AgentLensTheme.cardHover,
                                            foregroundColor: AgentLensTheme.textPrimary,
                                            side: const BorderSide(color: AgentLensTheme.border),
                                          ),
                                          onPressed: _handleJoinRoom,
                                          child: const Text('Join Room Stream'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                  const SizedBox(height: 48),

                  // Feature pills footer
                  Wrap(
                    spacing: 16,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildFeaturePill(Icons.bolt_rounded, 'Serverpod 4.1.2 Typed Streams'),
                      _buildFeaturePill(Icons.shield_outlined, 'Automatic Secret Redaction'),
                      _buildFeaturePill(Icons.policy_outlined, '5 Deterministic Failure Rules'),
                      _buildFeaturePill(Icons.sync_rounded, 'Snapshot + Monotonic Sequence Sync'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required String buttonLabel,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: isPrimary ? AgentLensTheme.primary : AgentLensTheme.info, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(description, style: const TextStyle(fontSize: 13, color: AgentLensTheme.textSecondary, height: 1.4)),
            const SizedBox(height: 38),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                child: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AgentLensTheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AgentLensTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AgentLensTheme.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: AgentLensTheme.textSecondary)),
        ],
      ),
    );
  }
}
