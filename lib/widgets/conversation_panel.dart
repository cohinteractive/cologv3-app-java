import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../models/conversation.dart';
import '../models/exchange.dart';

class ConversationPanel extends StatefulWidget {
  final Conversation? conversation;
  const ConversationPanel({super.key, this.conversation});

  @override
  State<ConversationPanel> createState() => _ConversationPanelState();
}

class _ConversationPanelState extends State<ConversationPanel>
    with TickerProviderStateMixin {
  final Map<String, Set<int>> _expandedMap = <String, Set<int>>{};
  Set<int> _expanded = <int>{};
  final ScrollController _scrollController = ScrollController();
  final Map<int, Alignment> _alignmentMap = <int, Alignment>{};
  final Map<int, GlobalKey> _promptKeys = <int, GlobalKey>{};
  final Map<int, GlobalKey> _responseKeys = <int, GlobalKey>{};
  static const promptBg = Color(0xFF0D47A1); // dark blue
  static const responseBg = Color(0xFF424242); // dark grey

  @override
  void initState() {
    super.initState();
    final conv = widget.conversation;
    if (conv != null) {
      _expanded = _expandedMap[_keyFor(conv)] ?? <int>{};
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ConversationPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.conversation != widget.conversation) {
      final oldConv = oldWidget.conversation;
      if (oldConv != null) {
        _expandedMap[_keyFor(oldConv)] = _expanded;
      }
      final newConv = widget.conversation;
      _expanded = newConv != null
          ? (_expandedMap[_keyFor(newConv)] ?? <int>{})
          : <int>{};
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }
  }

  @override
Widget build(BuildContext context) {
  final conversation = widget.conversation;
  if (conversation == null) {
    return const Center(child: Text('No conversation selected'));
  }

  final exchanges = conversation.exchanges;
  if (exchanges.isEmpty) {
    return const Center(child: Text('No exchanges found.'));
  }

  final colorScheme = Theme.of(context).colorScheme;

  return Container(
    color: colorScheme.background,
    child: Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        addAutomaticKeepAlives: false,
        itemCount: exchanges.length,
        itemBuilder: (context, index) {
          final ex = exchanges[index];
          final expanded = _expanded.contains(index);
          final alignment = _alignmentMap[index] ?? Alignment.topCenter;
          final pKey = _promptKeys[index] ??= GlobalKey();
          final rKey = _responseKeys[index] ??= GlobalKey();
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _ExchangeTile(
              key: ValueKey('ex_$index'),
              exchange: ex,
              expanded: expanded,
              alignment: alignment,
              promptKey: pKey,
              responseKey: rKey,
              onToggle: (align, anchorKey) {
                final beforeBox =
                    anchorKey.currentContext?.findRenderObject() as RenderBox?;
                final beforeOffset = beforeBox?.localToGlobal(Offset.zero);
                setState(() {
                  if (expanded) {
                    _expanded.remove(index);
                  } else {
                    _expanded.add(index);
                    debugPrint('[Expand] Conversation: "${conversation.title}" | '
                        'Exchange #${index + 1}\n'
                        'Prompt: "${_preview(ex.prompt)}"\n'
                        'Response: "${_preview(ex.response ?? '')}"');
                  }
                  _alignmentMap[index] = align;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final afterBox =
                      anchorKey.currentContext?.findRenderObject() as RenderBox?;
                  final afterOffset = afterBox?.localToGlobal(Offset.zero);
                  if (beforeOffset != null && afterOffset != null) {
                    final delta = afterOffset.dy - beforeOffset.dy;
                    if (delta != 0) {
                      _scrollController
                          .jumpTo(_scrollController.offset + delta);
                    }
                  }
                });
              },
            ),
          );
        },
      ),
    ),
  );
}


  Widget _buildCollapsedPreview(BuildContext context, Exchange ex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: promptBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            ex.prompt,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade300,
                ),
          ),
        ),
        if (ex.response != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              margin: const EdgeInsets.only(left: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: responseBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                ex.response!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade200,
                    ),
              ),
            ),
          ),
      ],
    );
  }

  String _keyFor(Conversation conv) =>
      '${conv.title}_${conv.timestamp.millisecondsSinceEpoch}';

  String _preview(String text) =>
      text.substring(0, math.min(40, text.length));
}

class _ExchangeTile extends StatefulWidget {
  final Exchange exchange;
  final bool expanded;
  final Alignment alignment;
  final GlobalKey promptKey;
  final GlobalKey responseKey;
  final void Function(Alignment, GlobalKey) onToggle;

  const _ExchangeTile({
    super.key,
    required this.exchange,
    required this.expanded,
    required this.alignment,
    required this.promptKey,
    required this.responseKey,
    required this.onToggle,
  });

  @override
  State<_ExchangeTile> createState() => _ExchangeTileState();
}

class _ExchangeTileState extends State<_ExchangeTile>
    with TickerProviderStateMixin {
  bool? expandedFromPrompt;

  void _toggleFromPrompt() {
    setState(() {
      expandedFromPrompt = true;
    });
    widget.onToggle(Alignment.topCenter, widget.promptKey);
  }

  void _toggleFromResponse() {
    setState(() {
      expandedFromPrompt = false;
    });
    widget.onToggle(Alignment.bottomCenter, widget.responseKey);
  }

  @override
  Widget build(BuildContext context) {
    final expandPrompt = widget.expanded && (expandedFromPrompt ?? true);
    final expandResponse =
        widget.expanded && (expandedFromPrompt == false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPromptBlock(context, expandPrompt),
        if (widget.exchange.response != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: _buildResponseBlock(context, expandResponse),
          ),
      ],
    );
  }

  Widget _buildPromptBlock(BuildContext context, bool expand) {
    final lines = widget.exchange.prompt.split('\n');
    final first = lines.first;
    final rest = lines.length > 1 ? lines.sublist(1).join('\n') : '';
    return GestureDetector(
      onTap: _toggleFromPrompt,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _ConversationPanelState.promptBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              key: widget.promptKey,
              alignment: Alignment.centerLeft,
              child: Text(
                first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade300,
                    ),
              ),
            ),
            AnimatedSize(
              alignment: Alignment.topCenter,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: expand && rest.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        rest,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade300,
                            ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseBlock(BuildContext context, bool expand) {
    final lines = widget.exchange.response!.split('\n');
    final first = lines.first;
    final rest = lines.length > 1 ? lines.sublist(1).join('\n') : '';

    return GestureDetector(
      onTap: _toggleFromResponse,
      child: Container(
        margin: const EdgeInsets.only(left: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _ConversationPanelState.responseBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              key: widget.responseKey,
              alignment: Alignment.centerLeft,
              child: Text(
                first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                      color: Colors.grey.shade200,
                    ),
              ),
            ),
            AnimatedSize(
              alignment: Alignment.topCenter,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: expand && rest.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        rest,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: Colors.grey.shade200,
                            ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
