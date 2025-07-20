import 'dart:ffi';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      title: 'Colog V3',
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
      // TODO: handle loaded JSON file
    }
  }

  void _exitApp() {
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Colog V3'),
        actions: [
          MenuBar(children: [
            SubmenuButton(
              menuChildren: [
                MenuItemButton(
                  onPressed: _openJsonFile,
                  child: const Text('Open'),
                ),
                const SizedBox(height: 8),
                MenuItemButton(
                  onPressed: _exitApp,
                  child: const Text('Exit'),
                ),
              ],
              child: const Text('File'),
            ),
          ])
        ],
      ),
      body: const Center(
        child: Text('Welcome to Colog V3'),
      ),
    );
  }
}
