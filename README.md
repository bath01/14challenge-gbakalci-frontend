# GbakalCI 🎵

> **"Gbakal"** = ambiance / fête en nouchi (argot ivoirien)  
> Player de musique ivoirienne — écouter sans connexion ni inscription.

**Challenge 14-14-14 — Jour 7 — Mars 2026**

---

## 📱 Aperçu

GbakalCI est une application mobile Flutter dédiée à la musique ivoirienne. Elle permet d'explorer, télécharger et écouter des morceaux de genres comme le Zouglou, le Coupé-Décalé et le Rap Ivoire — sans inscription ni connexion obligatoire.

---

## ✨ Fonctionnalités

- 🎵 **Lecture audio** — play / pause / stop / suivant / précédent
- 📥 **Téléchargement** — sauvegarde locale des morceaux pour écoute hors-ligne
- 🗄️ **Base de données locale** — SQLite pour gérer les audios téléchargés
- 📊 **Visualiseur audio** — barres animées en temps réel
- 🎛️ **Contrôle complet** — barre de progression, volume, shuffle, repeat
- 📋 **Playlists** — créer, modifier, réordonner, ajouter/supprimer des morceaux
- 🏷️ **Catégories** — filtrer par genre musical (Zouglou, Coupé-Décalé, Rap Ivoire...)
- 🖼️ **Pochette tournante** — animation fluide dans le lecteur plein écran
- 📱 **Responsive** — adapté à tous les formats d'écran

---

## 🛠️ Stack technique

| Couche | Technologie |
|---|---|
| Frontend | Flutter 3.27.4 / Dart 3.6.2 |
| État | Provider 6.x |
| Audio | just_audio + audio_session |
| HTTP | Dio 5.x |
| Base de données | SQLite (sqflite) |
| Cache images | cached_network_image |
| Stockage | path_provider |
| Backend | .NET Core (API REST) |

---

## 🏗️ Architecture
```
lib/
├── main.dart                  → Point d'entrée + injection des providers
├── app.dart                   → MaterialApp + thème global
├── shell/
│   └── app_shell.dart         → Navigation principale (bottom nav)
├── core/
│   ├── models/
│   │   ├── track.dart         → Modèle morceau
│   │   ├── playlist.dart      → Modèle playlist
│   │   ├── player_state.dart  → État du lecteur
│   │   └── category.dart      → Modèle catégorie musicale
│   ├── services/
│   │   ├── api_service.dart       → Appels HTTP (tracks, playlists, catégories)
│   │   ├── player_service.dart    → Contrôle audio (just_audio)
│   │   ├── playlist_service.dart  → Logique métier playlists
│   │   ├── download_service.dart  → Téléchargement + BDD SQLite
│   │   └── mock_data.dart         → Données statiques (fallback)
│   └── providers/
│       ├── player_provider.dart    → État global du lecteur + visualiseur
│       ├── playlist_provider.dart  → État playlists, tracks, catégories
│       └── download_provider.dart  → État des téléchargements
├── features/
│   ├── library/
│   │   ├── home_page.dart     → Accueil + filtres catégories
│   │   ├── library_page.dart  → Bibliothèque + recherche
│   │   └── about_page.dart    → À propos
│   ├── playlist/
│   │   └── playlists_page.dart → Gestion des playlists
│   └── player/
│       ├── lyrics_player_page.dart → Lecteur plein écran
│       ├── full_player_page.dart   → Lecteur alternatif
│       └── queue_page.dart         → File d'attente
└── shared/
    ├── theme.dart              → Couleurs et thème (orange CI + vert CI)
    ├── responsive.dart         → Utilitaire responsive
    └── widgets/
        ├── cover_art.dart          → Pochette d'album
        ├── track_row.dart          → Ligne d'un morceau
        ├── visualizer_bars.dart    → Barres d'égaliseur animées
        ├── rotating_cover.dart     → Pochette circulaire animée
        ├── genre_badge.dart        → Badge de catégorie
        └── download_button.dart    → Bouton téléchargement avec progression
```

---

## 🌐 API




| Endpoint | Méthode | Description |
|---|---|---|
| `/tracks` | GET | Liste tous les morceaux |
| `/tracks/:id` | GET | Détail d'un morceau |
| `/tracks/:id/audio` | GET | Fichier audio du morceau |
| `/playlists` | GET | Liste des playlists |
| `/playlists` | POST | Créer une playlist |
| `/playlists/:id/tracks/:trackId` | POST | Ajouter un morceau |
| `/playlists/:id/tracks/:trackId` | DELETE | Retirer un morceau |
| `/playlists/:id/reorder` | PUT | Réordonner les morceaux |
| `/Categories` | GET | Liste des catégories musicales |

---

## 🚀 Installation

### Prérequis

- Flutter 3.27.4+
- Dart 3.6.2+
- Android SDK (minSdk 21)

### Lancer le projet
```bash
# Cloner le repo
git clone https://github.com/bath01/14challenge-gbakalci-frontend.git
cd 14challenge-gbakalci-frontend

# Installer les dépendances
flutter pub get

# Lancer sur un appareil connecté
flutter run

# Build release APK
flutter build apk --release
```

---

## 📦 Dépendances principales
```yaml
just_audio: ^0.9.40        # Lecture audio
audio_session: ^0.1.21     # Gestion session OS
provider: ^6.1.2           # Gestion d'état
dio: ^5.7.0                # Requêtes HTTP
sqflite: ^2.3.3            # Base de données locale
path_provider: ^2.1.4      # Accès au stockage
cached_network_image: ^3.4.1  # Cache des pochettes
```

---

## 👥 Équipe

| Nom | Rôle |
|---|---|
| Bath Dorgeles | Chef de projet & Front-end |
| Oclin Marcel C. | Dev Front-end (Flutter) |
| Rayane Irie | Back-end (.NET Core) |

---

## 📄 Licence

Open Source · [225os.com](https://225os.com) & GitHub

---

*14-14-14 // JOUR 7 // MARS 2026*
