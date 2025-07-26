import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../models/conversation.dart';
import '../models/exchange.dart';
import '../models/context_parcel.dart';
import '../services/llm_client.dart';
import '../debug/debug_logger.dart';
import '../src/instructions/llm_instruction_templates.dart';
import 'exchange_hover_menu.dart';

class ConversationPanel extends StatefulWidget {
  final Conversation? conversation;
  const ConversationPanel({super.key, this.conversation});

  @override
  State<ConversationPanel> createState() => _ConversationPanelState();
}

class _ConversationPanelState extends State<ConversationPanel>
    with TickerProviderStateMixin {
  final Map<String, int?> _expandedMap = <String, int?>{};
  int? _expandedIndex;
  final ScrollController _scrollController = ScrollController();
  final Map<int, Alignment> _alignmentMap = <int, Alignment>{};
  final Map<int, GlobalKey> _promptKeys = <int, GlobalKey>{};
  final Map<int, GlobalKey> _responseKeys = <int, GlobalKey>{};
  final Map<int, GlobalKey> _tileKeys = <int, GlobalKey>{};
  final GlobalKey _listKey = GlobalKey();
  static const promptBg = Color(0xFF0D47A1); // dark blue
  static const responseBg = Color(0xFF424242); // dark grey
  static const textStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
  static const double _headerHeight = 56;
  String _summaryText = '';

  @override
  void initState() {
    super.initState();
    final conv = widget.conversation;
    if (conv != null) {
      _expandedIndex = _expandedMap[_keyFor(conv)];
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
        _expandedMap[_keyFor(oldConv)] = _expandedIndex;
      }
      final newConv = widget.conversation;
      _expandedIndex = newConv != null ? _expandedMap[_keyFor(newConv)] : null;
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
      child: Column(
        children: [
          _buildHeader(conversation),
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: ListView.builder(
                key: _listKey,
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                addAutomaticKeepAlives: false,
                itemCount: exchanges.length,
                itemBuilder: (context, index) {
                  final ex = exchanges[index];
                  final expanded = index == _expandedIndex;
                  final alignment = _alignmentMap[index] ?? Alignment.topCenter;
                  final pKey = _promptKeys[index] ??= GlobalKey();
                  final rKey = _responseKeys[index] ??= GlobalKey();
                  final tKey = _tileKeys[index] ??= GlobalKey();
                  final bottom = expanded ? 16.0 : 8.0;
                  return Padding(
                    padding: EdgeInsets.only(bottom: bottom),
                    child: _ExchangeTile(
                      key: tKey,
                      index: index,
                      exchange: ex,
                      expanded: expanded,
                      alignment: alignment,
                      promptKey: pKey,
                      responseKey: rKey,
                      onToggle: (align, anchorKey) {
                        final newlyExpanded = _expandedIndex != index;
                        setState(() {
                          _expandedIndex = newlyExpanded ? index : null;
                          _alignmentMap[index] = align;
                          if (!newlyExpanded) {
                            _summaryText = '';
                          }
                        });
                        if (newlyExpanded) {
                          _loadSummary(index);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final listBox =
                                _listKey.currentContext?.findRenderObject()
                                    as RenderBox?;
                            final tileBox =
                                tKey.currentContext?.findRenderObject()
                                    as RenderBox?;
                            if (listBox != null && tileBox != null) {
                              final listTop = listBox
                                  .localToGlobal(Offset.zero)
                                  .dy;
                              final tileTop = tileBox
                                  .localToGlobal(Offset.zero)
                                  .dy;
                              final offset =
                                  _scrollController.offset +
                                  tileTop -
                                  listTop -
                                  _headerHeight;
                              final max =
                                  _scrollController.position.maxScrollExtent;
                              final target = offset.clamp(0.0, max);
                              _scrollController.animateTo(
                                target,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Conversation conversation) {
    final tsStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(fontSize: 12, color: Colors.grey.shade300);
    final summaryStyle = tsStyle?.copyWith(fontSize: 11);

    String tsText = 'Select a prompt...';
    if (_expandedIndex != null) {
      final ex = conversation.exchanges[_expandedIndex!];
      final ts = ex.promptTimestamp;
      if (ts != null) {
        tsText = DateFormat('dd HH:mm').format(ts);
      } else {
        tsText = '';
      }
    }

    final summary = _expandedIndex != null ? _summaryText : '';

    return Container(
      height: _headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade800, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 16,
            child: Row(
              children: [
                Expanded(child: Text(tsText, style: tsStyle)),
                const SizedBox(width: 40),
              ],
            ),
          ),
          Divider(height: 8, color: Colors.grey.shade800),
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                summary,
                style: summaryStyle,
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedPreview(BuildContext context, Exchange ex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 40, 12),
          decoration: BoxDecoration(
            color: promptBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            ex.prompt,
            style: _ConversationPanelState.textStyle.copyWith(
              color: Colors.grey.shade300,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        ),
        if (ex.response != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              margin: const EdgeInsets.only(left: 16),
              padding: const EdgeInsets.fromLTRB(12, 12, 40, 12),
              decoration: BoxDecoration(
                color: responseBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                ex.response!,
                style: _ConversationPanelState.textStyle.copyWith(
                  color: Colors.grey.shade200,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
          ),
      ],
    );
  }

  String _keyFor(Conversation conv) =>
      '${conv.title}_${conv.timestamp.millisecondsSinceEpoch}';

  String _preview(String text) => text.substring(0, math.min(40, text.length));

  void updateSummary(String text) {
    setState(() => _summaryText = text);
  }

  void _loadSummary(int index) {
    updateSummary('Summary loading…');
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted || _expandedIndex != index) return;
      updateSummary('Prompt asks about scroll behavior and metadata pinning');
    });
  }
}

class _ExchangeTile extends StatefulWidget {
  final Exchange exchange;
  final int index;
  final bool expanded;
  final Alignment alignment;
  final GlobalKey promptKey;
  final GlobalKey responseKey;
  final void Function(Alignment, GlobalKey) onToggle;

  const _ExchangeTile({
    super.key,
    required this.exchange,
    required this.index,
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
  bool _hoverPrompt = false;
  bool _hoverResponse = false;
  bool _loading = false;
  String? _error;

  void _toggleFromPrompt() {
    widget.onToggle(Alignment.topCenter, widget.promptKey);
  }

  void _toggleFromResponse() {
    widget.onToggle(Alignment.bottomCenter, widget.responseKey);
  }

  Future<void> _summarize() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final prompt = initialExchangePromptTemplate
        .replaceAll('{{prompt}}', widget.exchange.prompt.trim())
        .replaceAll('{{response}}', widget.exchange.response?.trim() ?? '');
    try {
      final resp = await LLMClient.sendPrompt(prompt);
      DebugLogger.logLLMCallRaw(
        prompt: prompt,
        rawResponse: jsonEncode(resp),
      );
      final choices = resp['choices'];
      if (choices == null || choices.isEmpty) {
        throw Exception('No choices returned');
      }
      final content = choices.first['message']?['content'] as String?;
      if (content == null || content.trim().isEmpty) {
        throw Exception('LLM response content is empty');
      }
      final Map<String, dynamic> json = jsonDecode(content);
      final parcel = ContextParcel.fromJson(json);
      setState(() {
        widget.exchange.llmSummary = parcel.summary;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final expandPrompt = widget.expanded;
    final expandResponse = widget.expanded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPromptBlock(context, expandPrompt),
        if (widget.exchange.response != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: _buildResponseBlock(context, expandResponse),
          ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('Summarizing...', style: TextStyle(color: Colors.amber)),
          )
        else if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          )
        else if (widget.exchange.llmSummary != null &&
            widget.exchange.llmSummary!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Card(
              color: Colors.black54,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.exchange.llmSummary!,
                        style: _ConversationPanelState.textStyle,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        setState(() => widget.exchange.llmSummary = null);
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPromptBlock(BuildContext context, bool expand) {
    final lines = widget.exchange.prompt.split('\n');
    final first = lines.first;
    final rest = lines.length > 1 ? lines.sublist(1).join('\n') : '';
    return MouseRegion(
      onEnter: (_) => setState(() => _hoverPrompt = true),
      onExit: (_) => setState(() => _hoverPrompt = false),
      child: GestureDetector(
        onTap: _toggleFromPrompt,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(
                expand ? 12 : 8,
                expand ? 12 : 8,
                expand ? 40 : 36,
                expand ? 12 : 8,
              ),
              decoration: BoxDecoration(
                color: _ConversationPanelState.promptBg
                    .withOpacity(expand ? 1.0 : 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    margin: const EdgeInsets.only(right: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '#${widget.index + 1}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          key: widget.promptKey,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            first,
                            style: _ConversationPanelState.textStyle.copyWith(
                              color: expand
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade400,
                            ),
                            maxLines: expand ? null : 1,
                            overflow: expand
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                            softWrap: expand,
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
                                    style: _ConversationPanelState.textStyle
                                        .copyWith(color: Colors.grey.shade300),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _hoverPrompt ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: ExchangeHoverMenu(
                  exchange: widget.exchange,
                  onSummarizeRequested: (_) => _summarize(),
                ),
              ),
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

    return MouseRegion(
      onEnter: (_) => setState(() => _hoverResponse = true),
      onExit: (_) => setState(() => _hoverResponse = false),
      child: GestureDetector(
        onTap: _toggleFromResponse,
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(left: expand ? 16 : 12),
              padding: EdgeInsets.fromLTRB(
                expand ? 12 : 8,
                expand ? 12 : 8,
                expand ? 40 : 36,
                expand ? 12 : 8,
              ),
              decoration: BoxDecoration(
                color: _ConversationPanelState.responseBg
                    .withOpacity(expand ? 1.0 : 0.6),
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
                      style: _ConversationPanelState.textStyle.copyWith(
                        color: expand
                            ? Colors.grey.shade200
                            : Colors.grey.shade400,
                      ),
                      maxLines: expand ? null : 1,
                      overflow: expand
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      softWrap: expand,
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
                              style: _ConversationPanelState.textStyle.copyWith(
                                color: Colors.grey.shade200,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _hoverResponse ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: ExchangeHoverMenu(
                  exchange: widget.exchange,
                  onSummarizeRequested: (_) => _summarize(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
