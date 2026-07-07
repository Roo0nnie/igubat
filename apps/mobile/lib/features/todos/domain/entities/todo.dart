import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo.freezed.dart';

/// Domain entity for a todo item.
@freezed
abstract class Todo with _$Todo {
  const factory Todo({
    required int id,
    required String title,
    @Default(false) bool completed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Todo;
}
