import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/playlist_model.dart';
import '../models/track_model.dart';
import 'spotify_auth_service.dart';

class SpotifyApiService {
  static const String _baseUrl = 'https://api.spotify.com/v1';
  final SpotifyAuthService _auth;

  SpotifyApiService(this._auth);

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getValidAccessToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/me'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<List<SpotifyPlaylist>> getUserPlaylists() async {
    final List<SpotifyPlaylist> playlists = [];
    String? nextUrl = '$_baseUrl/me/playlists?limit=50';

    while (nextUrl != null) {
      final response = await http.get(
        Uri.parse(nextUrl),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List;
        for (final item in items) {
          if (item != null) {
            playlists.add(SpotifyPlaylist.fromJson(item));
          }
        }
        nextUrl = data['next'];
      } else {
        break;
      }
    }
    return playlists;
  }

  Future<CurrentTrack?> getCurrentlyPlaying() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/me/player/currently-playing'),
      headers: await _headers(),
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final data = jsonDecode(response.body);
      if (data['item'] != null) {
        return CurrentTrack.fromJson(data);
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> getPlaybackState() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/me/player'),
      headers: await _headers(),
    );
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<bool> playPlaylist(String playlistUri) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/me/player/play'),
      headers: await _headers(),
      body: jsonEncode({'context_uri': playlistUri}),
    );
    return response.statusCode == 204 || response.statusCode == 200;
  }

  Future<bool> pause() async {
    final response = await http.put(
      Uri.parse('$_baseUrl/me/player/pause'),
      headers: await _headers(),
    );
    return response.statusCode == 204 || response.statusCode == 200;
  }

  Future<bool> resume() async {
    final response = await http.put(
      Uri.parse('$_baseUrl/me/player/play'),
      headers: await _headers(),
    );
    return response.statusCode == 204 || response.statusCode == 200;
  }

  Future<bool> nextTrack() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/me/player/next'),
      headers: await _headers(),
    );
    return response.statusCode == 204 || response.statusCode == 200;
  }

  Future<bool> previousTrack() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/me/player/previous'),
      headers: await _headers(),
    );
    return response.statusCode == 204 || response.statusCode == 200;
  }

  Future<bool> setShuffle(bool state) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/me/player/shuffle?state=$state'),
      headers: await _headers(),
    );
    return response.statusCode == 204 || response.statusCode == 200;
  }

  Future<List<Map<String, dynamic>>> getPlaylistTracks(
      String playlistId) async {
    final response = await http.get(
      Uri.parse(
          '$_baseUrl/playlists/$playlistId/tracks?limit=5&fields=items(track(name,artists,album(images)))'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['items']);
    }
    return [];
  }
}
