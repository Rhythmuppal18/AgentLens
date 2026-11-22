import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:agentlens_hackathon_client/agentlens_hackathon_client.dart';
import '../providers/room_state.dart';
import '../theme.dart';
import '../widgets/evidence_sheet.dart';

class DebugRoomScreen extends ConsumerStatefulWidget {
  const DebugRoomScreen({super.key});

  @override
  ConsumerState<DebugRoomScreen> createState() => _DebugRoomScreenState();
}

class _DebugRoomScreenState extends ConsumerState<DebugRoomScreen> {
  final _noteController = TextEditingController();
  final _noteScrollController = ScrollController();
  final Set<String> _expandedTraces = {};

  @override
  void dispose() {
    _noteController.dispose();
    _noteScrollController.dispose();
    super.dispose();
  }

  void _postNote() {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;
    if (text.length > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note cannot exceed 1000 characters')),
      );
      return;
    }

    ref.read(roomProvider.notifier).addNote(text);
    _noteController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_noteScrollController.hasClients) {
        _noteScrollController.animateTo(
          _noteScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showQrCodeDialog(String roomCode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AgentLensTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Room QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: QrImageView(
                data: 'agentlens://room/$roomCode',
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Room Code: $roomCode',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AgentLensTheme.primary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roomProvider);
    final room = state.room;

    if (room == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No active room session.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            const Icon(Icons.hub_rounded, color: AgentLensTheme.primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(room.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Text(
                        'ROOM: ${room.roomCode}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AgentLensTheme.primary, letterSpacing: 0.5),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: room.roomCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Room code copied')),
                          );
                        },
                        child: const Icon(Icons.copy_rounded, size: 13, color: AgentLensTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Sequence sync badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AgentLensTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AgentLensTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: state.isConnected ? AgentLensTheme.success : AgentLensTheme.warning,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'SEQ #${state.lastSequenceNumber}',
                  style: AgentLensTheme.monoTextStyle.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // QR Code button
          IconButton(
            icon: const Icon(Icons.qr_code_rounded, size: 20),
            tooltip: 'Show QR Code',
            onPressed: () => _showQrCodeDialog(room.roomCode),
          ),

          // Diagnostic Simulation Menu Button
          PopupMenuButton<String>(
            tooltip: 'Trigger Diagnostic Simulation',
            icon: const Icon(Icons.bug_report_rounded, color: AgentLensTheme.warning),
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                enabled: false,
                child: Text(
                  '[SAMPLE DIAGNOSTIC TELEMETRY]',
                  style: TextStyle(color: AgentLensTheme.warning, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'SEARCH_TIMEOUT_AND_FAILED_SPAN',
                child: Text('WebSearch Gateway Timeout (Failed & Slow Span)'),
              ),
              const PopupMenuItem(
                value: 'LOOPING_SQL_AGENT',
                child: Text('Looping SQL Agent (Repeated Tool Calls & Retries)'),
              ),
              const PopupMenuItem(
                value: 'EMPTY_DOC_SUMMARIZER',
                child: Text('Empty Doc Summarizer (Empty Tool Result)'),
              ),
            ],
            onSelected: (val) {
              ref.read(roomProvider.notifier).simulateScenario(val);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Triggered diagnostic simulation scenario: $val')),
              );
            },
          ),

          // Leave Room button
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AgentLensTheme.error, size: 20),
            tooltip: 'Leave Room',
            onPressed: () async {
              await ref.read(roomProvider.notifier).leaveRoom();
              if (context.mounted) Navigator.pop(context);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Live Collaborator Presence Strip
          _buildPresenceStrip(state.participants, state.currentParticipant),

          // Main Dual-Pane Body
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                if (isWide) {
                  return Row(
                    children: [
                      // Left Pane: Traces & Spans Timeline (55%)
                      Expanded(
                        flex: 11,
                        child: _buildTracesPane(state.traces, state.spans),
                      ),
                      const VerticalDivider(width: 1, color: AgentLensTheme.border),
                      // Right Pane: Failure Findings & Shared Notes (45%)
                      Expanded(
                        flex: 9,
                        child: _buildRightPane(state.findings, state.notes),
                      ),
                    ],
                  );
                } else {
                  // Tabbed layout on small screens
                  return DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(icon: Icon(Icons.account_tree_outlined), text: 'Traces & Spans'),
                            Tab(icon: Icon(Icons.warning_amber_rounded), text: 'Findings & Chat'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildTracesPane(state.traces, state.spans),
                              _buildRightPane(state.findings, state.notes),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomSheet: (state.selectedFinding != null || state.selectedSpan != null)
          ? EvidenceSheet(
              finding: state.selectedFinding,
              span: state.selectedSpan,
              onClose: () {
                ref.read(roomProvider.notifier).selectFinding(null);
                ref.read(roomProvider.notifier).selectSpan(null);
              },
            )
          : null,
    );
  }

  Widget _buildPresenceStrip(
    List<RoomParticipant> participants,
    RoomParticipant? current,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AgentLensTheme.surface,
        border: Border(bottom: BorderSide(color: AgentLensTheme.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.people_outline_rounded, size: 16, color: AgentLensTheme.textSecondary),
          const SizedBox(width: 8),
          const Text('COLLABORATORS:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AgentLensTheme.textMuted)),
          const SizedBox(width: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: participants.map((p) {
                  final isYou = p.deviceId == current?.deviceId;
                  final isOnline = p.isOnline;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isYou ? AgentLensTheme.primary.withValues(alpha: 0.18) : AgentLensTheme.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isYou ? AgentLensTheme.primary.withValues(alpha: 0.5) : AgentLensTheme.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: isOnline ? AgentLensTheme.success : AgentLensTheme.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          p.participantName + (isYou ? ' (You)' : ''),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isYou ? FontWeight.bold : FontWeight.normal,
                            color: isOnline ? AgentLensTheme.textPrimary : AgentLensTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTracesPane(List<RoomTrace> traces, List<RoomSpan> spans) {
    if (traces.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sensors_off_rounded, size: 48, color: AgentLensTheme.textMuted),
            const SizedBox(height: 12),
            const Text('Awaiting Agent Telemetry Traces...', style: TextStyle(color: AgentLensTheme.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Simulate Test Trace'),
              onPressed: () {
                ref.read(roomProvider.notifier).simulateScenario('SEARCH_TIMEOUT_AND_FAILED_SPAN');
              },
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: traces.length,
      itemBuilder: (ctx, i) {
        final trace = traces[i];
        final traceSpans = spans.where((s) => s.traceId == trace.traceId).toList();
        final isExpanded = _expandedTraces.contains(trace.traceId);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: trace.status == 'error' ? AgentLensTheme.error.withValues(alpha: 0.15) : AgentLensTheme.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    trace.status == 'error' ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                    color: trace.status == 'error' ? AgentLensTheme.error : AgentLensTheme.success,
                    size: 20,
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        trace.agentName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    if (trace.isSample)
                      const Chip(
                        label: Text('SAMPLE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AgentLensTheme.warning)),
                        backgroundColor: Color(0x22F59E0B),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                subtitle: Text(
                  'Trace: ${trace.traceId} • ${trace.durationMs}ms • ${trace.totalTokens} tokens • ${traceSpans.length} spans',
                  style: const TextStyle(fontSize: 12, color: AgentLensTheme.textSecondary),
                ),
                trailing: IconButton(
                  icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedTraces.remove(trace.traceId);
                      } else {
                        _expandedTraces.add(trace.traceId);
                      }
                    });
                  },
                ),
              ),
              if (isExpanded) ...[
                const Divider(height: 1, color: AgentLensTheme.border),
                Container(
                  color: AgentLensTheme.background.withValues(alpha: 0.4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: traceSpans.map((span) => _buildSpanRow(span)).toList(),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpanRow(RoomSpan span) {
    final isError = span.status == 'error' || span.errorMessage != null;
    return InkWell(
      onTap: () {
        ref.read(roomProvider.notifier).selectSpan(span);
        ref.read(roomProvider.notifier).selectFinding(null);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AgentLensTheme.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AgentLensTheme.border),
              ),
              child: Text(
                span.spanType.toUpperCase(),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AgentLensTheme.textMuted),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                span.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isError ? AgentLensTheme.error : AgentLensTheme.textPrimary,
                ),
              ),
            ),
            Text(
              '${span.durationMs} ms',
              style: AgentLensTheme.monoTextStyle.copyWith(
                fontSize: 11,
                color: span.durationMs > 4000 ? AgentLensTheme.warning : AgentLensTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, size: 16, color: AgentLensTheme.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildRightPane(List<RoomFinding> findings, List<InvestigationNote> notes) {
    return Column(
      children: [
        // Top: Failure Alerts (45% height)
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AgentLensTheme.border)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.crisis_alert_rounded, size: 18, color: AgentLensTheme.error),
                    const SizedBox(width: 8),
                    const Text('FAILURE ALERTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: findings.isNotEmpty ? AgentLensTheme.error.withValues(alpha: 0.15) : AgentLensTheme.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${findings.length} DETECTED',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: findings.isNotEmpty ? AgentLensTheme.error : AgentLensTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: findings.isEmpty
                    ? const Center(
                        child: Text(
                          'No failure anomalies detected yet.',
                          style: TextStyle(color: AgentLensTheme.textMuted, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: findings.length,
                        itemBuilder: (ctx, i) {
                          final f = findings[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AgentLensTheme.error.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          f.severity,
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AgentLensTheme.error),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        f.ruleType,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      TextButton(
                                        style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                        onPressed: () {
                                          ref.read(roomProvider.notifier).selectFinding(f);
                                          ref.read(roomProvider.notifier).selectSpan(null);
                                        },
                                        child: const Text('Inspect Evidence', style: TextStyle(fontSize: 11)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    f.summary,
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),

        const Divider(height: 1, color: AgentLensTheme.border),

        // Bottom: Collaborative Investigation Notes (55% height)
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AgentLensTheme.border)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.forum_outlined, size: 18, color: AgentLensTheme.info),
                    SizedBox(width: 8),
                    Text('SHARED INVESTIGATION THREAD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                  ],
                ),
              ),
              Expanded(
                child: notes.isEmpty
                    ? const Center(
                        child: Text(
                          'No collaborative notes posted yet.\nShare hypotheses, observations, and findings with your team.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AgentLensTheme.textMuted, fontSize: 12.5, height: 1.4),
                        ),
                      )
                    : ListView.builder(
                        controller: _noteScrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: notes.length,
                        itemBuilder: (ctx, i) {
                          final n = notes[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AgentLensTheme.card,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AgentLensTheme.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      n.authorName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AgentLensTheme.primary),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${n.createdAt.hour.toString().padLeft(2, '0')}:${n.createdAt.minute.toString().padLeft(2, '0')}:${n.createdAt.second.toString().padLeft(2, '0')}',
                                      style: const TextStyle(fontSize: 10, color: AgentLensTheme.textMuted),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                SelectableText(
                                  n.content,
                                  style: const TextStyle(fontSize: 13, height: 1.3),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              // Note Input Bar
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AgentLensTheme.surface,
                  border: Border(top: BorderSide(color: AgentLensTheme.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _noteController,
                        maxLines: null,
                        maxLength: 1000,
                        buildCounter: (ctx, {required currentLength, required isFocused, maxLength}) => null,
                        decoration: const InputDecoration(
                          hintText: 'Share debugging note or hypothesis (1000 chars max)...',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        onSubmitted: (_) => _postNote(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: AgentLensTheme.primary),
                      tooltip: 'Post Note',
                      onPressed: _postNote,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
