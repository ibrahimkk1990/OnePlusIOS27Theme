import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void enterEditMode() {
    if (!state) {
      HapticFeedback.heavyImpact();
      state = true;
    }
  }

  void exitEditMode() {
    if (state) {
      HapticFeedback.lightImpact();
      state = false;
    }
  }

  void toggleEditMode() {
    HapticFeedback.selectionClick();
    state = !state;
  }
}

final editModeProvider = NotifierProvider<EditModeNotifier, bool>(() {
  return EditModeNotifier();
});
