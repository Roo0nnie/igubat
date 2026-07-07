// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todos_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TodosList)
const todosListProvider = TodosListProvider._();

final class TodosListProvider
    extends $AsyncNotifierProvider<TodosList, List<Todo>> {
  const TodosListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todosListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todosListHash();

  @$internal
  @override
  TodosList create() => TodosList();
}

String _$todosListHash() => r'ccc13c5430f44764f37d3843d19df337fbf446cc';

abstract class _$TodosList extends $AsyncNotifier<List<Todo>> {
  FutureOr<List<Todo>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Todo>>, List<Todo>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Todo>>, List<Todo>>,
              AsyncValue<List<Todo>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
