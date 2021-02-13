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

class VirtualKeyboardState extends State<VirtualKeyboard>
    with TextInputControl {
  // The currently attached client.
  TextInputClient? _client;
  // The current text input state.
  var _editingState = TextEditingValue();

  @override
  void initState() {
    super.initState();
    // Register the virtual keyboard as the current text input control.
    TextInput.addInputControl(this);
    TextInput.setCurrentInputControl(this);
  }

  @override
  void dispose() {
    super.dispose();
    // Restore the original platform text input control.
    TextInput.removeInputControl(this);
    TextInput.setCurrentInputControl(PlatformTextInputControl.instance);
  }

  // Handle a virtual key button press.
  void _handleKeyPress(String key) {
    // Insert text, replacing the current selection if any.
    var text = _editingState.text;
    var selection = _editingState.selection;

    final value = TextEditingValue(
      text: text.replaceRange(selection.start, selection.end, key),
      selection: TextSelection.collapsed(offset: selection.start + key.length),
    );
    setEditingState(value);

    // Request the attached client to update accordingly.
    updateEditingValue(value);
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      canRequestFocus: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final key in ['A', 'B', 'C'])
            ElevatedButton(
              child: Text(key),
              onPressed: _client != null ? () => _handleKeyPress(key) : null,
            ),
        ],
      ),
    );
  }

  @override
  void attach(TextInputClient client, TextInputConfiguration configuration) {
    setState(() => _client = client);
  }

  @override
  void detach(TextInputClient client) {
    setState(() => _client = null);
  }

  @override
  void setEditingState(TextEditingValue value) {
    // Keep track of the attached client's editing state changes.
    _editingState = value;
  }
}
