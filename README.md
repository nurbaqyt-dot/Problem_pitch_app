<p align="center">
  <img src="screenshots/banner.png" alt="QTalk Banner" width="100%"/>
</p>

<h1 align="center">QTalk 🇰🇿</h1>

<p align="center">
  <b>Learn Kazakh with a clear rhythm — study the phrase, practice with a local, then test what stuck.</b><br/>
  A gamified Kazakh language learning app for foreigners, inspired by Duolingo.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter"/>
  <img src="https://img.shields.io/badge/Firebase-enabled-orange?logo=firebase"/>
  <img src="https://img.shields.io/badge/Language-Kazakh-green"/>
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey"/>
</p>

---

## Screenshots

| Home | Lessons | Speed Match | Chat |
|---|---|---|---|
| <img src="screenshots/home.png" width="180"/> | <img src="screenshots/lessons.png" width="180"/> | <img src="screenshots/speed_match.png" width="180"/> | <img src="screenshots/chat.png" width="180"/> |

| Lesson Map | Practice | Profile | Scenarios |
|---|---|---|---|
| <img src="screenshots/lesson_map.png" width="180"/> | <img src="screenshots/practice.png" width="180"/> | <img src="screenshots/profile.png" width="180"/> | <img src="screenshots/scenarios.png" width="180"/> |

---

## About

QTalk is a startup mobile app built to make Kazakh accessible to foreigners and non-native speakers through a structured **Learn → Practice → Test** loop, real conversation scenarios, and game-based reinforcement. Every lesson rewards XP, tracks streaks, and unlocks the next level — keeping learners motivated.

---

## Features

### 🏠 Home
- Personalized lesson feed showing your current progress
- XP progress bar with "Next level in X XP" indicator
- Course completion percentage (25%, 50%…)
- Locked / Ready to learn / Completed lesson states

### 📚 Lessons (Learn → Practice → Test)
Each lesson has three phases:

| Phase | Description |
|---|---|
| **Learn** | Flashcards with pronunciation (5 cards per lesson) |
| **Practice** | Reply in dialogue / chat mode with a virtual local |
| **Test** | Quiz system to keep what you learned |

Current lesson curriculum:

| # | Lesson | Topic |
|---|---|---|
| 1 | Greetings | Meet people, check-ins, friendly conversation |
| 2 | Basic Phrases | Polite everyday replies, yes/no, survival phrases |
| 3 | Food & Restaurant | Menu, ordering drinks, complimenting food 🔒 |
| 4 | Directions | Direction words, asking where a place is 🔒 |

### 🎮 Games — Speed Match
- Match the **English meaning** to the **Kazakh phrase** before time runs out
- Timer pressure + scoring system
- XP earned each round
- Replay to get a fresh set of word pairs
- Vocabulary covered: Rahmet, Keshiriniz, Ia, Salem, Qalaisyn, Zhoq…

### 💬 Chat With Locals
- Choose **conversation scenarios** instead of free typing
- Learn from mistakes instantly
- Build confidence before real conversations
- Scenarios: Meet Aida, Market Mini Talk, Cafe Order, Ask for Directions
- Each chat awards **+18 XP**

### 👤 Profile
- Level badge and title ("QTalk Learner — Mini Duolingo energy")
- **Total XP** counter
- **Streak** tracker (daily login streak)
- **Completed** lessons counter (e.g. 1/4)
- **Next Level** XP target
- Level progress bar (26/200 XP in this level)

### 🗺 Lesson Map
- Visual course roadmap with all lessons
- Completion % per lesson
- Status: Completed / In progress / Locked

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| Auth | Firebase Authentication |
| Database | Cloud Firestore |
| State management | Riverpod |
| Navigation | go_router |
| Animations | Flutter built-in + custom |

---

## Project Structure

```
lib/
├── core/
│   ├── theme/            # Green/orange/blue color palette, typography
│   └── constants/        # XP thresholds, lesson config
├── models/
│   ├── lesson_model.dart
│   ├── user_progress_model.dart
│   └── word_pair_model.dart
├── providers/
│   ├── auth_provider.dart
│   ├── progress_provider.dart
│   └── game_provider.dart
├── screens/
│   ├── home/             # Lesson feed, XP bar, course progress
│   ├── lesson/           # Learn / Practice / Test flow
│   ├── games/            # Speed Match
│   ├── chat/             # Chat With Locals, scenarios
│   └── profile/          # Stats, level, streak
└── widgets/              # LessonCard, XPBar, ProgressBadge, WordPairTile…
```

---

## Getting Started

### Prerequisites
- Flutter SDK ≥ 3.x
- Firebase project with **Authentication** and **Firestore** enabled

### Setup

1. Clone and install dependencies:
   ```bash
   git clone https://github.com/your-username/qtalk.git
   cd qtalk
   flutter pub get
   ```

2. Connect Firebase:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

3. Run the app:
   ```bash
   flutter run
   ```

---

## Firestore Schema

```
users/
  {uid}/
    displayName:   string
    level:         int
    totalXp:       int
    streak:        int
    lastActiveAt:  timestamp
    progress/
      {lessonId}/
        learnDone:    bool
        practiceDone: bool
        testDone:     bool
        xpEarned:     int
```

---

## Gamification Logic

| Action | XP Reward |
|---|---|
| Complete a Learn phase | +10 XP |
| Complete a Practice chat | +18 XP |
| Pass a Test | +20 XP |
| Speed Match round | +5–15 XP |
| Daily streak bonus | +5 XP |

Level thresholds: 0 → 200 XP → 500 XP → 1000 XP → …

---

## Design

- **Primary:** `#2ECC71` (Kazakh green)
- **Accent:** `#F39C12` (Speed Match orange)
- **Info:** `#2E86C1` (Chat blue)
- Clean white card UI with bold typography
- Bottom navigation: Home · Chat · Games · Profile

---

## Roadmap

- [ ] Audio pronunciation for every flashcard
- [ ] Live chat with real Kazakh-speaking tutors
- [ ] More lessons: Numbers, Family, Work, Travel
- [ ] Leaderboard between friends
- [ ] Offline mode

---

## About the Project

QTalk is an independent startup project with the mission of making **Kazakh accessible** to the millions of people living in Kazakhstan who want to learn the language but lack engaging, modern tools to do so.

> *"Сәлем, әлем!" — Hello, world!*
