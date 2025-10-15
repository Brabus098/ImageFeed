# ImageFeed - Лента изображений

![Swift](https://img.shields.io/badge/Swift-5.9-FA7343?logo=swift)
![iOS](https://img.shields.io/badge/iOS-13.0+-lightgrey?logo=apple)
![API](https://img.shields.io/badge/API-Unsplash-000000?logo=unsplash)
![OAuth](https://img.shields.io/badge/Auth-OAuth-1E8CBE?logo=auth0)
![UIKit](https://img.shields.io/badge/UI-UIControl-2396F3?logo=apple)

**ImageFeed** - многостраничное iOS-приложение для просмотра бесконечной ленты изображений через API Unsplash. Авторизация через OAuth, возможность лайкать фотографии и добавлять их в избранное.

<p align="center">
  <img src="https://github.com/Brabus098/ImageFeed/blob/main/auth-screen.png?raw=true" width="200" alt="Экран авторизации">
  
  <img src="https://github.com/Brabus098/ImageFeed/blob/main/Loader.png?raw=true" width="200" alt="Загрузка фото">
  <img src="https://github.com/Brabus098/ImageFeed/blob/main/feed-screen.png?raw=true" width="200" alt="Лента изображений">
  <img src="https://github.com/Brabus098/ImageFeed/blob/main/fullscreen-image.png?raw=true" width="200" alt="Просмотр изображения">
    <img src="https://github.com/Brabus098/ImageFeed/blob/main/Sharing.png?raw=true" width="200" alt="Поделиться изображением">
 <img src="https://github.com/Brabus098/ImageFeed/blob/main/profile-screen.png?raw=true" width="200" alt="Профиль пользователя">
  <img src="https://github.com/Brabus098/ImageFeed/blob/main/Exit.png?raw=true" width="200" alt="Выход из системы">


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
```
1) Настройте OAuth в Unsplash Developer Portal
2) Добавьте API keys в проект
3) Выберите симулятор или подключите устройство
4) Нажмите Cmd + R для сборки и запуска

## 🏗 Архитектура
- Проект реализован с использованием MVC архитектуры
- Четкое разделение сетевых запросов и UI логики
- Эффективная работа с UITableView и бесконечной лентой
- Безопасное хранение OAuth токенов в Keychain

## 🎯 Особенности реализации

🔐 OAuth авторизация
- Безопасный обмен кода на access token
- Хранение учетных данных в iOS Keychain
- Обработка сценариев ошибок сети

## 📱 Пользовательский интерфейс
- UITableView с кастомными ячейками для ленты
- TabBarController для навигации между разделами
- Gesture recognizers для полноэкранного просмотра
- System fonts для соответствия гайдлайнам iOS

## 🌐 Сетевое взаимодействие
- REST API Unsplash для загрузки изображений
- URLSession для асинхронных запросов
- Kingfisher/SDWebImage для кэширования изображений
- Error handling с пользовательскими алертами

## 📈 Статус разработки
✅ Завершено
- OAuth авторизация через Unsplash
- Бесконечная лента изображений
- Полноэкранный просмотр с жестами
- Система профиля пользователя
- Навигация через TabBar
- Система лайков и избранного
- Галерея избранных изображений в профиле
- Функционал поделиться и сохранить
- Счетчики лайков и избранного

🔄 В планах
- Кэширование данных для офлайн-работы
- Push-уведомления о новых публикациях
- Расширенная статистика профиля

## 👨‍💻 Автор
Vladimir - iOS Developer

<p align="center"> <a href="https://t.me/Vov4eg777"> <img src="https://img.shields.io/badge/Telegram-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white&color=FA7343" alt="Telegram"/> </a> <a href="mailto:olsh0988@gmail.com"> <img src="https://img.shields.io/badge/Gmail-D14836?style=for-the-badge&logo=gmail&logoColor=white&color=FA7343" alt="Email"/> </a> <a href="https://docs.google.com/document/d/18caT1lR7wfQcId3kl3MaWkGpnjQqEGYBz7goR_59zEw/edit?usp=sharing"> <img src="https://img.shields.io/badge/Resume-4285F4?style=for-the-badge&logo=google-drive&logoColor=white&color=FA7343" alt="Resume"/> </a> </p>
