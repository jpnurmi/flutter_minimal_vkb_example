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
    implements TextInputSource {
  // The currently attached client.
  TextInputClient? _client;
  // The current text input state.
  String _text = '';
  TextSelection _selection = TextSelection.collapsed(offset: 0);

  @override
  void initState() {
    super.initState();
    // Set the virtual keyboard as the current text input source.
    TextInput.setSource(this);
  }

  @override
  void dispose() {
    super.dispose();
    // Restore the default text input source.
    TextInput.setSource(TextInput.defaultSource);
  }

  // Handle a virtual key button press.
  void _handleKeyPress(String key) {
    // Insert text, replacing the current selection if any.
    _text = _text.replaceRange(_selection.start, _selection.end, key);
    _selection = TextSelection.collapsed(offset: _selection.start + key.length);

    // Request the attached client to update accordingly.
    _client?.updateEditingValue(
      TextEditingValue(text: _text, selection: _selection),
    );
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
  TextInputConnection attach(TextInputClient client) {
    setState(() => _client = client);

    return VirtualKeyboardConnection(
      client,
      onEditingValueSet: (TextEditingValue value) {
        // Keep track of the currently attached client's editing state changes.
        _text = value.text;
        _selection = value.selection;
      },
    );
  }

  @override
  void detach(TextInputClient client) {
    setState(() => _client = null);
  }

  @override
  void init() {}

  @override
  void cleanup() {}

  @override
  void finishAutofillContext({bool shouldSave = true}) {}
}

class VirtualKeyboardConnection extends TextInputConnection {
  ValueChanged<TextEditingValue> _onEditingValueSet;

  VirtualKeyboardConnection(
    TextInputClient client, {
    required ValueChanged<TextEditingValue> onEditingValueSet,
  })   : _onEditingValueSet = onEditingValueSet,
        super(client);

  @override
  void setEditingState(TextEditingValue value) {
    _onEditingValueSet(value);
  }

  @override
  void setClient(TextInputConfiguration configuration) {}

  @override
  void updateConfig(TextInputConfiguration configuration) {}

  @override
  void show() {}

  @override
  void hide() {}

  @override
  void clearClient() {}

  @override
  void setComposingRect(Rect rect) {}

  @override
  void setEditableSizeAndTransform(Size editableBoxSize, Matrix4 transform) {}

  @override
  void setStyle({
    required String? fontFamily,
    required double? fontSize,
    required FontWeight? fontWeight,
    required TextDirection textDirection,
    required TextAlign textAlign,
  }) {}

  @override
  void requestAutofill() {}

  @override
  void close() {}

  @override
  void connectionClosedReceived() {}
}
