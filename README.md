# ImageFeed - Лента изображений

![Swift](https://img.shields.io/badge/Swift-5.9-FA7343?logo=swift)
![iOS](https://img.shields.io/badge/iOS-13.0+-lightgrey?logo=apple)
![API](https://img.shields.io/badge/API-Unsplash-000000?logo=unsplash)
![OAuth](https://img.shields.io/badge/Auth-OAuth-1E8CBE?logo=auth0)
![UIKit](https://img.shields.io/badge/UI-UIControl-2396F3?logo=apple)

**ImageFeed** - многостраничное iOS-приложение для просмотра бесконечной ленты изображений через API Unsplash. Авторизация через OAuth, возможность лайкать фотографии и добавлять их в избранное.

<p align="center">
  <img src="https://github.com/Brabus098/ImageFeed/blob/main/Screenshots/auth-screen.png?raw=true" width="200" alt="Экран авторизации">
  <img src="https://github.com/Brabus098/ImageFeed/blob/main/Screenshots/feed-screen.png?raw=true" width="200" alt="Лента изображений">
  <img src="https://github.com/Brabus098/ImageFeed/blob/main/Screenshots/profile-screen.png?raw=true" width="200" alt="Профиль пользователя">
  <img src="https://github.com/Brabus098/ImageFeed/blob/main/Screenshots/fullscreen-image.png?raw=true" width="200" alt="Просмотр изображения">
</p>

## 🚀 Возможности

### 🔐 Безопасная авторизация
- **OAuth 2.0** через Unsplash API
- **Автоматический вход** после успешной авторизации
- **Обработка ошибок** с пользовательскими уведомлениями

### 📸 Просмотр контента
- **Бесконечная лента** редакционных изображений Unsplash
- **Полноэкранный просмотр** с масштабированием и жестами
- **Система лайков** с добавлением в избранное
- **Быстрая загрузка** с индикаторами прогресса

### 👤 Профиль пользователя
- **Данные аккаунта** из Unsplash (имя, username, био)
- **Галерея избранных** изображений
- **Выход из аккаунта** с подтверждением

### 🔗 Социальные функции
- **Поделиться изображениями** через системное меню
- **Сохранение фотографий** в галерею устройства
- **Счетчик лайков** и избранного

## 🛠 Технологический стек

**Языки программирования:**  
![Swift](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white)

**iOS Frameworks:**  
![UIKit](https://img.shields.io/badge/UIKit-2396F3?style=for-the-badge&logo=apple&logoColor=white)
![URLSession](https://img.shields.io/badge/Network-URLSession-1E8CBE?style=for-the-badge&logo=apple)
![OAuth](https://img.shields.io/badge/Auth-OAuth_2.0-green?style=for-the-badge)

**Tools & Platforms:**  
![Xcode](https://img.shields.io/badge/Xcode-1575F9?style=for-the-badge&logo=xcode&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)

**Architecture & Methods:**  
![MVC](https://img.shields.io/badge/Architecture-MVC-FA7343?style=for-the-badge)

## ⚙️ Установка и запуск

### Требования
- macOS 13.0+
- Xcode 14.0+
- iOS 13.0+
- Аккаунт Unsplash для доступа к API

### Быстрый старт

```bash
git clone https://github.com/Brabus098/ImageFeed.git
cd ImageFeed
open ImageFeed.xcodeproj
