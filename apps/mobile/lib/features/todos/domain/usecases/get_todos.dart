import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/todos_repository_impl.dart';
import '../entities/todo.dart';
import '../repositories/todos_repository.dart';

part 'get_todos.g.dart';

class GetTodos extends UseCase<List<Todo>, NoParams> {
  GetTodos(this._repository);

  final TodosRepository _repository;

  @override
  FutureResult<List<Todo>> call(NoParams params) => _repository.getTodos();
}

@riverpod
GetTodos getTodosUseCase(Ref ref) => GetTodos(ref.watch(todosRepositoryProvider));
