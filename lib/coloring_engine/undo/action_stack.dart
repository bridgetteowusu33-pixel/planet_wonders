/// Generic action stack for undo/redo workflows.
///
/// Keeps committed actions and redo actions separate.
class ActionStack<T> {
  const ActionStack({
    this.actions = const [],
    this.redo = const [],
  });

  final List<T> actions;
  final List<T> redo;

  bool get canUndo => actions.isNotEmpty;
  bool get canRedo => redo.isNotEmpty;

  ActionStack<T> push(T action) => ActionStack<T>(
        actions: [...actions, action],
        redo: const [],
      );

  (ActionStack<T>, T?) undoOne() {
    if (actions.isEmpty) return (this, null);
    final nextActions = [...actions];
    final last = nextActions.removeLast();
    return (
      ActionStack<T>(
        actions: nextActions,
        redo: [...redo, last],
      ),
      last,
    );
  }

  (ActionStack<T>, T?) redoOne() {
    if (redo.isEmpty) return (this, null);
    final nextRedo = [...redo];
    final action = nextRedo.removeLast();
    return (
      ActionStack<T>(
        actions: [...actions, action],
        redo: nextRedo,
      ),
      action,
    );
  }
}

