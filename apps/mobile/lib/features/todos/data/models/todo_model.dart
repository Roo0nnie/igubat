import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/todo.dart';

part 'todo_model.freezed.dart';
part 'todo_model.g.dart';

@freezed
abstract class TodoModel with _$TodoModel {
  const TodoModel._();

  const factory TodoModel({
    required int id,
    required String title,
    @Default(false) bool completed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TodoModel;

  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(json);

  Todo toEntity() => Todo(
    id: id,
    title: title,
    completed: completed,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
