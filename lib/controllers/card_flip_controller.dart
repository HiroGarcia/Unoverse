import 'package:flutter/material.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:provider/provider.dart';

class CardFlipController extends ChangeNotifier {
  FlipCardController? _currentFlipped;
  void flip(FlipCardController controller) {
    if (_currentFlipped != null && _currentFlipped != controller) {
      _currentFlipped!.flipcard(); // desvira o anterior
    }
    _currentFlipped = controller;
    notifyListeners();
  }

  void reset() {
    if (_currentFlipped != null) {
      _currentFlipped!.flipcard(); // desvira o atual
      _currentFlipped = null;
      notifyListeners();
    }
  }

  bool isFlipped(FlipCardController controller) {
    return _currentFlipped == controller;
  }

  bool get hasFlipped => _currentFlipped != null;
}

void handleInteractionOrReset({
  required BuildContext context,
  required VoidCallback onValid,
}) {
  final controller = context.read<CardFlipController>();
  if (controller.hasFlipped) {
    controller.reset();
  } else {
    onValid();
  }
}
