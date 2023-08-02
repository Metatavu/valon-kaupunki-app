import "dart:typed_data";

import "package:async/async.dart";
import "package:audioplayers/audioplayers.dart";
import "package:flutter_cache_manager/flutter_cache_manager.dart";
import "package:cancellation_token_http/http.dart" as http;
import "package:valon_kaupunki_app/preferences/preferences.dart";

class CachingAudioClient {
  static CachingAudioClient? _client;
  static const String _cachePrefix = "valon-kaupunki-audio-cache/";
  static const String _playerId = "valon-kaupunki-audio-player";

  // Mapping from URLs from Strapi to cache file names
  final Map<String, String> _cache = Preferences.audioCacheMapping;
  AudioPlayer player = AudioPlayer(playerId: _playerId);
  CacheManager? _cacheManager;

  factory CachingAudioClient.getInstance() {
    _client ??= CachingAudioClient._();

    _client!._cacheManager ??= CacheManager(
        Config(_cachePrefix, stalePeriod: const Duration(days: 1)));
    return _client!;
  }

  void reinitPlayer() {
    player = AudioPlayer(playerId: _playerId);
  }

  CachingAudioClient._();

  Future<Uint8List> _readCacheFile(String filename) async {
    final file = await _cacheManager!.getFileFromCache(filename);
    if (file == null) {
      throw Exception("_readCacheFile expects the file to exist");
    }

    return file.file.readAsBytes();
  }

  Future<void> _writeCacheFile(String url, String filename, Uint8List bytes) {
    _cache[url] = filename;
    Preferences.setAudioCacheMapping(_cache);
    return _cacheManager!.putFile(filename, bytes);
  }

  Future<Uint8List?> _downloadFile(
    String url,
    http.CancellationToken cancel,
  ) async {
    try {
      final response =
          await http.get(Uri.parse(url), cancellationToken: cancel);
      return response.bodyBytes;
    } on http.CancelledException {
      return null;
    }
  }

  Future<CancelableOperation<Uint8List?>> _loadAndCacheIfNeeded(
    String url,
    http.CancellationToken cancel,
  ) async {
    if (_cache[url] != null) {
      return CancelableOperation.fromValue(await _readCacheFile(_cache[url]!));
    }

    final download = _downloadFile(url, cancel);
    download.then((value) {
      if (value != null) {
        final filename = url.split("/").last;
        _writeCacheFile(url, filename, value);
      }
    });
    final op = CancelableOperation.fromFuture(download,
        onCancel: () => cancel.cancel());
    return op;
  }

  Future play(
    String url,
    http.CancellationToken cancel,
    void Function(PlayingState state, [double? progress]) progressCallback,
  ) async {
    progressCallback(PlayingState.downloading);
    final caching = await _loadAndCacheIfNeeded(url, cancel);
    final result = await caching.value;

    if (caching.isCanceled) {
      progressCallback(PlayingState.canceled);
      return null;
    }

    if (result == null) {
      progressCallback(PlayingState.failed);
      return null;
    }

    progressCallback(PlayingState.playing, 0.0);
    await player.setSource(BytesSource(result));
    final audioLength = await player.getDuration();

    player.onPositionChanged.listen((duration) {
      progressCallback(PlayingState.playing,
          duration.inMilliseconds / audioLength!.inMilliseconds);
    });
    player.onPlayerComplete.listen((_) {
      progressCallback(PlayingState.done);
    });
    return await player.play(player.source!,
        volume: 1.0, mode: PlayerMode.mediaPlayer);
  }
}

enum PlayingState {
  downloading,
  playing,
  paused,
  failed,
  canceled,
  done,
}
