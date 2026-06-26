// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_remote_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(newsRemoteDataSource)
const newsRemoteDataSourceProvider = NewsRemoteDataSourceProvider._();

final class NewsRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          NewsRemoteDataSource,
          NewsRemoteDataSource,
          NewsRemoteDataSource
        >
    with $Provider<NewsRemoteDataSource> {
  const NewsRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'newsRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$newsRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<NewsRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NewsRemoteDataSource create(Ref ref) {
    return newsRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NewsRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NewsRemoteDataSource>(value),
    );
  }
}

String _$newsRemoteDataSourceHash() =>
    r'b20bed3792be2975a402e55a963488ac70e21c81';
