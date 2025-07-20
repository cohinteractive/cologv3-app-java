import 'package:flutter/material.dart';

class AppMenuBar extends StatelessWidget {
  final VoidCallback onOpen;
  final VoidCallback onExit;

  const AppMenuBar({super.key, required this.onOpen, required this.onExit});

  @override
  Widget build(BuildContext context) {
    return MenuBar(children: [
      SubmenuButton(
        menuChildren: [
          MenuItemButton(
            onPressed: onOpen,
            child: const Text('Open'),
          ),
          const SizedBox(height: 8),
          MenuItemButton(
            onPressed: onExit,
            child: const Text('Exit'),
          ),
        ],
        child: const Text('File'),
      ),
    ]);
  }
}
