# ♻️ ReLoop

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white">
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white">
  <img src="https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase&logoColor=black">
  <img src="https://img.shields.io/badge/Firestore-Database-FF6F00?logo=firebase&logoColor=white">
  <img src="https://img.shields.io/badge/Status-MVP%20Complete-0A8F3D">
</p>

<p align="center">
  <b>Reuse. Exchange. Impact.</b><br>
  A campus-focused circular marketplace built with Flutter and Firebase.
</p>

---

## 🌱 About ReLoop

**ReLoop** is a campus marketplace that helps students **sell, exchange, discover, and reuse items** within their college community.

Useful books, electronics, stationery, bags, and other items can get a second life instead of sitting unused or becoming waste.

> ♻️ **Buy less. Reuse more. Create more impact.**

---

## ✨ Highlights

| Feature | Description |
|---|---|
| 🎓 Campus Marketplace | Student-focused buying, selling and exchange |
| 🔎 Search & Discovery | Search, categories and price sorting |
| 📦 Listing Management | Create, publish and manage listings |
| 🤖 AI-Assisted Listing | Suggested title, category, price and eco impact |
| 🤝 Requests | Send, accept and reject exchange requests |
| 💬 Chat | Participant-to-participant messaging |
| 🔔 Notifications | Request, chat and exchange notifications |
| 🚩 Reporting | Report listings and track submitted reports |
| 🌱 Eco Impact | CO₂ savings, reused items and eco points |
| 👤 Profiles | User profile and settings |

---

## 🤖 AI-Assisted Listing

ReLoop includes an AI-style listing assistant that helps users create listings faster.

```text
📦 Item
   ↓
🤖 AI-assisted analysis
   ↓
📝 Suggested Title
📚 Suggested Category
⭐ Suggested Condition
💰 Suggested Price
🌱 Eco Impact
   ↓
✏️ Review / Edit
   ↓
📤 Publish Listing
```

> **Current implementation:** the AI assistant uses a local/mock suggestion flow. A production AI API can be integrated later.

---

## 🔄 Exchange Flow

```text
👤 Student A
     │
     ▼
🔎 Find Listing
     │
     ▼
📨 Send Request
     │
     ▼
👤 Student B
     │
 ┌───┴────┐
 ▼        ▼
✅ Accept  ❌ Reject
 │
 ▼
💬 Chat
 │
 ▼
🔄 Complete Exchange
 │
 ▼
🌱 Eco Impact
```

---

## 🧰 Tech Stack

- 📱 **Frontend:** Flutter
- 💻 **Language:** Dart
- 🔐 **Authentication:** Firebase Authentication
- 🗄️ **Database:** Cloud Firestore
- ☁️ **Backend:** Firebase
- 🎨 **UI:** Flutter Material 3
- 🤖 **AI:** Local/mock AI-assisted workflow
- 🔀 **Version Control:** Git + GitHub

---

## 🏗️ Architecture

```text
┌───────────────────────────────┐
│          📱 Flutter           │
│                               │
│  🏠 Home   🔎 Explore        │
│  ➕ Sell    🌱 Impact         │
│  👤 Profile                   │
└───────────────┬───────────────┘
                │
                ▼
┌───────────────────────────────┐
│          ☁️ Firebase          │
│                               │
│ 🔐 Authentication             │
│ 🗄️ Cloud Firestore            │
│ 🔔 Notifications              │
└───────────────┬───────────────┘
                │
                ▼
        ♻️ ReLoop Community
```

---

## 🗂️ Firestore Structure

```text
users/
├── {userId}
│   └── notifications/
│
listings/
├── {listingId}
│
requests/
├── {requestId}
│
chats/
├── {chatId}
│   └── messages/
│
reports/
└── {reportId}
```

---

## 🔒 Security

Firestore Security Rules are used to protect user-owned data.

- 🔐 Users manage their own profiles
- 📦 Sellers manage their own listings
- 🔄 Requests are restricted to requester/seller participants
- 💬 Chat access is restricted to participants
- 🔔 Notifications are restricted to their owner
- 🚩 Users can create/read their own reports
- 👤 Messages require the authenticated user's `senderId`

> 🔐 A final Firebase production/security review should be completed before public release.

---

## 📱 User Journey

```text
🚀 Launch
  ↓
🔐 Login / Sign Up
  ↓
🏠 Home
  ↓
🔎 Discover
  ↓
📦 View Listing
  ↓
🤝 Send Request
  ↓
🔔 Notification
  ↓
✅ Accept / ❌ Reject
  ↓
💬 Chat
  ↓
🔄 Complete Exchange
  ↓
🌱 Impact
```

---

## 🛠️ Getting Started

### 1️⃣ Clone

```bash
git clone <YOUR_REPOSITORY_URL>
cd reloop
```

### 2️⃣ Install dependencies

```bash
flutter pub get
```

### 3️⃣ Configure Firebase

Connect the project to your Firebase project and ensure the generated Firebase configuration files are available.

### 4️⃣ Run

```bash
flutter run
```

### 5️⃣ Analyze

```bash
flutter analyze
```

---

## 🧪 Testing Checklist

### 🔐 Authentication
- [ ] Sign up
- [ ] Login
- [ ] Profile
- [ ] Logout

### 📦 Listings
- [ ] Create listing
- [ ] AI suggestions
- [ ] Edit suggestions
- [ ] Publish
- [ ] Explore
- [ ] Listing details
- [ ] My Listings

### 🤝 Exchange
- [ ] Send request
- [ ] Accept request
- [ ] Reject request
- [ ] Complete exchange
- [ ] Chat

### 🔔 Notifications
- [ ] Request notification
- [ ] Chat notification
- [ ] Read/unread state

### 🚩 Reports
- [ ] Report listing
- [ ] My Reports
- [ ] Report details
- [ ] Status tracking

### 👥 Multi-user
- [ ] Test requester account
- [ ] Test seller account
- [ ] Verify unauthorized access is blocked

---

## 📊 Development Status

| Module | Feature | Status |
|---|---|:---:|
| 01–04 | Core app foundation | ✅ |
| 05 | Request accept/reject | ✅ |
| 06 | Exchange completion | ✅ |
| 07 | Chat list & inbox | ✅ |
| 08 | Notification triggers | ✅ |
| 09 | Settings & profile | ✅ |
| 10 | Search & discovery | ✅ |
| 11 | Seller dashboard & listing management | ✅ |
| 12 | AI listing & reporting | ✅ |

### 🏁 Current Milestone

**ReLoop MVP — Development Complete ✅**

Final release-readiness tasks:

- 🧪 Full end-to-end testing
- 🔐 Firebase production/security review
- 📦 Android release build
- 👥 Different-user testing
- 🐛 Edge-case testing
- 🎨 UI polish
- 📚 Final documentation
- 🧹 Git cleanup

---

## 📦 Android Release

### APK

```bash
flutter build apk --release
```

### Play Store AAB

```bash
flutter build appbundle --release
```

> Configure Android signing and production Firebase settings before distribution.

---

## 🌍 Vision

ReLoop aims to turn a college campus into a **small circular economy** where useful items continuously move from one student to another.

```text
       📦 ITEM
          ↓
      ♻️ RELOOP
          ↓
   🤝 EXCHANGE / SELL
          ↓
       👤 STUDENT
          ↓
      🌱 IMPACT
```

> ### ♻️ One item reused = one less item wasted.

---

## 👨‍💻 Project

**ReLoop — Campus Circular Marketplace**

Built with ❤️ using **Flutter + Firebase**

### ♻️ Reuse. Exchange. Impact.
