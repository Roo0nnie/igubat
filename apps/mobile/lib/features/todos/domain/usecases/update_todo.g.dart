// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_todo.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(updateTodoUseCase)
const updateTodoUseCaseProvider = UpdateTodoUseCaseProvider._();

final class UpdateTodoUseCaseProvider
    extends $FunctionalProvider<UpdateTodo, UpdateTodo, UpdateTodo>
    with $Provider<UpdateTodo> {
  const UpdateTodoUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateTodoUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateTodoUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateTodo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateTodo create(Ref ref) {
    return updateTodoUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateTodo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateTodo>(value),
    );
  }
}

String _$updateTodoUseCaseHash() => r'e4ff3831c943e926ad646fdc8a1d98c4423dc0e8';
