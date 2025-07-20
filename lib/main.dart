import 'dart:ffi';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/conversation.dart';
import 'services/json_loader.dart';
import 'widgets/conversation_view.dart';
import 'widgets/menu_bar.dart';

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
  bool _loading = false;
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
      setState(() => _loading = true);
      final convs = await JsonLoader.loadConversations(file.path);
      setState(() {
        _conversations = convs;
        _loading = false;
      });
    }
  }

  void _exitApp() {
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_conversations != null) {
      body = ConversationView(conversations: _conversations!);
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
