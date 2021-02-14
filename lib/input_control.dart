import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class VirtualKeyboardControl extends TextInputControl {
  var _editingState = TextEditingValue();
  final _attached = ValueNotifier<bool>(false);

  ValueNotifier<bool> get attached => _attached;
  TextEditingValue get editingState => _editingState;

  void register() {
    // Register the virtual keyboard as the current text input control.
    TextInput.setInputControl(this);
  }

  void unregister() {
    // Restore the original platform text input control.
    TextInput.restorePlatformInputControl();
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
}
