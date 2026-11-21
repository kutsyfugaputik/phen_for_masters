# phen_for_masters

A new Flutter project.
<div align="center">

<img src="https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExb2p5eXJxM2I3Y2V6eGJ2cWJ6c2N0dXh5Z3J0Z3J0eGZ0cWZ2dSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/3o7aD2saalBwwftBIY/giphy.gif" width="170" alt="Decorative animation" />

# ✦ phen for masters

**Мобильное приложение для мастеров салона красоты «Под феном»**

Управление клиентами, заявками и расписанием, а также просмотр статистики работы мастера в едином Flutter-приложении.

[![Flutter](https://img.shields.io/badge/Flutter-3.7+-54C5F8?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.7+-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev/)
[![Provider](https://img.shields.io/badge/State-Provider-7952B3?style=flat-square)](https://pub.dev/packages/provider)
[![Dio](https://img.shields.io/badge/HTTP-Dio-008ECC?style=flat-square)](https://pub.dev/packages/dio)


<br/>

[О проекте](#-о-проекте) ·
[Возможности](#-возможности) ·
[Технологии](#-технологический-стек) ·
[Запуск](#-запуск-проекта) ·
[Структура](#-структура-проекта)

</div>

---

## ✧ О проекте

**phen for masters** — мобильное приложение для сотрудников салона красоты **«Под феном»**. Оно предназначено для повседневной работы мастера: просмотра клиентской информации, обработки поступивших заявок, контроля предстоящих записей и анализа результатов работы.

Приложение разработано на **Flutter**. Для взаимодействия с серверной частью используется HTTP-клиент Dio, а для управления состоянием интерфейса — Provider. Данные о пользователях, услугах и записях загружаются через API.

## ♡ Возможности

| Раздел | Описание |
|---|---|
| **Авторизация** | Вход в приложение мастера |
| **Главное меню** | Навигация по основным рабочим разделам |
| **Профиль** | Отображение данных пользователя: ФИО, email, телефон и возраст |
| **Клиенты** | Просмотр списка клиентов, связанных с записями мастера |
| **Поиск клиентов** | Фильтрация списка по имени и фамилии |
| **Новые заявки** | Просмотр заявок, ожидающих подтверждения |
| **Управление заявками** | Подтверждение или отмена заявки |
| **Расписание** | Просмотр подтверждённых записей на ближайшие семь дней |
| **Статистика** | Анализ дохода, количества клиентов и востребованных услуг |
| **Графики** | Просмотр распределения доходов по дням и услугам |
| **Настройки оформления** | Изменение темы и параметров отображения текста |
| **Подключение к API** | Настройка адреса сервера и сохранение выбранного URL |

## ✿ Рабочие разделы

### Клиенты

Раздел «Мои клиенты» формирует список пользователей, связанных с заявками текущего мастера. Повторяющиеся клиенты исключаются, список сортируется по имени и фамилии. Предусмотрен поиск по имени.

### Новые заявки

В разделе отображаются заявки, ожидающие подтверждения. Мастер может просмотреть информацию о клиенте и выбранной услуге, а затем подтвердить или отменить заявку.

### Расписание

Раздел «Моё расписание» показывает подтверждённые записи мастера на ближайшую неделю. Для записи отображаются дата, время и связанные сведения о клиенте и услуге.

### Статистика

Статистический раздел позволяет анализировать результаты работы за выбранный месяц. В частности, рассчитываются:

- общий доход за месяц;
- количество уникальных клиентов;
- наиболее востребованная услуга;
- средний возраст клиентов;
- доход по отдельным услугам;
- распределение дохода по дням месяца.

Для визуального представления данных используется библиотека `fl_chart`.

## ⚙️ Технологический стек

| Технология | Назначение |
|---|---|
| **Flutter** | Разработка мобильного приложения |
| **Dart** | Основной язык программирования |
| **Provider** | Управление состоянием и настройками интерфейса |
| **Dio** | HTTP-запросы к серверному API |
| **cookie_jar** | Хранение cookie |
| **dio_cookie_manager** | Управление cookie в HTTP-клиенте |
| **SharedPreferences** | Сохранение пользовательских настроек и адреса API |
| **path_provider** | Получение каталога документов приложения |
| **intl** | Форматирование дат и локализация |
| **fl_chart** | Построение графиков статистики |
| **google_fonts** | Подключение шрифтов |
| **flutter_svg** | Отображение SVG-графики |
| **flutter_staggered_animations** | Анимация элементов интерфейса |
| **flutter_rating_bar** | Компоненты рейтингов |
| **csv** | Работа с CSV-данными |
| **permission_handler** | Работа с разрешениями устройства |
| **logger** | Логирование |

## 🚀 Запуск проекта

### Требования

- Flutter SDK версии, совместимой с Dart SDK `^3.7.0`;
- Android Studio или Visual Studio Code с Flutter-плагином;
- Android-эмулятор или физическое Android-устройство;
- доступ к серверной части проекта.

### 1. Клонирование репозитория

```bash
git clone https://github.com/kutsyfugaputik/phen_for_masters.git
cd phen_for_masters
```

### 2. Установка зависимостей

```bash
flutter pub get
```

### 3. Проверка конфигурации API

В `lib/data/api_service.dart` задаётся базовый адрес API. В текущей версии исходного кода используется адрес:

```text
http://192.168.0.106:5000/api
```

Это локальный сетевой адрес разработческой среды. Для запуска в другой сети необходимо указать актуальный адрес сервера. В приложении предусмотрено сохранение и восстановление изменённого URL.

Устройство или эмулятор должны иметь сетевой доступ к серверу. Если сервер работает на компьютере разработчика, проверьте настройки локальной сети и доступность указанного порта.

### 4. Запуск приложения

```bash
flutter run
```

Для проверки перед запуском можно выполнить:

```bash
flutter analyze
```

## 🔌 Взаимодействие с сервером

Для сетевого взаимодействия используется класс `ApiService`. Он инкапсулирует HTTP-запросы и предоставляет методы для получения данных и выполнения операций.

В приложении используются API-ресурсы, связанные с:

- пользователями;
- мастерами;
- услугами;
- заявками;
- статусами;
- скидками;
- отзывами.

Для работы с пользовательской сессией используется `UserSession`. Сетевой клиент поддерживает cookie и позволяет сохранять адрес API в `SharedPreferences`.

> **Важно:** приложение не является полностью автономным. Для загрузки актуальных клиентов, услуг, заявок и статистики требуется доступная серверная часть и корректно настроенный адрес API.

## 🗂 Структура проекта

```text
phen_for_masters/
│
├── android/                 # Android-конфигурация
├── ios/                     # iOS-конфигурация
├── assets/                  # Изображения, шрифты и другие ресурсы
│
├── lib/
│   ├── data/
│   │   ├── api_service.dart     # HTTP-клиент и методы API
│   │   ├── data_repository.dart # Получение и организация данных
│   │   └── user_session.dart    # Данные текущей сессии
│   │
│   ├── models/                  # Модели пользователей, услуг и заявок
│   ├── screens/                 # Экраны приложения
│   │   ├── splash_screen.dart
│   │   ├── auth_screen.dart
│   │   ├── menu_screen.dart
│   │   ├── clients_screen.dart
│   │   ├── reqs_screen.dart
│   │   ├── schedule_screen.dart
│   │   ├── stats_screen.dart
│   │   └── settings_screen.dart
│   │
│   ├── theme/
│   │   └── settings.dart        # Настройки и тема приложения
│   │
│   ├── widgets/                 # Переиспользуемые элементы интерфейса
│   └── main.dart                # Точка входа
│
├── test/                        # Тесты
├── pubspec.yaml                 # Зависимости и ресурсы Flutter
├── pubspec.lock                 # Зафиксированные версии зависимостей
├── analysis_options.yaml        # Настройки статического анализа
├── README.md
└── LICENSE                         # Лицензия MIT
```

## 📚 Полезные ссылки

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Provider](https://pub.dev/packages/provider)
- [Dio](https://pub.dev/packages/dio)
- [fl_chart](https://pub.dev/packages/fl_chart)

## ✦ Связанные проекты

- [phen_](https://github.com/kutsyfugaputik/phen_) — клиентское мобильное приложение салона «Под феном».
- [rabenda_dezaina](https://github.com/kutsyfugaputik/rabenda_dezaina) — серверная часть и компоненты системы салона.


---

<div align="center">

<sub>phen for masters · Flutter · Dart</sub>

<img src="https://capsule-render.vercel.app/api?type=soft&color=gradient&height=70&section=footer" width="100%" alt="" />

</div>

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
