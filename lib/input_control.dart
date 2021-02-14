import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CustomInputControl extends TextInputControl {
  var _editingState = TextEditingValue();
  final _attached = ValueNotifier<bool>(false);
  final _visible = ValueNotifier<bool>(false);

  /// The input control's attached state for updating the visual presentation.
  ValueListenable<bool> get attached => _attached;

  /// The input control's visibility state for updating the visual presentation.
  ValueListenable<bool> get visible => _visible;

  /// Register the input control.
  void register() => TextInput.setInputControl(this);

  /// Restore the original platform input control.
  void unregister() => TextInput.restorePlatformInputControl();

  @override
  void attach(_, __) => _attached.value = true;

  @override
  void detach(_) => _attached.value = false;

  @override
  void show() => _visible.value = true;

  @override
  void hide() => _visible.value = false;

  @override
  void setEditingState(TextEditingValue value) => _editingState = value;

  /// Process user input.
  ///
  /// Updates the internal editing state by inserting the input text,
  /// and by replacing the current selection if any.
  void processUserInput(String input) {
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
