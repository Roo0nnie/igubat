// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_todo.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(createTodoUseCase)
const createTodoUseCaseProvider = CreateTodoUseCaseProvider._();

final class CreateTodoUseCaseProvider
    extends $FunctionalProvider<CreateTodo, CreateTodo, CreateTodo>
    with $Provider<CreateTodo> {
  const CreateTodoUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createTodoUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createTodoUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateTodo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreateTodo create(Ref ref) {
    return createTodoUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateTodo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateTodo>(value),
    );
  }
}

String _$createTodoUseCaseHash() => r'69bf996677e094d7492f730b26c4f53fa4fc2133';
