import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'models/conversation.dart';
import 'services/json_loader.dart';
import 'widgets/conversation_list.dart';
import 'widgets/conversation_panel.dart';
import 'widgets/menu_bar.dart';
import 'widgets/error_panel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    _maximizeWindow();
  }
  runApp(const CologApp());
}

void _maximizeWindow() {
  final user32 = DynamicLibrary.open('user32.dll');
  final getForegroundWindow = user32.lookupFunction<IntPtr Function(), int Function()>('GetForegroundWindow');
  final showWindow = user32.lookupFunction<Int32 Function(IntPtr, Int32), int Function(int, int)>('ShowWindow');
  const swMaximize = 3;
  final hwnd = getForegroundWindow();
  showWindow(hwnd, swMaximize);
}

class CologApp extends StatelessWidget {
  const CologApp({super.key});

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF0B1E2D);
    return MaterialApp(
      title: '',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1E88E5),
          background: darkBlue,
        ),
        scaffoldBackgroundColor: darkBlue,
        scrollbarTheme: ScrollbarThemeData(
          thumbVisibility: MaterialStateProperty.all(true),
          trackVisibility: MaterialStateProperty.all(true),
          radius: const Radius.circular(4),
          thickness: MaterialStateProperty.all(8),
          thumbColor: MaterialStateProperty.all(Colors.grey),
          trackColor: MaterialStateProperty.all(Colors.black54),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Conversation>? _conversations;
  Conversation? _selectedConversation;
  bool _loading = false;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _currentFilePath;
  late DateTime _currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _timer?.cancel();
    super.dispose();
  }
  Future<void> _openJsonFile() async {
    final prefs = await SharedPreferences.getInstance();
    final initialDir = prefs.getString('last_dir');
    const typeGroup = XTypeGroup(label: 'json', extensions: ['json']);
    final file = await openFile(
      initialDirectory: initialDir,
      acceptedTypeGroups: [typeGroup],
    );
    if (file != null) {
      prefs.setString('last_dir', File(file.path).parent.path);
      setState(() {
        _loading = true;
        _error = null;
      });
      try {
        final convs = await JsonLoader.loadConversations(file.path);
        convs.sort((a, b) {
          DateTime getLast(Conversation c) {
            DateTime? ts;
            for (final ex in c.exchanges) {
              ts = ex.responseTimestamp ?? ex.promptTimestamp ?? ts;
            }
            return ts ?? c.timestamp;
          }

          return getLast(b).compareTo(getLast(a));
        });
        setState(() {
          _conversations = convs;
          _selectedConversation = null;
          _loading = false;
          _currentFilePath = file.path;
        });
      } on JsonLoadException catch (e) {
        setState(() {
          _conversations = null;
          _error = e.message;
          _loading = false;
          _currentFilePath = null;
        });
      }
    }
  }

  void _exitApp() {
    exit(0);
  }

  List<Conversation> _filteredConversations() {
    if (_conversations == null || _searchQuery.isEmpty) {
      return _conversations ?? <Conversation>[];
    }
    final q = _searchQuery.toLowerCase();
    return _conversations!.where((c) {
      for (final ex in c.exchanges) {
        if (ex.prompt.toLowerCase().contains(q)) return true;
        final resp = ex.response;
        if (resp != null && resp.toLowerCase().contains(q)) return true;
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = ErrorPanel(message: _error!);
    } else if (_conversations != null) {
      final filtered = _filteredConversations();
      body = Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: SizedBox(
                    height: 20,
                    child: Builder(
                      builder: (context) {
                        final style = Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontSize: 12, color: Colors.grey);
                        final countText = _searchQuery.isEmpty
                            ? 'Conversations: ${_conversations!.length}'
                            : 'Conversations: ${filtered.length} / ${_conversations!.length}';
                        final timeStr = DateFormat('h:mm a').format(_currentTime);
                        return Row(
                          children: [
                            Expanded(
                              child: Text(
                                _currentFilePath ?? '',
                                style: style,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(countText, style: style),
                            const SizedBox(width: 8),
                            Text(timeStr, style: style),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ConversationList(
                    conversations: filtered,
                    selected: _selectedConversation,
                    onSelected: (c) {
                      setState(() {
                        _selectedConversation = c;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: ConversationPanel(conversation: _selectedConversation),
          ),
        ],
      );
    } else {
      body = const Center(child: Text('Welcome to Colog V3'));
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: AppMenuBar(onOpen: _openJsonFile, onExit: _exitApp),
      ),
      body: body,
    );
  }
}
