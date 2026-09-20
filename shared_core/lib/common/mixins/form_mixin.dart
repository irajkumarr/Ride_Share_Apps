import 'package:flutter/widgets.dart';

/// Mixin that provides common form-field handling for [State] classes.
///
/// Apply to any StatefulWidget that contains a [Form]:
/// ```dart
/// class _LoginViewState extends State<LoginView> with FormMixin {
///   @override
///   void dispose() {
///     disposeControllers();
///     super.dispose();
///   }
/// }
/// ```
mixin FormMixin<T extends StatefulWidget> on State<T> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// All [TextEditingController]s registered via [registerController].
  final List<TextEditingController> _controllers = [];

  /// All [FocusNode]s registered via [registerFocusNode].
  final List<FocusNode> _focusNodes = [];

  /// Registers a controller for automatic disposal.
  TextEditingController registerController([String? initialText]) {
    final controller = TextEditingController(text: initialText);
    _controllers.add(controller);
    return controller;
  }

  /// Registers a focus node for automatic disposal.
  FocusNode registerFocusNode() {
    final node = FocusNode();
    _focusNodes.add(node);
    return node;
  }

  /// Validates the form. Returns `true` if all fields are valid.
  bool validateForm() => formKey.currentState?.validate() ?? false;

  /// Resets the form (clears all field errors and values).
  void resetForm() => formKey.currentState?.reset();

  /// Hides the on-screen keyboard.
  void hideKeyboard() => FocusScope.of(context).unfocus();

  /// Disposes all registered controllers and focus nodes.
  /// Call inside [dispose].
  void disposeControllers() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    _controllers.clear();
    _focusNodes.clear();
  }
}

/// Mixin for automatic [ScrollController] lifecycle management.
mixin ScrollMixin<T extends StatefulWidget> on State<T> {
  late final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  /// Smoothly scrolls to the top of the list.
  void scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// Smoothly scrolls to the bottom of the list.
  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}
