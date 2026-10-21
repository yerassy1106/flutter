# StudyHub — справочник проекта и исходного кода

Этот документ предназначен для передачи проекта другому ИИ или для подготовки к устной защите. Он описывает приложение и содержит снимок всех актуальных текстовых исходников и конфигураций. Исходной спецификацией остаётся `Lab_01.docx`: при расхождении требований задания с этим справочником следовать Word-файлу. Рабочий каталог проекта является главным источником кода; если код ниже устарел, доверять файлам проекта.

## 1. Назначение приложения

StudyHub — мобильное приложение для просмотра и организации учебных занятий. Категории: математика, программирование, языки, естественные науки и дизайн. Пользователь видит список занятий, ищет и фильтрует его, открывает подробности, записывается/выходит, отмечает избранное, создаёт и редактирует занятия, управляет профилем и темой оформления. Данные хранятся только в памяти приложения и сбрасываются после перезапуска: это учебный проект без базы данных и сети.

## 2. Запуск и окружение

Из корня проекта в PowerShell:

```powershell``
C:\src\flutter\bin\flutter.bat pub get
C:\src\flutter\bin\cache\dart-sdk\bin\dart.exe format .
C:\src\flutter\bin\flutter.bat analyze
C:\src\flutter\bin\flutter.bat test
C:\src\flutter\bin\flutter.bat run -d chrome
`````

На компьютере пользователя были Flutter 3.47.5 и Dart 3.13.4. Chrome запускался пользователем и подключился после долгого ожидания; пользователь проверил интерфейс с размером окна телефона. Последние локальные результаты: форматирование без изменений, `flutter analyze` — `No issues found!`, два теста прошли. Это подтверждает анализ, тесты и Web-запуск. Android-запуск не подтверждён: эмулятор отсутствует, физическое устройство для отладки недоступно. Flutter Android-шаблон уже создан в `android/`. Для Chrome можно запускать `flutter run -d chrome`; для Android после подключения доступного устройства — `flutter run -d <device-id>`.

## 3. Структура проекта

```text``
study_hub/
├── android/                     # стандартная Flutter Android-обвязка
├── web/                         # стандартная Flutter Web-обвязка
├── assets/header.png            # изображение в верхней части деталей
├── test/widget_test.dart        # два теста: модель и экран деталей
├── lib/
│   ├── main.dart                # MyApp, темы и ThemeMode
│   ├── app_router.dart           # генератор detail/form маршрутов
│   ├── routes.dart               # имена маршрутов и типизированные аргументы
│   ├── data/seed.dart            # 12 демонстрационных занятий
│   ├── models/                   # Session, Profile, Subject, Countdown
│   ├── screens/                  # Shell и экраны/вкладки
│   ├── utils/format.dart         # форматирование дат и длительности
│   └── widgets/                  # общие карточки, список, состояния, диалоги
├── pubspec.yaml                  # SDK, зависимости, ресурсы
├── analysis_options.yaml         # flutter_lints
├── README.md                     # запуск, скриншоты, архитектурные решения
├── PROJECT_CONTEXT_RU.md         # краткая памятка
└── PROJECT_REFERENCE_RU.md       # этот справочник и полный текст кода
`````

## 4. Как устроен код

`main.dart` создаёт MaterialApp, определяет светлую/тёмную цветовые схемы и режим темы. `Shell` (`screens/shell.dart`) — корневой экран и единственный владелец изменяемых данных занятий, профиля и активной вкладки. Вкладки расположены в `IndexedStack`, поэтому их состояние сохраняется при переключении; нижняя навигация переключает Sessions, Favourites и Profile. Drawer содержит About и подтверждаемый Reset.

Список отображается через `list_tab.dart`, избранное — через `favourites_tab.dart`, профиль и настройка темы — через `profile_tab.dart`. Переиспользуемая карточка лежит в `widgets/session_card.dart`, а адаптивный ListView/GridView — в `widgets/session_list.dart`; переключение на сетку зависит от доступной ширины. Детали (`detail_screen.dart`) показывают описание, места, участников, обратный отсчёт/статус, кнопки записи и меню действий. Верхняя картинка `assets/header.png` окрашивается цветом категории.

Форма (`form_screen.dart`) используется и для добавления, и для редактирования. Она валидирует обязательные и optional поля, использует клавиатурные/date/time pickers и возвращает `Session` через `Navigator.pop`. Shell ждёт результат; отмена возвращает `null` и не изменяет список. При попытке уйти с изменённой формы появляется подтверждение.

## 5. Модели и правила данных

`Session` описывает занятие: `id`, `title`, `subject`, `starts`, `place`, `limit`, `online`, optional `description`, `favourite`, `attendees`. Производные значения вроде количества/свободных мест, полной группы и прошедшего занятия рассчитываются из полей. `places` возвращает record с занятыми и свободными местами. Занятие считается прошедшим после его условной длительности. `Session.withAttendees` копирует список участников в неизменяемый список; тест проверяет, что изменение исходного списка не меняет Session и что getter нельзя модифицировать. `copyWith` создаёт обновлённую модель.

`Profile` содержит имя и группу. `Subject` — enhanced enum пяти категорий с подписью, иконкой и исчерпывающим switch для цвета из ColorScheme. `Countdown` — sealed-типы Upcoming, Started и Ended; детальный экран обрабатывает все варианты switch-выражением. Seed-функция создаёт 12 относительных по дате демонстрационных занятий, включая граничный 60-символьный заголовок, полную группу, прошедшие занятия, online и отсутствие optional description.

## 6. Как меняются данные и открываются экраны

Shell передаёт вкладкам модели и callback-функции, через которые те сообщают об изменениях. Для detail Shell открывает именованный маршрут и передаёт `DetailArgs`: занятие, профильное имя и callbacks на изменение/удаление/переход к профилю. Для формы передаётся `FormArgs`; её результат возвращается вызывающему Shell через Navigator. Именованные маршруты и типы аргументов объявлены в `routes.dart`, сборка экранов — в `app_router.dart`. Данные не дублируются по экранам и не сохраняются за пределами процесса.

## 7. Проверки и ограниченные пункты сдачи

| Пункт | Текущее состояние |
| --- | --- |
| Форматирование (R39) | `dart format .` завершилось без diff |
| Статический анализ (R39) | `flutter analyze`: `No issues found!` |
| Тесты | `flutter test`: 2 прошли |
| Web | Пользователь запустил приложение в Chrome; Android запуск отдельно не проверен |
| Скриншоты (R41) | Нужны настоящие `docs/phone_light.png`, `docs/phone_dark.png`, `docs/tablet_grid.png`; их ещё нет |
| Git-история (R40) | В исходном ZIP не было `.git`; нет требуемой истории из 12 содержательных коммитов |
| GitHub | Не настроен remote, проект не опубликован |

Не создавайте фиктивную историю задним числом и не утверждайте, что Android проверен. Для GitHub нужен репозиторий/адрес remote. Скриншоты нужно получить из реально работающего приложения в трёх требуемых режимах.

## 8. Правила продолжения работы для другого ИИ

Прочитай это руководство, README и рабочие файлы. Если предоставлен `Lab_01.docx`, используй его как спецификацию и проверяй, какие R-пункты затрагивает каждая правка. Сохраняй владение состоянием в Shell, callback/route-потоки и работу без внешних runtime-зависимостей, если это требует задание. Не меняй внешний вид или поведение без причины, связанной с условием или багом. Перед выводом сообщи, что изменено и какие команды действительно запускались. Перед публикацией спроси адрес GitHub remote; не выдумывай коммиты, скриншоты или тесты.

# Приложение. Актуальный текст исходников и конфигурации

Ниже снимок актуальных текстовых файлов относительно корня проекта. Изображения и другие бинарные ресурсы лежат в самом каталоге проекта; Android `local.properties` с путями конкретного компьютера и сборочные/IDE-файлы не включены.

## `.gitignore`

``gitignore``
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.build/
.buildlog/
.history
.svn/
.swiftpm/
migrate_working_dir/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# The .vscode folder contains launch configuration and tasks you configure in
# VS Code which you may wish to be included in version control, so this line
# is commented out by default.
#.vscode/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins-dependencies
.pub-cache/
.pub/
/build/
/coverage/

# Symbolication related
app.*.symbols

# Obfuscation related
app.*.map.json

# Android Studio will place build artifacts here
/android/app/debug
/android/app/profile
/android/app/release

# Widget Preview related
.widget_preview/
````

## `.metadata`

``yaml``
# This file tracks properties of this Flutter project.
# Used by Flutter tool to assess capabilities and perform upgrades etc.
#
# This file should be version controlled and should not be manually edited.

version:
  revision: "6a19cca56475dbfba1478ee68d7bd0c2ef891da1"
  channel: "stable"

project_type: app

# Tracks metadata for the flutter migrate command
migration:
  platforms:
    - platform: root
      create_revision: 6a19cca56475dbfba1478ee68d7bd0c2ef891da1
      base_revision: 6a19cca56475dbfba1478ee68d7bd0c2ef891da1
    - platform: android
      create_revision: 6a19cca56475dbfba1478ee68d7bd0c2ef891da1
      base_revision: 6a19cca56475dbfba1478ee68d7bd0c2ef891da1

  # User provided section

  # List of Local paths (relative to this file) that should be
  # ignored by the migrate tool.
  #
  # Files that are not part of the templates will be ignored by default.
  unmanaged_files:
    - 'lib/main.dart'
    - 'ios/Runner.xcodeproj/project.pbxproj'
````

## `analysis_options.yaml`

``yaml``
analyzer:
  exclude:
    - build/**
    - web/**
    - android/**
include: package:flutter_lints/flutter.yaml
````



## `.gitignore`

``gitignore``
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.build/
.buildlog/
.history
.svn/
.swiftpm/
migrate_working_dir/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# The .vscode folder contains launch configuration and tasks you configure in
# VS Code which you may wish to be included in version control, so this line
# is commented out by default.
#.vscode/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins-dependencies
.pub-cache/
.pub/
/build/
/coverage/

# Symbolication related
app.*.symbols

# Obfuscation related
app.*.map.json

# Android Studio will place build artifacts here
/android/app/debug
/android/app/profile
/android/app/release

# Widget Preview related
.widget_preview/
````

## `.metadata`

``yaml``
# This file tracks properties of this Flutter project.
# Used by Flutter tool to assess capabilities and perform upgrades etc.
#
# This file should be version controlled and should not be manually edited.

version:
  revision: "6a19cca56475dbfba1478ee68d7bd0c2ef891da1"
  channel: "stable"

project_type: app

# Tracks metadata for the flutter migrate command
migration:
  platforms:
    - platform: root
      create_revision: 6a19cca56475dbfba1478ee68d7bd0c2ef891da1
      base_revision: 6a19cca56475dbfba1478ee68d7bd0c2ef891da1
    - platform: android
      create_revision: 6a19cca56475dbfba1478ee68d7bd0c2ef891da1
      base_revision: 6a19cca56475dbfba1478ee68d7bd0c2ef891da1

  # User provided section

  # List of Local paths (relative to this file) that should be
  # ignored by the migrate tool.
  #
  # Files that are not part of the templates will be ignored by default.
  unmanaged_files:
    - 'lib/main.dart'
    - 'ios/Runner.xcodeproj/project.pbxproj'
````

## `analysis_options.yaml`

``yaml``
analyzer:
  exclude:
    - build/**
    - web/**
    - android/**
include: package:flutter_lints/flutter.yaml
````

## `pubspec.lock`

``yaml``
# Generated by pub
# See https://dart.dev/tools/pub/glossary#lockfile
packages:
  async:
    dependency: transitive
    description:
      name: async
      sha256: e2eb0491ba5ddb6177742d2da23904574082139b07c1e33b8503b9f46f3e1a37
      url: "https://pub.dev"
    source: hosted
    version: "2.13.1"
  boolean_selector:
    dependency: transitive
    description:
      name: boolean_selector
      sha256: "8aab1771e1243a5063b8b0ff68042d67334e3feab9e95b9490f9a6ebf73b42ea"
      url: "https://pub.dev"
    source: hosted
    version: "2.1.2"
  characters:
    dependency: transitive
    description:
      name: characters
      sha256: faf38497bda5ead2a8c7615f4f7939df04333478bf32e4173fcb06d428b5716b
      url: "https://pub.dev"
    source: hosted
    version: "1.4.1"
  clock:
    dependency: transitive
    description:
      name: clock
      sha256: e51d50bca3217c9a9fa2b41a30e4a38971133f5f9ec7a3d57bae095007f1d28e
      url: "https://pub.dev"
    source: hosted
    version: "1.1.3"
  collection:
    dependency: transitive
    description:
      name: collection
      sha256: "2f5709ae4d3d59dd8f7cd309b4e023046b57d8a6c82130785d2b0e5868084e76"
      url: "https://pub.dev"
    source: hosted
    version: "1.19.1"
  fake_async:
    dependency: transitive
    description:
      name: fake_async
      sha256: "5368f224a74523e8d2e7399ea1638b37aecfca824a3cc4dfdf77bf1fa905ac44"
      url: "https://pub.dev"
    source: hosted
    version: "1.3.3"
  flutter:
    dependency: "direct main"
    description: flutter
    source: sdk
    version: "0.0.0"
  flutter_lints:
    dependency: "direct dev"
    description:
      name: flutter_lints
      sha256: "3105dc8492f6183fb076ccf1f351ac3d60564bff92e20bfc4af9cc1651f4e7e1"
      url: "https://pub.dev"
    source: hosted
    version: "6.0.0"
  flutter_test:
    dependency: "direct dev"
    description: flutter
    source: sdk
    version: "0.0.0"
  leak_tracker:
    dependency: transitive
    description:
      name: leak_tracker
      sha256: "33e2e26bdd85a0112ec15400c8cbffea70d0f9c3407491f672a2fad47915e2de"
      url: "https://pub.dev"
    source: hosted
    version: "11.0.2"
  leak_tracker_flutter_testing:
    dependency: transitive
    description:
      name: leak_tracker_flutter_testing
      sha256: "1dbc140bb5a23c75ea9c4811222756104fbcd1a27173f0c34ca01e16bea473c1"
      url: "https://pub.dev"
    source: hosted
    version: "3.0.10"
  leak_tracker_testing:
    dependency: transitive
    description:
      name: leak_tracker_testing
      sha256: "8d5a2d49f4a66b49744b23b018848400d23e54caf9463f4eb20df3eb8acb2eb1"
      url: "https://pub.dev"
    source: hosted
    version: "3.0.2"
  lints:
    dependency: transitive
    description:
      name: lints
      sha256: "12f842a479589fea194fe5c5a3095abc7be0c1f2ddfa9a0e76aed1dbd26a87df"
      url: "https://pub.dev"
    source: hosted
    version: "6.1.0"
  matcher:
    dependency: transitive
    description:
      name: matcher
      sha256: "31bd099b47c10cd1aeb55146a2d46ce0277630ecef3f7dae54ad7873f36696cd"
      url: "https://pub.dev"
    source: hosted
    version: "0.12.20"
  material_color_utilities:
    dependency: transitive
    description:
      name: material_color_utilities
      sha256: "9c337007e82b1889149c82ed242ed1cb24a66044e30979c44912381e9be4c48b"
      url: "https://pub.dev"
    source: hosted
    version: "0.13.0"
  meta:
    dependency: transitive
    description:
      name: meta
      sha256: c82594181e3312f3d0695fc95aaaf7758d75b8d4ae2bbecf223b9fd5109a059d
      url: "https://pub.dev"
    source: hosted
    version: "1.18.3"
  path:
    dependency: transitive
    description:
      name: path
      sha256: "75cca69d1490965be98c73ceaea117e8a04dd21217b37b292c9ddbec0d955bc5"
      url: "https://pub.dev"
    source: hosted
    version: "1.9.1"
  sky_engine:
    dependency: transitive
    description: flutter
    source: sdk
    version: "0.0.0"
  source_span:
    dependency: transitive
    description:
      name: source_span
      sha256: "56a02f1f4cd1a2d96303c0144c93bd6d909eea6bee6bf5a0e0b685edbd4c47ab"
      url: "https://pub.dev"
    source: hosted
    version: "1.10.2"
  stack_trace:
    dependency: transitive
    description:
      name: stack_trace
      sha256: "277654b3034d17ac6f9f1cb5595db011b1d5d41e8806866db28e0abaa101c490"
      url: "https://pub.dev"
    source: hosted
    version: "1.12.2"
  stream_channel:
    dependency: transitive
    description:
      name: stream_channel
      sha256: "969e04c80b8bcdf826f8f16579c7b14d780458bd97f56d107d3950fdbeef059d"
      url: "https://pub.dev"
    source: hosted
    version: "2.1.4"
  string_scanner:
    dependency: transitive
    description:
      name: string_scanner
      sha256: "921cd31725b72fe181906c6a94d987c78e3b98c2e205b397ea399d4054872b43"
      url: "https://pub.dev"
    source: hosted
    version: "1.4.1"
  term_glyph:
    dependency: transitive
    description:
      name: term_glyph
      sha256: "7f554798625ea768a7518313e58f83891c7f5024f88e46e7182a4558850a4b8e"
      url: "https://pub.dev"
    source: hosted
    version: "1.2.2"
  test_api:
    dependency: transitive
    description:
      name: test_api
      sha256: "2a122cbe059f8b610d3a5415f42e255b6c17b1f21eee1d960f31080237fb4f11"
      url: "https://pub.dev"
    source: hosted
    version: "0.7.12"
  vector_math:
    dependency: transitive
    description:
      name: vector_math
      sha256: "1d774bbdf6b72a0b12122fc1560c9c2d2a67db5a4a4cc2bd8a5c990ab20e3188"
      url: "https://pub.dev"
    source: hosted
    version: "2.4.0"
  vm_service:
    dependency: transitive
    description:
      name: vm_service
      sha256: "89b11d62e1040ee681af3b4f1c97a803ecbf010c6e8b9c5896ee5b08c3bf7b78"
      url: "https://pub.dev"
    source: hosted
    version: "15.4.0"
sdks:
  dart: ">=3.11.0-0 <4.0.0"
  flutter: ">=3.18.0-18.0.pre.54"
````

## `pubspec.yaml`

``yaml``
name: study_hub
description: StudyHub - study sessions app (Mobile Development, Lab 1).
publish_to: none
version: 1.0.0+1

environment:
  sdk: ^3.8.0

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/header.png
````

## `README.md`

``md``
# StudyHub

Mobile Development, Lab 1. A multi-screen Flutter app for **study sessions**:
each session has a title, a subject (math, coding, languages, science, design),
a start time, a place (or a link when it is online), a limit of places and a
list of people who joined. All data lives in memory.

## Screenshots

The submission requires three screenshots: phone in light theme, phone in dark
theme, and tablet in grid layout. They were not included in the supplied archive
and must be captured from the running app and added under `docs/` before submission.

## Run

`````
flutter pub get
flutter run
`````

## Decisions

The list of sessions and the profile live in the shell's State, because three tabs, the detail and the form all read or change them, and State is the lowest common ancestor. Tabs receive them as constructor parameters and send changes up through callbacks. The detail takes callbacks through its route arguments because it is a pushed screen that covers the shell, so it has no other way to change the list or to ask the shell to switch to the profile tab. The form returns a value through `pop` instead of calling a callback: the caller awaits the result, ignores `null` (back out) and only then calls `setState`, so a cancelled form changes nothing. The list is a `LayoutBuilder` and not `MediaQuery` because the widget must react to the width it is actually given, not to the width of the whole screen. The `PopScope` compares a snapshot of all form values with the snapshot taken when the form opened, so typing a letter and deleting it again does not count as a change. With week 9's tools I would move the sessions and the profile out of the shell's State into a state-management solution, so that tabs and pushed screens read them directly instead of through long callback chains.
````

## `study_hub.iml`

``iml``
<?xml version="1.0" encoding="UTF-8"?>
<module type="JAVA_MODULE" version="4">
  <component name="NewModuleRootManager" inherit-compiler-output="true">
    <exclude-output />
    <content url="file://$MODULE_DIR$">
      <sourceFolder url="file://$MODULE_DIR$/lib" isTestSource="false" />
      <sourceFolder url="file://$MODULE_DIR$/test" isTestSource="true" />
      <excludeFolder url="file://$MODULE_DIR$/.dart_tool" />
      <excludeFolder url="file://$MODULE_DIR$/.idea" />
      <excludeFolder url="file://$MODULE_DIR$/build" />
    </content>
    <orderEntry type="sourceFolder" forTests="false" />
    <orderEntry type="library" name="Dart SDK" level="project" />
    <orderEntry type="library" name="Flutter Plugins" level="project" />
    <orderEntry type="library" name="Dart Packages" level="project" />
  </component>
</module>
````

## `android/.gitignore`

``gitignore``
gradle-wrapper.jar
/.gradle
/captures/
/gradlew
/gradlew.bat
/local.properties
GeneratedPluginRegistrant.java
.cxx/

# Remember to never publicly share your keystore.
# See https://flutter.dev/to/reference-keystore
key.properties
**/*.keystore
**/*.jks
````

## `android/build.gradle.kts`

``kts``
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
````

## `android/gradle.properties`

``properties``
org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=4G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
# This newDsl flag was added by the Flutter template
android.newDsl=false
# This builtInKotlin flag was added by the Flutter template
android.builtInKotlin=false
````

## `android/settings.gradle.kts`

``kts``
pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.1.0" apply false
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
}

include(":app")
````

## `android/study_hub_android.iml`

``iml``
<?xml version="1.0" encoding="UTF-8"?>
<module type="JAVA_MODULE" version="4">
  <component name="FacetManager">
    <facet type="android" name="Android">
      <configuration>
        <option name="ALLOW_USER_CONFIGURATION" value="false" />
        <option name="GEN_FOLDER_RELATIVE_PATH_APT" value="/gen" />
        <option name="GEN_FOLDER_RELATIVE_PATH_AIDL" value="/gen" />
        <option name="MANIFEST_FILE_RELATIVE_PATH" value="/app/src/main/AndroidManifest.xml" />
        <option name="RES_FOLDER_RELATIVE_PATH" value="/app/src/main/res" />
        <option name="ASSETS_FOLDER_RELATIVE_PATH" value="/app/src/main/assets" />
        <option name="LIBS_FOLDER_RELATIVE_PATH" value="/app/src/main/libs" />
        <option name="PROGUARD_LOGS_FOLDER_RELATIVE_PATH" value="/app/src/main/proguard_logs" />
      </configuration>
    </facet>
  </component>
  <component name="NewModuleRootManager" inherit-compiler-output="true">
    <exclude-output />
    <content url="file://$MODULE_DIR$">
      <sourceFolder url="file://$MODULE_DIR$/app/src/main/java" isTestSource="false" />
      <sourceFolder url="file://$MODULE_DIR$/app/src/main/kotlin" isTestSource="false" />
      <sourceFolder url="file://$MODULE_DIR$/gen" isTestSource="false" generated="true" />
    </content>
    <orderEntry type="jdk" jdkName="Android API 24 Platform" jdkType="Android SDK" />
    <orderEntry type="sourceFolder" forTests="false" />
    <orderEntry type="library" name="Flutter for Android" level="project" />
    <orderEntry type="library" name="KotlinJavaRuntime" level="project" />
  </component>
</module>
````

## `android/app/build.gradle.kts`

``kts``
plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.study_hub"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.study_hub"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
````

## `android/app/src/debug/AndroidManifest.xml`

``xml``
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- The INTERNET permission is required for development. Specifically,
         the Flutter tool needs it to communicate with the running application
         to allow setting breakpoints, to provide hot reload, etc.
    -->
    <uses-permission android:name="android.permission.INTERNET"/>
</manifest>
````

## `android/app/src/main/AndroidManifest.xml`

``xml``
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="study_hub"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <!-- Specifies an Android theme to apply to this Activity as soon as
                 the Android process has started. This theme is visible to the user
                 while the Flutter UI initializes. After that, this theme continues
                 to determine the Window background behind the Flutter UI. -->
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <!-- Don't delete the meta-data below.
             This is used by the Flutter tool to generate GeneratedPluginRegistrant.java -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
    <!-- Required to query activities that can process text, see:
         https://developer.android.com/training/package-visibility and
         https://developer.android.com/reference/android/content/Intent#ACTION_PROCESS_TEXT.

         In particular, this is used by the Flutter engine in io.flutter.plugin.text.ProcessTextPlugin. -->
    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
    </queries>
</manifest>
````

## `android/app/src/main/kotlin/com/example/study_hub/MainActivity.kt`

``kt``
package com.example.study_hub

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
````

## `android/app/src/main/res/drawable/launch_background.xml`

``xml``
<?xml version="1.0" encoding="utf-8"?>
<!-- Modify this file to customize your launch splash screen -->
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@android:color/white" />

    <!-- You can insert your own image assets here -->
    <!-- <item>
        <bitmap
            android:gravity="center"
            android:src="@mipmap/launch_image" />
    </item> -->
</layer-list>
````

## `android/app/src/main/res/drawable-v21/launch_background.xml`

``xml``
<?xml version="1.0" encoding="utf-8"?>
<!-- Modify this file to customize your launch splash screen -->
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="?android:colorBackground" />

    <!-- You can insert your own image assets here -->
    <!-- <item>
        <bitmap
            android:gravity="center"
            android:src="@mipmap/launch_image" />
    </item> -->
</layer-list>
````

## `android/app/src/main/res/values/styles.xml`

``xml``
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Theme applied to the Android Window while the process is starting when the OS's Dark Mode setting is off -->
    <style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <!-- Show a splash screen on the activity. Automatically removed when
             the Flutter engine draws its first frame -->
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    <!-- Theme applied to the Android Window as soon as the process has started.
         This theme determines the color of the Android Window while your
         Flutter UI initializes, as well as behind your Flutter UI while its
         running.

         This Theme is only used starting with V2 of Flutter's Android embedding. -->
    <style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">?android:colorBackground</item>
    </style>
</resources>
````

## `android/app/src/main/res/values-night/styles.xml`

``xml``
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Theme applied to the Android Window while the process is starting when the OS's Dark Mode setting is on -->
    <style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <!-- Show a splash screen on the activity. Automatically removed when
             the Flutter engine draws its first frame -->
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    <!-- Theme applied to the Android Window as soon as the process has started.
         This theme determines the color of the Android Window while your
         Flutter UI initializes, as well as behind your Flutter UI while its
         running.

         This Theme is only used starting with V2 of Flutter's Android embedding. -->
    <style name="NormalTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">?android:colorBackground</item>
    </style>
</resources>
````

## `android/app/src/profile/AndroidManifest.xml`

``xml``
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- The INTERNET permission is required for development. Specifically,
         the Flutter tool needs it to communicate with the running application
         to allow setting breakpoints, to provide hot reload, etc.
    -->
    <uses-permission android:name="android.permission.INTERNET"/>
</manifest>
````

## `android/gradle/wrapper/gradle-wrapper.properties`

``properties``
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-9.3.1-all.zip
````

## `lib/app_router.dart`

``dart``
import 'package:flutter/material.dart';

import 'models/session.dart';
import 'routes.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';

/// R25: builds detail and form from typed argument classes.
Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.detail:
      if (settings.arguments case final DetailArgs args) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) => DetailScreen(args: args),
        );
      }
    case Routes.form:
      if (settings.arguments case final FormArgs args) {
        return MaterialPageRoute<Session>(
          settings: settings,
          builder: (context) => FormScreen(args: args),
        );
      }
  }
  return null;
}

Route<dynamic> onUnknownRoute(RouteSettings settings) {
  return MaterialPageRoute<void>(
    settings: settings,
    builder: (context) => Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: const Center(child: Text('Not found')),
    ),
  );
}
````

## `lib/main.dart`

``dart``
import 'package:flutter/material.dart';

import 'app_router.dart';
import 'routes.dart';
import 'screens/shell.dart';

// The single colour literal in lib/: the seed of both colour schemes.
const _seed = Color(0xFF3F51B5);

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // R11: ThemeMode lives here, above MaterialApp.
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) => setState(() => _themeMode = mode);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyHub',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: _seed)),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      initialRoute: Routes.home,
      routes: {
        Routes.home: (context) =>
            Shell(themeMode: _themeMode, onThemeMode: _setThemeMode),
      },
      onGenerateRoute: onGenerateRoute,
      onUnknownRoute: onUnknownRoute,
    );
  }
}
````

## `lib/routes.dart`

``dart``
import 'package:flutter/foundation.dart';

import 'models/session.dart';

/// R25: the only place with route-name literals.
abstract final class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const form = '/form';
}

/// R26: the detail gets the item AND callbacks through route arguments.
class DetailArgs {
  const DetailArgs({
    required this.session,
    required this.userName,
    required this.onChanged,
    required this.onDelete,
    required this.onOpenProfile,
  });

  final Session session;
  final String userName;
  final ValueChanged<Session> onChanged;
  final ValueChanged<String> onDelete;
  final VoidCallback onOpenProfile;
}

/// R26: the form receives Session? (null = new) and returns a Session via pop.
class FormArgs {
  const FormArgs({this.session});

  final Session? session;
}
````

## `lib/data/seed.dart`

``dart``
import '../models/session.dart';
import '../models/subject.dart';

const _people = [
  'Aigerim', 'Dana', 'Timur', 'Madina', 'Alikhan', 'Sofia', //
  'Arman', 'Laura', 'Nurlan', 'Aya', 'Daniyar', 'Zhanna',
];

List<String> _names(int n) => _people.take(n).toList();

/// Twelve seed items, dates relative to today.
List<Session> buildSeed() {
  final now = DateTime.now();
  DateTime at(int days, int hour, [int minute = 0]) =>
      DateTime(now.year, now.month, now.day + days, hour, minute);

  return [
    Session.withAttendees(
      id: 's1',
      title: 'Calculus office hours',
      subject: Subject.math,
      starts: at(1, 10),
      place: 'Room 204',
      limit: 12,
      online: false,
      description: 'Bring your problem sets and questions.',
      attendees: _names(4),
    ),
    Session.withAttendees(
      id: 's2',
      title: 'Flutter widgets crash course',
      subject: Subject.coding,
      starts: at(2, 15),
      place: 'Lab 3.1',
      limit: 8,
      online: false,
      description: 'Layouts, state and navigation in two hours.',
      attendees: _names(5),
      favourite: true,
    ),
    // Mandatory: a 60-character title.
    Session.withAttendees(
      id: 's3',
      title: 'Intensive Linear Algebra and Differential Equations Marathon',
      subject: Subject.math,
      starts: at(3, 9),
      place: 'Main hall',
      limit: 30,
      online: false,
      description: 'A long revision day before the exam.',
      attendees: _names(9),
    ),
    // Mandatory: an item at its limit.
    Session.withAttendees(
      id: 's4',
      title: 'Spanish conversation club',
      subject: Subject.languages,
      starts: at(3, 17, 30),
      place: 'Library cafe',
      limit: 6,
      online: false,
      description: 'Relaxed speaking practice.',
      attendees: _names(6),
    ),
    // Mandatory: a past item.
    Session.withAttendees(
      id: 's5',
      title: 'Organic chemistry lab prep',
      subject: Subject.science,
      starts: at(-2, 14),
      place: 'Lab 1.2',
      limit: 15,
      online: false,
      attendees: _names(9),
    ),
    // Mandatory: mode on (place is a link) and no optional text.
    Session.withAttendees(
      id: 's6',
      title: 'UI design critique',
      subject: Subject.design,
      starts: at(4, 12),
      place: 'https://meet.example.org/ui-critique',
      limit: 30,
      online: true,
      attendees: _names(8),
    ),
    Session.withAttendees(
      id: 's7',
      title: 'IELTS speaking practice',
      subject: Subject.languages,
      starts: at(5, 16),
      place: 'Room 118',
      limit: 10,
      online: false,
      description: 'Mock interviews in pairs.',
      attendees: _names(8),
      favourite: true,
    ),
    Session.withAttendees(
      id: 's8',
      title: 'Python for data analysis',
      subject: Subject.coding,
      starts: at(6, 19),
      place: 'https://meet.example.org/python-data',
      limit: 40,
      online: true,
      description: 'pandas basics with a small dataset.',
      attendees: _names(12),
    ),
    // Started 40 minutes ago, nobody on the list yet.
    Session.withAttendees(
      id: 's9',
      title: 'Probability problem solving',
      subject: Subject.math,
      starts: now.subtract(const Duration(minutes: 40)),
      place: 'Room 310',
      limit: 20,
      online: false,
      description: 'Dice, cards and Bayes.',
    ),
    Session.withAttendees(
      id: 's10',
      title: 'Physics lab report help',
      subject: Subject.science,
      starts: at(-5, 13),
      place: 'Lab 2.4',
      limit: 10,
      online: false,
      description: 'How to write the error analysis section.',
      attendees: _names(6),
    ),
    Session.withAttendees(
      id: 's11',
      title: 'Figma basics workshop',
      subject: Subject.design,
      starts: at(9, 14),
      place: 'Studio B',
      limit: 13,
      online: false,
      description: 'Frames, auto layout and components.',
      attendees: _names(11),
    ),
    Session.withAttendees(
      id: 's12',
      title: 'Data structures study group',
      subject: Subject.coding,
      starts: at(10, 18),
      place: 'Room 207',
      limit: 25,
      online: false,
      description: 'Trees and graphs, weekly.',
      attendees: _names(7),
    ),
  ];
}
````

## `lib/models/countdown.dart`

``dart``
import 'session.dart';

/// R9: sealed class, rendered by an exhaustive switch.
sealed class Countdown {
  const Countdown();

  factory Countdown.of(Session session, DateTime now) {
    final diff = session.starts.difference(now);
    if (diff > Duration.zero) {
      return Upcoming(diff);
    }
    final since = -diff;
    if (since < Session.length) {
      return Started(since);
    }
    return const Ended();
  }
}

final class Upcoming extends Countdown {
  const Upcoming(this.left);
  final Duration left;
}

final class Started extends Countdown {
  const Started(this.since);
  final Duration since;
}

final class Ended extends Countdown {
  const Ended();
}
````

## `lib/models/profile.dart`

``dart``
import 'package:flutter/foundation.dart';

@immutable
class Profile {
  const Profile({required this.name, required this.group});

  /// R3
  const Profile.empty() : name = '', group = '';

  final String name;
  final String group;

  Profile copyWith({String? name, String? group}) {
    return Profile(name: name ?? this.name, group: group ?? this.group);
  }
}
````

## `lib/models/session.dart`

``dart``
import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'subject.dart';

/// The main model (R1): immutable, const constructor, copyWith.
@immutable
class Session {
  const Session({
    required this.id,
    required this.title,
    required this.subject,
    required this.starts,
    required this.place,
    required this.limit,
    required this.online,
    this.description,
    this.favourite = false,
  }) : _attendees = const [];

  /// Copies the supplied names so later changes to the caller's list cannot
  /// mutate this model.
  factory Session.withAttendees({
    required String id,
    required String title,
    required Subject subject,
    required DateTime starts,
    required String place,
    required int limit,
    required bool online,
    String? description,
    Iterable<String> attendees = const [],
    bool favourite = false,
  }) {
    return Session._(
      id: id,
      title: title,
      subject: subject,
      starts: starts,
      place: place,
      limit: limit,
      online: online,
      description: description,
      attendees: List<String>.unmodifiable(attendees),
      favourite: favourite,
    );
  }

  const Session._({
    required this.id,
    required this.title,
    required this.subject,
    required this.starts,
    required this.place,
    required this.limit,
    required this.online,
    required this.description,
    required List<String> attendees,
    required this.favourite,
  }) : _attendees = attendees;

  /// R3: defaults for a new item.
  factory Session.empty() {
    final now = DateTime.now();
    return Session.withAttendees(
      id: '',
      title: '',
      subject: Subject.math,
      starts: DateTime(now.year, now.month, now.day + 1, 18),
      place: '',
      limit: 10,
      online: false,
    );
  }

  /// How long a session lasts (used by the countdown and isPast).
  static const Duration length = Duration(hours: 2);

  final String id;
  final String title;
  final Subject subject;
  final DateTime starts;
  final String place;
  final int limit;

  /// Mode: when true, [place] is a link instead of a room.
  final bool online;

  /// Optional text, shown only when present.
  final String? description;
  final bool favourite;

  final List<String> _attendees;

  /// R1: read-only view, the list cannot be mutated from outside.
  List<String> get attendees => UnmodifiableListView(_attendees);

  // R4: derived values are getters, never fields.
  int get count => _attendees.length;
  int get freePlaces => limit > count ? limit - count : 0;
  bool get isFull => count >= limit;
  bool get isPast => starts.add(length).isBefore(DateTime.now());
  bool contains(String name) => _attendees.contains(name);

  /// R5: record getter.
  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  Session copyWith({
    String? id,
    String? title,
    Subject? subject,
    DateTime? starts,
    String? place,
    int? limit,
    bool? online,
    String? description,
    bool clearDescription = false,
    List<String>? attendees,
    bool? favourite,
  }) {
    return Session.withAttendees(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      starts: starts ?? this.starts,
      place: place ?? this.place,
      limit: limit ?? this.limit,
      online: online ?? this.online,
      description: clearDescription ? null : (description ?? this.description),
      attendees: attendees ?? _attendees,
      favourite: favourite ?? this.favourite,
    );
  }
}
````

## `lib/models/subject.dart`

``dart``
import 'package:flutter/material.dart';

/// Category of a study session (enhanced enum: label + icon).
enum Subject {
  math('Math', Icons.functions),
  coding('Coding', Icons.code),
  languages('Languages', Icons.translate),
  science('Science', Icons.science_outlined),
  design('Design', Icons.palette_outlined);

  const Subject(this.label, this.icon);

  final String label;
  final IconData icon;

  /// R2: exhaustive switch expression -> a colorScheme role.
  Color color(ColorScheme scheme) => switch (this) {
    Subject.math => scheme.primary,
    Subject.coding => scheme.secondary,
    Subject.languages => scheme.tertiary,
    Subject.science => scheme.error,
    Subject.design => scheme.onSurfaceVariant,
  };
}
````

## `lib/screens/detail_screen.dart`

``dart``
import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/session.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/dialogs.dart';
import '../widgets/empty_state.dart';

enum _MenuAction { edit, delete }

/// R9: exhaustive switch over the sealed class.
String _countdownText(Countdown c) => switch (c) {
  Upcoming(:final left) => 'Starts in ${formatDuration(left)}',
  Started(:final since) => 'Started ${formatDuration(since)} ago',
  Ended() => 'Ended',
};

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Session _s = widget.args.session;
  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // R13: one-minute timer, created here, cancelled in dispose.
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!mounted) {
        return;
      }
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ---- actions ----

  /// R15: the primary action asks first; empty name -> SnackBar.
  Future<void> _join() async {
    final name = widget.args.userName;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enter your name in the profile first'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: widget.args.onOpenProfile,
          ),
        ),
      );
      return;
    }
    final ok = await confirm(
      context,
      title: 'Join this session?',
      message: '${_s.title}\n${formatDateTime(_s.starts)}',
      confirmLabel: 'Join',
    );
    if (!ok || !mounted) {
      return;
    }
    final updated = _s.copyWith(attendees: [..._s.attendees, name]);
    setState(() => _s = updated);
    widget.args.onChanged(updated);
  }

  void _leave() {
    final name = widget.args.userName;
    final updated = _s.copyWith(
      attendees: [
        for (final n in _s.attendees)
          if (n != name) n,
      ],
    );
    setState(() => _s = updated);
    widget.args.onChanged(updated);
  }

  Future<void> _edit() async {
    final edited = await Navigator.of(
      context,
    ).pushNamed<Session>(Routes.form, arguments: FormArgs(session: _s));
    if (edited == null || !mounted) {
      return;
    }
    setState(() => _s = edited);
    widget.args.onChanged(edited);
  }

  Future<void> _delete() async {
    final ok = await confirm(
      context,
      title: 'Delete session?',
      message: 'This cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (!ok || !mounted) {
      return;
    }
    widget.args.onDelete(_s.id);
    Navigator.of(context).pop();
  }

  Future<void> _onMenu(_MenuAction action) async {
    switch (action) {
      case _MenuAction.edit:
        await _edit();
      case _MenuAction.delete:
        await _delete();
    }
  }

  // ---- pieces ----

  Widget _header(ColorScheme scheme) {
    final accent = _s.subject.color(scheme);
    final countdown = Countdown.of(_s, _now);

    return AspectRatio(
      aspectRatio: 16 / 7,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/header.png',
            fit: BoxFit.cover,
            color: accent,
            colorBlendMode: BlendMode.modulate,
          ),
          Center(child: Icon(_s.subject.icon, size: 64, color: scheme.surface)),
          Positioned(left: 12, top: 12, child: _Pill(_s.subject.label)),
          Positioned(
            right: 12,
            top: 12,
            child: _Pill(_countdownText(countdown)),
          ),
        ],
      ),
    );
  }

  Widget _about() {
    // R5: the record is destructured where it is shown.
    final (:taken, :free) = _s.places;

    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.event),
          title: Text(formatDateTime(_s.starts)),
        ),
        ListTile(
          leading: Icon(_s.online ? Icons.link : Icons.place_outlined),
          title: Text(_s.place),
        ),
        ListTile(
          leading: const Icon(Icons.people_outline),
          title: Text('$taken taken, $free free (limit ${_s.limit})'),
        ),
        // R6: optional text via collection if, no "!".
        if (_s.description case final text?)
          ListTile(leading: const Icon(Icons.notes), title: Text(text)),
      ],
    );
  }

  Widget _names(ColorScheme scheme) {
    if (_s.attendees.isEmpty) {
      return const EmptyState(
        icon: Icons.group_outlined,
        message: 'Nobody has joined yet',
      );
    }
    final me = widget.args.userName;

    return ListView(
      children: _s.attendees.map((n) {
        return ListTile(
          tileColor: n == me ? scheme.primaryContainer : null,
          leading: CircleAvatar(child: Text(n.isEmpty ? '' : n[0])),
          title: Text(
            n == me ? '$n (You)' : n,
            style: n == me
                ? const TextStyle(fontWeight: FontWeight.bold)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _actionBar() {
    final name = widget.args.userName;
    final joined = name.isNotEmpty && _s.contains(name);

    // R16: null when it cannot act; the opposite once you are on the list.
    final VoidCallback? onPressed = joined
        ? _leave
        : (_s.isFull ? null : _join);

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        child: Text(joined ? 'Leave' : (_s.isFull ? 'Full' : 'Join')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // R29: DefaultTabController + TabBar + TabBarView; live count in label.
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // R31: no back arrow written by hand; the menu holds Edit/Delete.
        appBar: AppBar(
          title: Text(_s.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: [
            PopupMenuButton<_MenuAction>(
              onSelected: _onMenu,
              itemBuilder: (context) => const [
                PopupMenuItem(value: _MenuAction.edit, child: Text('Edit')),
                PopupMenuItem(value: _MenuAction.delete, child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _header(scheme),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Names (${_s.count})'),
              ],
            ),
            Expanded(child: TabBarView(children: [_about(), _names(scheme)])),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _actionBar(),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: theme.textTheme.labelMedium),
    );
  }
}
````

## `lib/screens/favourites_tab.dart`

``dart``
import 'package:flutter/material.dart';

import '../models/session.dart';
import '../widgets/empty_state.dart';
import '../widgets/session_list.dart';

/// Tab 2.
class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.sessions,
    required this.onOpen,
    required this.onFavourite,
    required this.onBrowse,
  });

  final List<Session> sessions;
  final ValueChanged<Session> onOpen;
  final ValueChanged<String> onFavourite;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final favourites = [...sessions.where((s) => s.favourite)]
      ..sort((a, b) => a.starts.compareTo(b.starts));

    if (favourites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet',
        buttonLabel: 'Browse sessions',
        onPressed: onBrowse,
      );
    }
    return SessionList(
      sessions: favourites,
      onOpen: onOpen,
      onFavourite: onFavourite,
    );
  }
}
````

## `lib/screens/form_screen.dart`

``dart``
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/session.dart';
import '../models/subject.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/dialogs.dart';

/// What the form looked like when it opened (compared by R30).
typedef _Snapshot = ({
  String title,
  String place,
  String limit,
  String description,
  Subject? subject,
  bool online,
  DateTime? starts,
});

/// One screen for new and edit. Receives Session?, returns a Session (R26).
class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.args});

  final FormArgs args;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  // R33
  final _formKey = GlobalKey<FormState>();

  // R35: controllers and focus nodes are fields, created once, disposed.
  late final TextEditingController _title;
  late final TextEditingController _place;
  late final TextEditingController _limit;
  late final TextEditingController _description;
  late final TextEditingController _dateText;
  late final TextEditingController _timeText;
  final _titleFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _limitFocus = FocusNode();
  final _descriptionFocus = FocusNode();

  Subject? _subject;
  late bool _online;
  DateTime? _date;
  TimeOfDay? _time;
  bool _saving = false;
  bool _allowDiscardPop = false;
  late final _Snapshot _initial;

  bool get _editing => widget.args.session != null;

  @override
  void initState() {
    super.initState();
    final s = widget.args.session ?? Session.empty();
    _title = TextEditingController(text: s.title);
    _place = TextEditingController(text: s.place);
    _limit = TextEditingController(text: '${s.limit}');
    _description = TextEditingController(text: s.description ?? '');
    _dateText = TextEditingController(text: formatDate(s.starts));
    _timeText = TextEditingController(text: formatTime(s.starts));
    _subject = _editing ? s.subject : null;
    _online = s.online;
    _date = DateTime(s.starts.year, s.starts.month, s.starts.day);
    _time = TimeOfDay(hour: s.starts.hour, minute: s.starts.minute);
    _initial = _snapshot;
  }

  @override
  void dispose() {
    _title.dispose();
    _place.dispose();
    _limit.dispose();
    _description.dispose();
    _dateText.dispose();
    _timeText.dispose();
    _titleFocus.dispose();
    _placeFocus.dispose();
    _limitFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  // ---- derived values ----

  DateTime? get _starts {
    final d = _date;
    final t = _time;
    if (d == null || t == null) {
      return null;
    }
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  _Snapshot get _snapshot => (
    title: _title.text,
    place: _place.text,
    limit: _limit.text,
    description: _description.text,
    subject: _subject,
    online: _online,
    starts: _starts,
  );

  /// R30: current values vs. the ones the form opened with.
  bool get _dirty => _snapshot != _initial;

  // ---- validators (R34) ----

  String? _validateTitle(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < 3) {
      return 'At least 3 characters';
    }
    if (text.length > 60) {
      return 'At most 60 characters';
    }
    return null;
  }

  String? _validatePlace(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return _online ? 'Meeting link is required' : 'Place is required';
    }
    if (_online && !text.contains('://')) {
      return 'A link must contain ://';
    }
    return null;
  }

  String? _validateLimit(String? value) {
    final n = int.tryParse(value?.trim() ?? '');
    if (n == null) {
      return 'Enter a whole number';
    }
    if (n < 1 || n > 500) {
      return 'Between 1 and 500';
    }
    final current = widget.args.session?.count ?? 0;
    if (_editing && n < current) {
      return 'Not below the current count ($current)';
    }
    return null;
  }

  String? _validateSubject(Subject? value) {
    return value == null ? 'Pick a category' : null;
  }

  String? _validateDate(String? value) {
    return _date == null ? 'Pick a date' : null;
  }

  String? _validateTime(String? value) {
    if (_time == null) {
      return 'Pick a time';
    }
    final starts = _starts;
    if (!_editing && starts != null && !starts.isAfter(DateTime.now())) {
      return 'Must be in the future';
    }
    return null;
  }

  // ---- pickers (R36) ----

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null || !mounted) {
      return; // Cancel keeps the old value.
    }
    _dateText.text = formatDate(picked);
    setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked == null || !mounted) {
      return;
    }
    _timeText.text = formatHm(picked.hour, picked.minute);
    setState(() => _time = picked);
  }

  void _dismissKeyboard(PointerDownEvent event) {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // ---- save (R17) ----

  Session _build() {
    final base = widget.args.session ?? Session.empty();
    final text = _description.text.trim();
    return base.copyWith(
      id: base.id.isEmpty
          ? DateTime.now().microsecondsSinceEpoch.toString()
          : base.id,
      title: _title.text.trim(),
      subject: _subject ?? base.subject,
      starts: _starts ?? base.starts,
      place: _place.text.trim(),
      limit: int.tryParse(_limit.text.trim()) ?? base.limit,
      online: _online,
      description: text,
      clearDescription: text.isEmpty,
    );
  }

  Future<void> _save() async {
    if (_saving) {
      return; // a double tap does not save twice
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(_build());
  }

  @override
  Widget build(BuildContext context) {
    // R30: the arrow and the Android gesture both end up here.
    return PopScope(
      canPop: !_dirty || _allowDiscardPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final navigator = Navigator.of(context);
        final discard = await confirm(
          context,
          title: 'Discard changes?',
          message: 'Your edits will be lost.',
          confirmLabel: 'Discard',
        );
        if (!discard || !mounted) {
          return;
        }
        setState(() => _allowDiscardPop = true);
        await WidgetsBinding.instance.endOfFrame;
        if (!mounted) {
          return;
        }
        navigator.pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_editing ? 'Edit session' : 'New session')),
        // R37: the form scrolls, no Spacer inside the scroll view.
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () => setState(() {}),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _title,
                  focusNode: _titleFocus,
                  maxLength: 60,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateTitle,
                  onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                  onTapOutside: _dismissKeyboard,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Subject>(
                  initialValue: _subject,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final s in Subject.values)
                      DropdownMenuItem(value: s, child: Text(s.label)),
                  ],
                  validator: _validateSubject,
                  onChanged: (value) => setState(() => _subject = value),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Online session'),
                  subtitle: const Text('The place becomes a meeting link'),
                  value: _online,
                  onChanged: (value) => setState(() => _online = value),
                ),
                TextFormField(
                  controller: _place,
                  focusNode: _placeFocus,
                  keyboardType: _online
                      ? TextInputType.url
                      : TextInputType.text,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: _online ? 'Meeting link' : 'Place',
                    border: const OutlineInputBorder(),
                  ),
                  validator: _validatePlace,
                  onFieldSubmitted: (_) => _limitFocus.requestFocus(),
                  onTapOutside: _dismissKeyboard,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _limit,
                  focusNode: _limitFocus,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Places (limit)',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateLimit,
                  onTapOutside: _dismissKeyboard,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dateText,
                        readOnly: true,
                        onTap: _pickDate,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          suffixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _timeText,
                        readOnly: true,
                        onTap: _pickTime,
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          suffixIcon: Icon(Icons.schedule),
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _description,
                  focusNode: _descriptionFocus,
                  maxLines: 3,
                  maxLength: 200,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => null,
                  onTapOutside: _dismissKeyboard,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
````

## `lib/screens/list_tab.dart`

``dart``
import 'package:flutter/material.dart';

import '../models/session.dart';
import '../models/subject.dart';
import '../widgets/empty_state.dart';
import '../widgets/session_list.dart';

/// Tab 1. R21: search + chips + filter in one Column, list in Expanded.
class ListTab extends StatefulWidget {
  const ListTab({
    super.key,
    required this.sessions,
    required this.onOpen,
    required this.onFavourite,
  });

  final List<Session> sessions;
  final ValueChanged<Session> onOpen;
  final ValueChanged<String> onFavourite;

  @override
  State<ListTab> createState() => _ListTabState();
}

class _ListTabState extends State<ListTab> {
  final _search = TextEditingController();
  String _query = '';
  Subject? _subject;
  bool _showPast = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// R7: where + sort on a copy; past items last; state is never sorted.
  List<Session> get _visible {
    final q = _query.trim().toLowerCase();
    final filtered = widget.sessions.where(
      (s) =>
          (_showPast || !s.isPast) &&
          (_subject == null || s.subject == _subject) &&
          (q.isEmpty || s.title.toLowerCase().contains(q)),
    );
    return [...filtered]..sort((a, b) {
      if (a.isPast != b.isPast) {
        return a.isPast ? 1 : -1;
      }
      return a.starts.compareTo(b.starts);
    });
  }

  void _clearSearch() {
    _search.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final items = _visible;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _search,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search sessions',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _clearSearch,
                      tooltip: 'Clear',
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _subject == null,
                onSelected: (_) => setState(() => _subject = null),
              ),
              for (final subject in Subject.values) ...[
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: Icon(subject.icon, size: 18),
                  label: Text(subject.label),
                  selected: _subject == subject,
                  onSelected: (_) => setState(() => _subject = subject),
                ),
              ],
              const SizedBox(width: 16),
              FilterChip(
                label: const Text('Show past'),
                selected: _showPast,
                onSelected: (value) => setState(() => _showPast = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: items.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  message: 'No sessions match',
                  buttonLabel: 'Clear search',
                  onPressed: _clearSearch,
                )
              : SessionList(
                  sessions: items,
                  onOpen: widget.onOpen,
                  onFavourite: widget.onFavourite,
                ),
        ),
      ],
    );
  }
}
````

## `lib/screens/profile_tab.dart`

``dart``
import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../models/session.dart';

/// Tab 3. R38: controllers initialised from the model, save on onSubmitted.
class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.sessions,
    required this.themeMode,
    required this.onProfile,
    required this.onThemeMode,
  });

  final Profile profile;
  final List<Session> sessions;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onProfile;
  final ValueChanged<ThemeMode> onThemeMode;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  static final _groupPattern = RegExp(r'^[A-Za-z]{2,5}-\d{3,4}$');

  late final TextEditingController _name;
  late final TextEditingController _group;
  final _groupKey = GlobalKey<FormFieldState<String>>();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _group = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The profile can change from above (Reset data in the drawer).
    if (_name.text != widget.profile.name) {
      _name.text = widget.profile.name;
    }
    if (_group.text != widget.profile.group) {
      _group.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    super.dispose();
  }

  String? _validateGroup(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty || _groupPattern.hasMatch(text)) {
      return null;
    }
    return 'Use a format like CS-2301';
  }

  void _saveName(String value) {
    widget.onProfile(widget.profile.copyWith(name: value.trim()));
  }

  void _saveGroup(String value) {
    if (_groupKey.currentState?.validate() ?? false) {
      widget.onProfile(widget.profile.copyWith(group: value.trim()));
    }
  }

  String _modeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'System',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = widget.profile.name;
    // R38: computed from the list on every build.
    final lists = name.isEmpty
        ? 0
        : widget.sessions.fold(
            0,
            (count, session) => count + (session.contains(name) ? 1 : 0),
          );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextFormField(
          controller: _name,
          maxLength: 30,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Name',
            helperText: 'Press the keyboard button to save',
            border: OutlineInputBorder(),
          ),
          onFieldSubmitted: _saveName,
          onTapOutside: (event) =>
              FocusManager.instance.primaryFocus?.unfocus(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: _groupKey,
          controller: _group,
          textInputAction: TextInputAction.done,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateGroup,
          decoration: const InputDecoration(
            labelText: 'Group',
            hintText: 'CS-2301',
            border: OutlineInputBorder(),
          ),
          onFieldSubmitted: _saveGroup,
          onTapOutside: (event) =>
              FocusManager.instance.primaryFocus?.unfocus(),
        ),
        const SizedBox(height: 24),
        Text('You are on $lists lists', style: theme.textTheme.titleMedium),
        const SizedBox(height: 24),
        Text('Theme', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final mode in ThemeMode.values)
              ChoiceChip(
                label: Text(_modeLabel(mode)),
                selected: widget.themeMode == mode,
                onSelected: (_) => widget.onThemeMode(mode),
              ),
          ],
        ),
      ],
    );
  }
}
````

## `lib/screens/shell.dart`

``dart``
import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/profile.dart';
import '../models/session.dart';
import '../routes.dart';
import '../widgets/dialogs.dart';
import 'favourites_tab.dart';
import 'list_tab.dart';
import 'profile_tab.dart';

/// R10: the item list and the profile live here; tabs get them as
/// constructor parameters and send changes up as callbacks.
class Shell extends StatefulWidget {
  const Shell({super.key, required this.themeMode, required this.onThemeMode});

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeMode;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  static const _titles = ['Sessions', 'Favourites', 'Profile'];

  int _tab = 0;
  List<Session> _sessions = buildSeed();
  Profile _profile = const Profile.empty();

  // ---- state changes (R12: setState wraps the change only) ----

  void _toggleFavourite(String id) {
    setState(() {
      _sessions = [
        for (final s in _sessions)
          s.id == id ? s.copyWith(favourite: !s.favourite) : s,
      ];
    });
  }

  void _upsert(Session session) {
    final exists = _sessions.any((s) => s.id == session.id);
    setState(() {
      _sessions = exists
          ? [for (final s in _sessions) s.id == session.id ? session : s]
          : [session, ..._sessions];
    });
  }

  void _delete(String id) {
    setState(() => _sessions = _sessions.where((s) => s.id != id).toList());
  }

  void _setProfile(Profile profile) => setState(() => _profile = profile);

  /// R28: tab switches from tabs or pushed screens go through here.
  void _goToTab(int index) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() => _tab = index);
  }

  // ---- navigation ----

  void _open(Session session) {
    Navigator.of(context).pushNamed<void>(
      Routes.detail,
      arguments: DetailArgs(
        session: session,
        userName: _profile.name,
        onChanged: _upsert,
        onDelete: _delete,
        onOpenProfile: () => _goToTab(2),
      ),
    );
  }

  /// R27: await `pushNamed<Session>`, check null and mounted, then setState.
  Future<void> _add() async {
    final created = await Navigator.of(
      context,
    ).pushNamed<Session>(Routes.form, arguments: const FormArgs());
    if (created == null || !mounted) {
      return;
    }
    _upsert(created);
  }

  // ---- drawer (R32) ----

  void _showAbout() {
    Navigator.of(context).pop();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('About'),
        content: const Text(
          'StudyHub - find and join study sessions.\n'
          'Mobile Development, Lab 1. All data lives in memory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetData() async {
    Navigator.of(context).pop();
    final ok = await confirm(
      context,
      title: 'Reset data?',
      message: 'The sample sessions come back and your profile is cleared.',
      confirmLabel: 'Reset',
    );
    if (!ok || !mounted) {
      return;
    }
    setState(() {
      _sessions = buildSeed();
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_titles[_tab])),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('StudyHub', style: theme.textTheme.titleLarge),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: _showAbout,
              ),
              ListTile(
                leading: const Icon(Icons.restart_alt),
                title: const Text('Reset data'),
                onTap: _resetData,
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          ListTab(
            sessions: _sessions,
            onOpen: _open,
            onFavourite: _toggleFavourite,
          ),
          FavouritesTab(
            sessions: _sessions,
            onOpen: _open,
            onFavourite: _toggleFavourite,
            onBrowse: () => _goToTab(0),
          ),
          ProfileTab(
            profile: _profile,
            sessions: _sessions,
            themeMode: widget.themeMode,
            onProfile: _setProfile,
            onThemeMode: widget.onThemeMode,
          ),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton(
              onPressed: _add,
              tooltip: 'New session',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Sessions',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
````

## `lib/utils/format.dart`

``dart``
/// R8: own formatting, no packages. "18 Oct, 10:00"
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _two(int n) => n.toString().padLeft(2, '0');

String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

String formatHm(int hour, int minute) => '${_two(hour)}:${_two(minute)}';

String formatTime(DateTime d) => formatHm(d.hour, d.minute);

String formatDateTime(DateTime d) => '${formatDate(d)}, ${formatTime(d)}';

String formatDuration(Duration d) {
  if (d.inDays > 0) {
    return '${d.inDays}d ${d.inHours % 24}h';
  }
  if (d.inHours > 0) {
    return '${d.inHours}h ${d.inMinutes % 60}m';
  }
  return '${d.inMinutes}m';
}
````

## `lib/widgets/dialogs.dart`

``dart``
import 'package:flutter/material.dart';

/// One confirmation dialog shape for the whole app: `showDialog<bool>`.
Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Yes',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
````

## `lib/widgets/empty_state.dart`

``dart``
import 'package:flutter/material.dart';

/// R23: one widget for every empty state: icon, message, optional button.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.buttonLabel,
    this.onPressed,
  });

  final IconData icon;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = buttonLabel;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            if (label != null && onPressed != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: onPressed, child: Text(label)),
            ],
          ],
        ),
      ),
    );
  }
}
````

## `lib/widgets/session_card.dart`

``dart``
import 'package:flutter/material.dart';

import '../models/session.dart';
import '../utils/format.dart';

/// R18: the one reusable card.
class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    required this.onTap,
    required this.onFavourite,
  });

  final Session session;
  final VoidCallback onTap;
  final VoidCallback onFavourite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final s = session;
    final accent = s.subject.color(scheme);

    // R19: "FULL", "N left" when <= 5 remain, otherwise no badge.
    final String? badge = s.isFull
        ? 'FULL'
        : (s.freePlaces <= 5 ? '${s.freePlaces} left' : null);

    return Opacity(
      opacity: s.isPast ? 0.6 : 1,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: accent.withValues(alpha: 0.18),
                      child: Icon(s.subject.icon, color: accent),
                    ),
                    if (badge != null)
                      Positioned(
                        left: -8,
                        right: -8,
                        bottom: -8,
                        child: Center(
                          child: _Badge(text: badge, full: s.isFull),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        s.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatDateTime(s.starts),
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        s.place,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onFavourite,
                  tooltip: s.favourite ? 'Remove favourite' : 'Add favourite',
                  icon: Icon(
                    s.favourite ? Icons.favorite : Icons.favorite_border,
                    color: s.favourite ? scheme.error : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.full});

  final String text;
  final bool full;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: full ? scheme.error : scheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: full ? scheme.onError : scheme.onPrimary,
        ),
      ),
    );
  }
}
````

## `lib/widgets/session_list.dart`

``dart``
import 'package:flutter/material.dart';

import '../models/session.dart';
import 'session_card.dart';

/// R20: list on phones, grid from 600 px - decided by LayoutBuilder.
class SessionList extends StatelessWidget {
  const SessionList({
    super.key,
    required this.sessions,
    required this.onOpen,
    required this.onFavourite,
  });

  final List<Session> sessions;
  final ValueChanged<Session> onOpen;
  final ValueChanged<String> onFavourite;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget card(Session s) => SessionCard(
          session: s,
          onTap: () => onOpen(s),
          onFavourite: () => onFavourite(s.id),
        );

        if (constraints.maxWidth >= 600) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360,
              mainAxisExtent: 136,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: sessions.length,
            itemBuilder: (context, index) => card(sessions[index]),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => card(sessions[index]),
        );
      },
    );
  }
}
````

## `test/widget_test.dart`

``dart``
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_hub/models/session.dart';
import 'package:study_hub/models/subject.dart';
import 'package:study_hub/main.dart';

void main() {
  test('Session copies and protects its attendee list', () {
    final names = ['Aigerim'];
    final session = Session.withAttendees(
      id: 'test',
      title: 'Test session',
      subject: Subject.math,
      starts: DateTime(2026, 10, 22, 10),
      place: 'Room 1',
      limit: 2,
      online: false,
      attendees: names,
    );

    names.add('Dana');

    expect(session.attendees, ['Aigerim']);
    expect(() => session.attendees.add('Timur'), throwsUnsupportedError);
  });

  testWidgets('detail tabs work at phone size', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Calculus office hours'));
    await tester.pumpAndSettle();

    expect(find.text('Room 204'), findsOneWidget);
    expect(find.text('Names (4)'), findsOneWidget);

    await tester.tap(find.text('Names (4)'));
    await tester.pumpAndSettle();

    expect(find.text('Aigerim'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
````

## `web/index.html`

``html``
<!DOCTYPE html>
<html>
<head>
  <!--
    If you are serving your web app in a path other than the root, change the
    href value below to reflect the base path you are serving from.

    The path provided below has to start and end with a slash "/" in order for
    it to work correctly.

    For more details:
    * https://developer.mozilla.org/en-US/docs/Web/HTML/Element/base

    This is a placeholder for base href that will be replaced by the value of
    the `--base-href` argument provided to `flutter build`.
  -->
  <base href="$FLUTTER_BASE_HREF">

  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="A new Flutter project.">

  <!-- iOS meta tags & icons -->
  <meta name="mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="study_hub">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">

  <!-- Favicon -->
  <link rel="icon" type="image/png" href="favicon.png"/>

  <title>study_hub</title>
  <link rel="manifest" href="manifest.json">
</head>
<body>
  <!--
    You can customize the "flutter_bootstrap.js" script.
    This is useful to provide a custom configuration to the Flutter loader
    or to give the user feedback during the initialization process.

    For more details:
    * https://docs.flutter.dev/platform-integration/web/initialization
  -->
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
````

## `web/manifest.json`

``json``
{
    "name": "study_hub",
    "short_name": "study_hub",
    "start_url": ".",
    "display": "standalone",
    "background_color": "#0175C2",
    "theme_color": "#0175C2",
    "description": "A new Flutter project.",
    "orientation": "portrait-primary",
    "prefer_related_applications": false,
    "icons": [
        {
            "src": "icons/Icon-192.png",
            "sizes": "192x192",
            "type": "image/png"
        },
        {
            "src": "icons/Icon-512.png",
            "sizes": "512x512",
            "type": "image/png"
        },
        {
            "src": "icons/Icon-maskable-192.png",
            "sizes": "192x192",
            "type": "image/png",
            "purpose": "maskable"
        },
        {
            "src": "icons/Icon-maskable-512.png",
            "sizes": "512x512",
            "type": "image/png",
            "purpose": "maskable"
        }
    ]
}
````
