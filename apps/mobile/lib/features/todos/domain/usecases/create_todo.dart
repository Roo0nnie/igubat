import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/todos_repository_impl.dart';
import '../entities/todo.dart';
import '../repositories/todos_repository.dart';
import 'todo_params.dart';

part 'create_todo.g.dart';

class CreateTodo extends UseCase<Todo, CreateTodoParams> {
  CreateTodo(this._repository);

  final TodosRepository _repository;

  @override
  FutureResult<Todo> call(CreateTodoParams params) =>
      _repository.createTodo(title: params.title, completed: params.completed);
}

@riverpod
CreateTodo createTodoUseCase(Ref ref) =>
    CreateTodo(ref.watch(todosRepositoryProvider));
