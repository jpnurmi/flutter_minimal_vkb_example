import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class VirtualKeyboardControl extends TextInputControl {
  final _attached = ValueNotifier<bool>(false);
  // The currently attached client.
  TextInputClient? _client;
  // The current text input state.
  var _editingState = TextEditingValue();

  ValueNotifier<bool> get attached => _attached;
  TextEditingValue get editingState => _editingState;

  @override
  void attach(TextInputClient client, TextInputConfiguration configuration) {
    _attached.value = true;
  }

  @override
  void detach(TextInputClient client) {
    _attached.value = false;
  }

  @override
  void setEditingState(TextEditingValue value) {
    _editingState = value;
  }

  void processInput(String input) {
    // Insert text, replacing the current selection if any.
    var text = _editingState.text;
    var selection = _editingState.selection;

    final value = TextEditingValue(
      text: text.replaceRange(selection.start, selection.end, input),
      selection:
          TextSelection.collapsed(offset: selection.start + input.length),
    );

    // Keep track of the attached client's editing state changes.
    setEditingState(value);

    // Request the attached client to update accordingly.
    updateEditingValue(value);
  }
}

class VirtualKeyboardState extends State<VirtualKeyboard> {
  final _control = VirtualKeyboardControl();

  @override
  void initState() {
    super.initState();
    // Register the virtual keyboard as the current text input control.
    TextInput.setInputControl(_control);
  }

  @override
  void dispose() {
    super.dispose();
    // Restore the original platform text input control.
    TextInput.restorePlatformInputControl();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      canRequestFocus: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final key in ['A', 'B', 'C'])
            ValueListenableBuilder<bool>(
              valueListenable: _control.attached,
              builder: (_, attached, __) {
                return ElevatedButton(
                  child: Text(key),
                  onPressed: attached ? () => _control.processInput(key) : null,
                );
              },
            ),
        ],
      ),
    );
  }
}
