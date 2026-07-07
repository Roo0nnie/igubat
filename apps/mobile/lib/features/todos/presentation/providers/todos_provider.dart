import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/todo.dart';
import '../../domain/usecases/create_todo.dart';
import '../../domain/usecases/delete_todo.dart';
import '../../domain/usecases/get_todos.dart';
import '../../domain/usecases/todo_params.dart';
import '../../domain/usecases/update_todo.dart';

part 'todos_provider.g.dart';

@riverpod
class TodosList extends _$TodosList {
  @override
  Future<List<Todo>> build() async {
    final result = await ref.read(getTodosUseCaseProvider).call(const NoParams());
    return result.fold((failure) => throw failure, (todos) => todos);
  }

  Future<void> createTodo({
    required String title,
    bool completed = false,
  }) async {
    final result = await ref
        .read(createTodoUseCaseProvider)
        .call(CreateTodoParams(title: title, completed: completed));
    result.fold((_) {}, (newTodo) {
      final current = state.value ?? <Todo>[];
      state = AsyncData([...current, newTodo]);
    });
  }

  Future<void> toggleTodo(Todo todo) async {
    final previousState = state;
    final todos = List<Todo>.from(state.value ?? <Todo>[]);
    final index = todos.indexWhere((t) => t.id == todo.id);
    if (index == -1) return;

    // Optimistic update.
    todos[index] = todo.copyWith(completed: !todo.completed);
    state = AsyncData(todos);

    final result = await ref
        .read(updateTodoUseCaseProvider)
        .call(UpdateTodoParams(id: todo.id, completed: !todo.completed));
    result.fold((_) => state = previousState, (_) {});
  }

  Future<void> updateTodo(int id, {String? title, bool? completed}) async {
    final result = await ref
        .read(updateTodoUseCaseProvider)
        .call(UpdateTodoParams(id: id, title: title, completed: completed));
    result.fold((_) {}, (updated) {
      final todos = List<Todo>.from(state.value ?? <Todo>[]);
      final index = todos.indexWhere((t) => t.id == id);
      if (index != -1) {
        todos[index] = updated;
        state = AsyncData(todos);
      }
    });
  }

  Future<void> deleteTodo(int id) async {
    final previousState = state;
    final todos = List<Todo>.from(state.value ?? <Todo>[]);

    // Optimistic removal.
    todos.removeWhere((t) => t.id == id);
    state = AsyncData(todos);

    final result =
        await ref.read(deleteTodoUseCaseProvider).call(id);
    result.fold((_) => state = previousState, (_) {});
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final result = await ref.read(getTodosUseCaseProvider).call(const NoParams());
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      AsyncData.new,
    );
  }
}
