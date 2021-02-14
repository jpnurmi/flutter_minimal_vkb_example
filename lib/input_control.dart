import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class VirtualKeyboardControl extends TextInputControl {
  var _editingState = TextEditingValue();
  final _attached = ValueNotifier<bool>(false);

  ValueNotifier<bool> get attached => _attached;

  void register() {
    // Register the virtual keyboard as the current text input control.
    TextInput.setInputControl(this);
  }

  void unregister() {
    // Restore the original platform text input control.
    TextInput.restorePlatformInputControl();
  }

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
    _editingState = _editingState.copyWith(
      text: _insertText(input),
      selection: _replaceSelection(input),
    );

    // Request the attached client to update accordingly.
    updateEditingValue(_editingState);
  }

  String _insertText(String input) {
    final text = _editingState.text;
    final selection = _editingState.selection;
    return text.replaceRange(selection.start, selection.end, input);
  }

  TextSelection _replaceSelection(String input) {
    final selection = _editingState.selection;
    return TextSelection.collapsed(offset: selection.start + input.length);
  }
}
