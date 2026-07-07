import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/todos_repository_impl.dart';
import '../repositories/todos_repository.dart';

part 'delete_todo.g.dart';

class DeleteTodo extends UseCase<Unit, int> {
  DeleteTodo(this._repository);

  final TodosRepository _repository;

  @override
  FutureResult<Unit> call(int id) => _repository.deleteTodo(id);
}

@riverpod
DeleteTodo deleteTodoUseCase(Ref ref) =>
    DeleteTodo(ref.watch(todosRepositoryProvider));
