// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todos_remote_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(todosRemoteDataSource)
const todosRemoteDataSourceProvider = TodosRemoteDataSourceProvider._();

final class TodosRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          TodosRemoteDataSource,
          TodosRemoteDataSource,
          TodosRemoteDataSource
        >
    with $Provider<TodosRemoteDataSource> {
  const TodosRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todosRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todosRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<TodosRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TodosRemoteDataSource create(Ref ref) {
    return todosRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TodosRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TodosRemoteDataSource>(value),
    );
  }
}

String _$todosRemoteDataSourceHash() =>
    r'fb62b348cd7d64e445df7d427da1e9d4d6a18ae4';
