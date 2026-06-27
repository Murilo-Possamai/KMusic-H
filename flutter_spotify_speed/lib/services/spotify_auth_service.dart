import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SpotifyAuthService {
  static const String _clientId = '579cf839dbf249d7a0fd4b1ce0fa2809';
  static const String _clientSecret = '5a54cd3027e34e0eab97ab87ce386134';
  static const String _redirectUri = 'spotifyspeed://callback';
  static const String _scopes =
      'user-read-private user-read-email playlist-read-private playlist-read-collaborative user-modify-playback-state user-read-playback-state streaming';

  static const String _accessTokenKey = 'spotify_access_token';
  static const String _refreshTokenKey = 'spotify_refresh_token';
  static const String _tokenExpiryKey = 'spotify_token_expiry';

  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiry;

  // PKCE
  late String _codeVerifier;
  late String _codeChallenge;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_accessTokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
    final expiryMs = prefs.getInt(_tokenExpiryKey);
    if (expiryMs != null) {
      _tokenExpiry = DateTime.fromMillisecondsSinceEpoch(expiryMs);
    }
  }

  bool get isLoggedIn => _accessToken != null;

  Future<String?> getValidAccessToken() async {
    if (_accessToken == null) return null;
    if (_tokenExpiry != null && DateTime.now().isAfter(_tokenExpiry!)) {
      await _refreshAccessToken();
    }
    return _accessToken;
  }

  void _generatePKCE() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    _codeVerifier = base64UrlEncode(bytes).replaceAll('=', '');
    final challenge = sha256.convert(utf8.encode(_codeVerifier)).bytes;
    _codeChallenge = base64UrlEncode(challenge).replaceAll('=', '');
  }

  Future<bool> login() async {
    _generatePKCE();

    final state = _generateRandomString(16);
    final authUrl = Uri.https('accounts.spotify.com', '/authorize', {
      'client_id': _clientId,
      'response_type': 'code',
      'redirect_uri': _redirectUri,
      'scope': _scopes,
      'state': state,
      'code_challenge_method': 'S256',
      'code_challenge': _codeChallenge,
    });

    try {
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: 'spotifyspeed',
      );

      final uri = Uri.parse(result);
      final code = uri.queryParameters['code'];
      if (code == null) return false;

      return await _exchangeCodeForToken(code);
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> _exchangeCodeForToken(String code) async {
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': _redirectUri,
        'client_id': _clientId,
        'code_verifier': _codeVerifier,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveTokens(data);
      return true;
    }
    print('Token exchange error: ${response.body}');
    return false;
  }

  Future<void> _refreshAccessToken() async {
    if (_refreshToken == null) return;

    final credentials = base64Encode(utf8.encode('$_clientId:$_clientSecret'));
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': _refreshToken!,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveTokens(data);
    }
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    _accessToken = data['access_token'];
    if (data['refresh_token'] != null) {
      _refreshToken = data['refresh_token'];
    }
    final expiresIn = data['expires_in'] as int;
    _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, _accessToken!);
    if (_refreshToken != null) {
      await prefs.setString(_refreshTokenKey, _refreshToken!);
    }
    await prefs.setInt(
        _tokenExpiryKey, _tokenExpiry!.millisecondsSinceEpoch);
  }

  Future<void> logout() async {
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiry = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenExpiryKey);
  }

  String _generateRandomString(int length) {
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }
}
