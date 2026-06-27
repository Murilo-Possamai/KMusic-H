# 🚗 Spotify Speed - Flutter App

App Flutter que detecta sua velocidade em km/h via GPS e toca automaticamente a playlist certa do Spotify para cada velocidade.

## 📱 Funcionalidades

- **Velocímetro digital** em tempo real (estilo display 7-segmentos)
- **GPS** para velocidade precisa ao dirigir
- **Acelerômetro** como fallback quando GPS indisponível
- **Playlists automáticas**: defina qual playlist toca em cada velocidade
- **Controles de player**: play/pause, próxima, anterior
- **Múltiplas playlists**: configure faixas de velocidade (ex: 60-100 km/h, 100+ km/h)

## 🛠️ Setup

### Pré-requisitos
- Flutter 3.10+
- Dart 3.0+
- Conta Spotify (Premium recomendado para controle de playback)

### 1. Clone e instale dependências

```bash
flutter pub get
```

### 2. Configure o Spotify App

O app já vem configurado com:
- **Client ID**: `579cf839dbf249d7a0fd4b1ce0fa2809`
- **Redirect URI**: `spotifyspeed://callback`

**No Spotify Developer Dashboard** (https://developer.spotify.com/dashboard):
1. Abra seu app
2. Em "Redirect URIs", adicione: `spotifyspeed://callback`
3. Salve as configurações

### 3. Android - Configuração

No arquivo `android/app/build.gradle`, certifique-se que:
```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        applicationId "com.spotifyspeed.app"
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

### 4. iOS - Configuração

O `Info.plist` já está configurado com:
- URL Scheme `spotifyspeed`
- Permissões de localização

Para iOS, adicione no `Podfile`:
```ruby
platform :ios, '12.0'
```

### 5. Executar

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Release APK
flutter build apk --release

# Release App Bundle
flutter build appbundle --release
```

## 🏗️ Estrutura do Projeto

```
lib/
├── main.dart                    # Entry point + navegação
├── theme.dart                   # Cores e tema do app
├── models/
│   ├── playlist_model.dart      # SpotifyPlaylist + PlaylistConfig
│   └── track_model.dart         # CurrentTrack
├── services/
│   ├── spotify_auth_service.dart # OAuth2 PKCE com Spotify
│   ├── spotify_api_service.dart  # API REST do Spotify
│   └── velocity_service.dart     # GPS + Acelerômetro
├── providers/
│   └── app_provider.dart        # Estado global (Provider)
├── screens/
│   ├── login_screen.dart        # Tela de login
│   ├── home_screen.dart         # Velocímetro + player
│   ├── playlists_screen.dart    # Config de playlists
│   └── settings_screen.dart    # Configurações
└── widgets/
    ├── speedometer_widget.dart  # Display digital de velocidade
    └── now_playing_card.dart    # Card de música atual + controles
```

## 🔐 Como Funciona o OAuth

O app usa **PKCE (Proof Key for Code Exchange)** para autenticação segura:

1. Usuário toca "Entrar com Spotify"
2. App gera `code_verifier` e `code_challenge` aleatórios
3. Abre browser com URL de autorização do Spotify
4. Spotify redireciona para `spotifyspeed://callback?code=...`
5. App captura o código e troca por access token
6. Tokens são salvos localmente (SharedPreferences)
7. Refresh token renova automaticamente quando expira

## 🎵 Lógica de Playlist por Velocidade

1. Usuário configura: "Playlist X toca a partir de 100 km/h"
2. App monitora GPS continuamente
3. Quando velocidade ≥ 100 km/h → toca Playlist X automaticamente
4. Quando velocidade cai abaixo → pausa música
5. Prioridade: playlist com maior `minSpeed` que ainda é válida

## 📦 Dependências Principais

| Pacote | Uso |
|--------|-----|
| `flutter_web_auth_2` | OAuth2 com Spotify |
| `http` | Chamadas REST à API do Spotify |
| `geolocator` | Velocidade via GPS |
| `sensors_plus` | Acelerômetro |
| `provider` | Gerenciamento de estado |
| `shared_preferences` | Salvar tokens e configs |
| `cached_network_image` | Imagens de playlists/álbuns |
| `google_fonts` | Fontes (Inter + Share Tech) |

## ⚠️ Notas Importantes

- **Spotify Premium** é necessário para controlar o playback via API
- Em modo **Development** do Spotify, apenas usuários na allowlist podem usar
- Para produção, solicite **Extended Quota Mode** no Spotify Dashboard
- O GPS consome bateria; o acelerômetro é alternativa mais econômica (menos preciso)

## 🎨 Design

Inspirado no design da imagem de referência com:
- Fundo preto (`#121212`)
- Velocímetro digital cyan (`#00D9FF`) com efeito glow
- Verde Spotify (`#1DB954`) para elementos interativos
- Cards escuros com bordas sutis
- Fonte `Share Tech` para o display (visual 7-segmentos)
