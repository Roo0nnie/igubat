import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/base_repository.dart';
import '../../../../core/usecases/result.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todos_repository.dart';
import '../datasources/todos_remote_data_source.dart';

part 'todos_repository_impl.g.dart';

class TodosRepositoryImpl with BaseRepository implements TodosRepository {
  TodosRepositoryImpl(this._remote);

  final TodosRemoteDataSource _remote;

  @override
  FutureResult<List<Todo>> getTodos() => execute(() async {
    final models = await _remote.fetchAll();
    return models.map((m) => m.toEntity()).toList();
  });

  @override
  FutureResult<Todo> createTodo({required String title, bool completed = false}) =>
      execute(() async {
        final model = await _remote.create(title: title, completed: completed);
        return model.toEntity();
      });

  @override
  FutureResult<Todo> updateTodo(int id, {String? title, bool? completed}) =>
      execute(() async {
        final model = await _remote.update(id, title: title, completed: completed);
        return model.toEntity();
      });

  @override
  FutureResult<Unit> deleteTodo(int id) => execute(() async {
    await _remote.delete(id);
    return unit;
  });
}

@riverpod
TodosRepository todosRepository(Ref ref) =>
    TodosRepositoryImpl(ref.watch(todosRemoteDataSourceProvider));
