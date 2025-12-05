# Expense Tracker — Flutter App

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![State%20Mgmt-Riverpod](https://img.shields.io/badge/State%20Mgmt-Riverpod-5C8DBC)](https://riverpod.dev)
[![Router-GoRouter](https://img.shields.io/badge/Router-go__router-blueviolet)](https://pub.dev/packages/go_router)
[![Backend-Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS-lightgrey)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A simple and elegant mobile application built with Flutter to track daily income, expenses, and visualize spending through charts.
Users can sign up, log in, manage their profile, add entries, and monitor financial activity effortlessly.

---

## 🚀 Features
🔐 Authentication

- Email & Password Sign Up
- Login System
- Secure password fields
- Profile completion (Name, Phone Number)

💰 Finance Management

- Add Income
- Add Expenses with category
- Automatically calculates Total Balance
- Shows Income and Expenses separately
- Displays expense history by date

📊 Data Visualization

- Bar Chart view of expense categories
- Line chart visualization for daily spending

🔔 Notifications

- Optional local notification reminder button (based on UI screenshot)

🎨 Modern UI

- Beautiful splash screen
- Clean light & dark style color usage
- Rounded dialogs

Smooth user navigation
---

## 📸 Screenshots

> Place the `screenshots/` folder in your repo root so these links work on GitHub.

<img src="./screenshots/1.jpeg" width="260"  alt=""/> <img src="./screenshots/2.jpeg" width="260" /> <img src="./screenshots/3.jpeg" width="260" />

<img src="./screenshots/4.jpeg" width="260" /> <img src="./screenshots/5.jpeg" width="260" /> <img src="./screenshots/6.jpeg" width="260" />

<img src="./screenshots/7.jpeg" width="260" />

---

## 🎥 Demo
<p><img src="./screenshots/demo.gif" width="420" alt="Quiz Academy demo GIF"/></p>


## 📝 How It Works
1️⃣ User Registration

- User creates an account → logs in → completes profile.

2️⃣ Add Income

- User enters income amount → saved → total balance increases.

3️⃣ Add Expense

- User selects a category → enters amount → saved → total balance decreases.

4️⃣ View History

- Expenses appear grouped by date.

5️⃣ Charts

- Expenses visualized by category and by day.

---

## 🚀 Getting Started

### Setup

```bash
# 1) Clone
git clone https://github.com/amhimel/expense-tracker.git
cd expense-tracker
...

# 2) Install packages
flutter pub get
flutter run
```

### Run
```bash
flutter run
```

---


## 📁 Suggested Folder Structure

```
lib/
 ├── Chart/          
 ├── Model/            
 ├── Provider/           
 ├── Screen/        
 ├── services/        
 ├── Widget/     
 ├── app.dart        
 └── main.dart       


```

---

## 🗺️ Roadmap

- User profiles
- Multi-language support
- Watchlist & history
- Push notifications
- Full trailer playback


---

## 🤝 Contributing

PRs are welcome!  
If you spot UI/UX tweaks, accessibility fixes, or performance improvements, please open an issue first to discuss the change.

---

## 📝 License

MIT © 2025-12-04 — Expense Tracker Contributors
