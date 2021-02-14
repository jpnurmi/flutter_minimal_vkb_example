import 'package:flutter/material.dart';

import 'input_control.dart';

void main() => runApp(ExampleApp());

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minimal VKB'),
      ),
      body: TextField(
        autofocus: true,
        controller: _controller,
        decoration: InputDecoration(
          suffix: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => _controller.clear(),
          ),
        ),
      ),
      bottomSheet: VirtualKeyboard(),
    );
  }
}

class VirtualKeyboard extends StatefulWidget {
  @override
  VirtualKeyboardState createState() => VirtualKeyboardState();
}

class VirtualKeyboardState extends State<VirtualKeyboard> {
  final _inputControl = VirtualKeyboardControl();

  @override
  void initState() {
    super.initState();
    _inputControl.register();
  }

  @override
  void dispose() {
    super.dispose();
    _inputControl.unregister();
  }

  void _handleKeyPress(String key) {
    _inputControl.processInput(key);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _inputControl.attached,
      builder: (_, attached, __) {
        return FocusScope(
          canRequestFocus: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final key in ['A', 'B', 'C'])
                ElevatedButton(
                  child: Text(key),
                  onPressed: attached ? () => _handleKeyPress(key) : null,
                ),
            ],
          ),
        );
      },
    );
  }
}
