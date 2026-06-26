// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_todo.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deleteTodoUseCase)
const deleteTodoUseCaseProvider = DeleteTodoUseCaseProvider._();

final class DeleteTodoUseCaseProvider
    extends $FunctionalProvider<DeleteTodo, DeleteTodo, DeleteTodo>
    with $Provider<DeleteTodo> {
  const DeleteTodoUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteTodoUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteTodoUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteTodo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteTodo create(Ref ref) {
    return deleteTodoUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteTodo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteTodo>(value),
    );
  }
}

String _$deleteTodoUseCaseHash() => r'2a1adfc7a0a7fcf42b308d785d3266902efae50f';
