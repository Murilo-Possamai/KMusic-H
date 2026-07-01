import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist_model.dart';
import '../models/track_model.dart';
import '../services/spotify_auth_service.dart';
import '../services/spotify_api_service.dart';
import '../services/velocity_service.dart';

class AppProvider extends ChangeNotifier {
  final SpotifyAuthService authService = SpotifyAuthService();
  late final SpotifyApiService apiService;
  final VelocityService velocityService = VelocityService();

  // Auth state
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userProfile;

  // Playlists
  List<SpotifyPlaylist> _playlists = [];
  bool _loadingPlaylists = false;
  SpotifyPlaylist? _selectedPlaylist;

  // Diagnóstico do último login Spotify (fica visível no card)
  String? _lastAuthError;

  // Speed state
  double _currentSpeedKmh = 0;
  VelocitySource _velocitySource = VelocitySource.gps;
  bool _isTracking = false;
  bool _useGPS = true;

  // Playlist configs
  List<PlaylistConfig> _playlistConfigs = [];
  PlaylistConfig? _activeConfig;
  String? _lastPlayedPlaylistUri;

  // Player state
  CurrentTrack? _currentTrack;
  Timer? _playerPollTimer;
  Timer? _speedCheckTimer;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get userProfile => _userProfile;
  List<SpotifyPlaylist> get playlists => List.unmodifiable(_playlists);
  bool get loadingPlaylists => _loadingPlaylists;
  SpotifyPlaylist? get selectedPlaylist => _selectedPlaylist;
  String? get lastAuthError => _lastAuthError;
  double get currentSpeedKmh => _currentSpeedKmh;
  VelocitySource get velocitySource => _velocitySource;
  bool get isTracking => _isTracking;
  bool get useGPS => _useGPS;
  List<PlaylistConfig> get playlistConfigs => List.unmodifiable(_playlistConfigs);
  PlaylistConfig? get activeConfig => _activeConfig;
  CurrentTrack? get currentTrack => _currentTrack;

  AppProvider() {
    apiService = SpotifyApiService(authService);
  }

  Future<void> init() async {
    await authService.init();
    _isLoggedIn = authService.isLoggedIn;
    await _loadPlaylistConfigs();
    if (_isLoggedIn) {
      await _loadUserProfile();
      _startPlayerPolling();
    }
    notifyListeners();
  }

  Future<void> login() async {
    _lastAuthError = null;
    notifyListeners();
    try {
      final success = await authService.login();
      if (success) {
        _isLoggedIn = true;
        notifyListeners(); // atualiza UI imediatamente (Conectado)
        _startPlayerPolling();
        await _loadUserProfile();
      }
    } catch (e) {
      _lastAuthError = e.toString();
      _isLoggedIn = authService.isLoggedIn; // reflete estado real do token
      notifyListeners();
      rethrow; // mantém o snackbar também
    }
  }


  Future<void> loadPlaylists() async {
    _loadingPlaylists = true;
    notifyListeners();
    try {
      _playlists = await apiService.getUserPlaylists();
    } finally {
      _loadingPlaylists = false;
      notifyListeners();
    }
  }

  Future<void> selectAndPlayPlaylist(SpotifyPlaylist playlist) async {
    _selectedPlaylist = playlist;
    notifyListeners();
    await apiService.playPlaylist(playlist.uri);
    await Future.delayed(const Duration(milliseconds: 500));
    await _pollPlayer();
  }

  Future<void> logout() async {
    await authService.logout();
    _isLoggedIn = false;
    _userProfile = null;
    _currentTrack = null;
    _playerPollTimer?.cancel();
    notifyListeners();
  }

  Future<void> _loadUserProfile() async {
    _userProfile = await apiService.getCurrentUser();
    notifyListeners();
  }

  // === VELOCITY ===

  Future<void> startTracking() async {
    await velocityService.startTracking(useGPS: _useGPS);
    _isTracking = true;

    velocityService.velocityStream.listen((data) {
      _currentSpeedKmh = data.speedKmh;
      _velocitySource = data.source;
      _checkSpeedForPlaylist();
      notifyListeners();
    });

    notifyListeners();
  }

  void stopTracking() {
    velocityService.stopTracking();
    _isTracking = false;
    _currentSpeedKmh = 0;
    notifyListeners();
  }

  void setUseGPS(bool useGPS) {
    _useGPS = useGPS;
    if (_isTracking) {
      velocityService.switchSource(useGPS: useGPS);
    }
    notifyListeners();
  }

  // === PLAYLIST CONFIGS ===

  Future<void> addPlaylistConfig(PlaylistConfig config) async {
    _playlistConfigs.add(config);
    await _savePlaylistConfigs();
    notifyListeners();
  }

  Future<void> updatePlaylistConfig(PlaylistConfig config) async {
    final index = _playlistConfigs.indexWhere((c) => c.id == config.id);
    if (index >= 0) {
      _playlistConfigs[index] = config;
      await _savePlaylistConfigs();
      notifyListeners();
    }
  }

  Future<void> removePlaylistConfig(String id) async {
    _playlistConfigs.removeWhere((c) => c.id == id);
    await _savePlaylistConfigs();
    notifyListeners();
  }

  Future<void> _savePlaylistConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _playlistConfigs.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList('playlist_configs', jsonList);
  }

  Future<void> _loadPlaylistConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('playlist_configs') ?? [];
    _playlistConfigs = jsonList
        .map((j) => PlaylistConfig.fromJson(jsonDecode(j)))
        .toList();
  }

  // === SPEED → PLAYLIST LOGIC ===

  void _checkSpeedForPlaylist() {
    if (!_isLoggedIn || _playlistConfigs.isEmpty) return;

    PlaylistConfig? best;
    for (final config in _playlistConfigs) {
      final minOk = _currentSpeedKmh >= config.minSpeedKmh;
      final maxOk = config.maxSpeedKmh == null ||
          _currentSpeedKmh <= config.maxSpeedKmh!;
      if (minOk && maxOk) {
        if (best == null || config.minSpeedKmh > best.minSpeedKmh) {
          best = config;
        }
      }
    }

    if (best != null && best.playlist.uri != _lastPlayedPlaylistUri) {
      _activeConfig = best;
      _lastPlayedPlaylistUri = best.playlist.uri;
      apiService.playPlaylist(best.playlist.uri);
      notifyListeners();
    } else if (best == null && _lastPlayedPlaylistUri != null) {
      _activeConfig = null;
      _lastPlayedPlaylistUri = null;
      apiService.pause();
      notifyListeners();
    }
  }

  // === PLAYER CONTROLS ===

  Future<void> playPlaylist(String uri) async {
    await apiService.playPlaylist(uri);
    await Future.delayed(const Duration(milliseconds: 500));
    await _pollPlayer();
  }

  Future<void> togglePlayPause() async {
    if (_currentTrack?.isPlaying == true) {
      await apiService.pause();
    } else {
      await apiService.resume();
    }
    await Future.delayed(const Duration(milliseconds: 300));
    await _pollPlayer();
  }

  Future<void> nextTrack() async {
    await apiService.nextTrack();
    await Future.delayed(const Duration(milliseconds: 500));
    await _pollPlayer();
  }

  Future<void> previousTrack() async {
    await apiService.previousTrack();
    await Future.delayed(const Duration(milliseconds: 500));
    await _pollPlayer();
  }

  void _startPlayerPolling() {
    _playerPollTimer?.cancel();
    _playerPollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _pollPlayer();
    });
  }

  Future<void> _pollPlayer() async {
    final track = await apiService.getCurrentlyPlaying();
    _currentTrack = track;
    notifyListeners();
  }

  @override
  void dispose() {
    velocityService.dispose();
    _playerPollTimer?.cancel();
    _speedCheckTimer?.cancel();
    super.dispose();
  }
}
