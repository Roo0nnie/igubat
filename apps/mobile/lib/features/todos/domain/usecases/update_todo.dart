import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/todos_repository_impl.dart';
import '../entities/todo.dart';
import '../repositories/todos_repository.dart';
import 'todo_params.dart';

part 'update_todo.g.dart';

class UpdateTodo extends UseCase<Todo, UpdateTodoParams> {
  UpdateTodo(this._repository);

  final TodosRepository _repository;

  @override
  FutureResult<Todo> call(UpdateTodoParams params) => _repository.updateTodo(
    params.id,
    title: params.title,
    completed: params.completed,
  );
}

@riverpod
UpdateTodo updateTodoUseCase(Ref ref) =>
    UpdateTodo(ref.watch(todosRepositoryProvider));
