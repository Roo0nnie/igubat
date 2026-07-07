// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_todos.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getTodosUseCase)
const getTodosUseCaseProvider = GetTodosUseCaseProvider._();

final class GetTodosUseCaseProvider
    extends $FunctionalProvider<GetTodos, GetTodos, GetTodos>
    with $Provider<GetTodos> {
  const GetTodosUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getTodosUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getTodosUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetTodos> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetTodos create(Ref ref) {
    return getTodosUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetTodos value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetTodos>(value),
    );
  }
}

String _$getTodosUseCaseHash() => r'ce70c37bdb505cf7a2283b3c5a3792f56eb352dd';
