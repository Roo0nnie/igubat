// Parameter objects for the todo use cases.

class CreateTodoParams {
  const CreateTodoParams({required this.title, this.completed = false});
  final String title;
  final bool completed;
}

class UpdateTodoParams {
  const UpdateTodoParams({required this.id, this.title, this.completed});
  final int id;
  final String? title;
  final bool? completed;
}
