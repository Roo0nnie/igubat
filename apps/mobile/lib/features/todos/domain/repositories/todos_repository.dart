import '../../../../core/usecases/result.dart';
import '../entities/todo.dart';

/// Todos contract. Implemented in
/// `data/repositories/todos_repository_impl.dart`.
abstract interface class TodosRepository {
  FutureResult<List<Todo>> getTodos();

  FutureResult<Todo> createTodo({required String title, bool completed});

  FutureResult<Todo> updateTodo(int id, {String? title, bool? completed});

  FutureResult<Unit> deleteTodo(int id);
}
