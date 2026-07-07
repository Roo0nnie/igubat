import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/base_remote_data_source.dart';
import '../../../../core/network/dio_client.dart';
import '../models/todo_model.dart';

part 'todos_remote_data_source.g.dart';

/// Talks to the example oRPC todos endpoints. Returns [TodoModel] DTOs.
class TodosRemoteDataSource with BaseRemoteDataSource {
  TodosRemoteDataSource(this._client);

  final DioClient _client;

  Future<List<TodoModel>> fetchAll() =>
      guard(() => _client.getList(ApiConstants.todos, TodoModel.fromJson));

  Future<TodoModel> create({required String title, bool completed = false}) =>
      guard(
        () => _client.post(
          ApiConstants.todos,
          TodoModel.fromJson,
          data: {'title': title, 'completed': completed},
        ),
      );

  Future<TodoModel> update(int id, {String? title, bool? completed}) => guard(() {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (completed != null) data['completed'] = completed;
    return _client.put(ApiConstants.todoById(id), TodoModel.fromJson, data: data);
  });

  Future<void> delete(int id) =>
      guard(() => _client.delete(ApiConstants.todoById(id)));
}

@riverpod
TodosRemoteDataSource todosRemoteDataSource(Ref ref) =>
    TodosRemoteDataSource(ref.watch(dioClientProvider));
