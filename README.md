# README CampusEvent

README de l’application Flutter CampusEvent, dédiée aux événements, conférences, clubs et activités étudiantes du campus.

CampusEvent est une application Flutter de gestion des événements du campus, des conférences, des clubs et des activités étudiantes.

## Description du projet

CampusEvent permet aux étudiants et aux administrateurs de gérer la vie événementielle d’un campus depuis une application Flutter structurée avec **Clean Architecture** et **MVVM**.

L’application couvre notamment :

* la consultation des événements du campus ;
* la gestion des conférences ;
* la création et la modification de clubs ;
* l’inscription et la désinscription aux événements ;
* la gestion des profils utilisateurs ;
* les notifications ;
* l’utilisation de QR codes pour les événements.

## Architecture utilisée

Le projet utilise deux principes principaux :

* **Clean Architecture** : séparation claire entre les couches `presentation`, `domaine`, `data`, `core` et `services`.
* **MVVM** : séparation entre les vues Flutter et les ViewModels responsables de la logique de présentation.

## Structure du projet

Evenements_Campus/
├── lib/
│   ├── main.dart
│   │
│   ├── presentation/           # UI Layer (MVVM - Vue)
│   │   ├── pages/
│   │   │   ├── admin_page.dart
│   │   │   ├── club_detail_page.dart
│   │   │   ├── club_details_page.dart
│   │   │   ├── clubs_page.dart
│   │   │   ├── conference_page.dart
│   │   │   ├── create_club_page.dart
│   │   │   ├── create_conference_page.dart
│   │   │   ├── create_event_page.dart
│   │   │   ├── edit_club_page.dart
│   │   │   ├── edit_conference_page.dart
│   │   │   ├── event_detail_page.dart
│   │   │   ├── event_details_page.dart
│   │   │   ├── event_qr_page.dart
│   │   │   ├── events_page.dart
│   │   │   ├── forgo_password_page.dart
│   │   │   ├── home_page.dart
│   │   │   ├── login_page.dart
│   │   │   ├── notificaions_page.dart
│   │   │   ├── profile_page.dart
│   │   │   ├── qr_scanner_page.dart
│   │   │   ├── register_page.dart
│   │   │   ├── reset_password_page.dart
│   │   │   ├── settings_page.dart
│   │   │   ├── splash_page.dart
│   │   │   └── verify_code_page.dart
│   │   │
│   │   ├── view_models/        # ViewModels (MVVM - ViewModel)
│   │   │   ├── auth_viewmodel.dart
│   │   │   ├── club_viewmodel.dart
│   │   │   ├── event_viewmodel.dart
│   │   │   ├── notification_viewmodel.dart
│   │   │   └── profile_viewmodel.dart
│   │   │
│   │   └── widgets/            # Widgets réutilisables et gestion d’état
│   │       ├── club_card.dart
│   │       ├── event_card.dart
│   │       ├── loading_dialog.dart
│   │       ├── logout_dialog.dart
│   │       ├── notification_badge.dart
│   │       └── fournisseur_états.dart
│   │
│   ├── models/
│   │   └── event.dart
│   │
│   ├── domaine/                # Domain Layer (Clean Architecture)
│   │   ├── entities/
│   │   │   ├── club.dart
│   │   │   ├── event.dart
│   │   │   ├── notification.dart
│   │   │   └── user.dart
│   │   │
│   │   ├── repositories/
│   │   │   ├── auth_repository.dart
│   │   │   ├── club_repository.dart
│   │   │   └── event_repository.dart
│   │   │
│   │   └── usecases/           # Cas d’utilisation
│   │       ├── auth/
│   │       │   ├── change_password_usecase.dart
│   │       │   ├── delete_all_users_usecase.dart
│   │       │   ├── delete_profile_image_usecase.dart
│   │       │   ├── delete_user_usecase.dart
│   │       │   ├── forgot_password_usecase.dart
│   │       │   ├── get_all_users_usecase.dart
│   │       │   ├── get_current_user_usecase.dart
│   │       │   ├── login_usecase
│   │       │   ├── register_usecase.dart
│   │       │   ├── update_email_usecase.dart
│   │       │   ├── update_profile_usecase.dart
│   │       │   └── update_profile_image_usecase.dart
│   │       │
│   │       ├── clubs/
│   │       │   ├── create_club_usecase.dart
│   │       │   ├── delete_club_usecase.dart
│   │       │   ├── get_clubs_usecase.dart
│   │       │   ├── get_user_clubs_usecase.dart
│   │       │   ├── join_club_usecase.dart
│   │       │   ├── leave_club_usecase.dart
│   │       │   ├── manage_members_usecase.dart
│   │       │   └── update_club_usecase.dart
│   │       │
│   │       └── events/
│   │           ├── create_event_usecase.dart
│   │           ├── delete_event_usecase.dart
│   │           ├── get_events_usecase.dart
│   │           ├── register_for_even_usecase.dart
│   │           ├── unregister_from_event_usecase.dart
│   │           └── update_event_usecase.dart
│   │
│   ├── data/                   # Data Layer (Clean Architecture)
│   │   ├── datasources/local/
│   │   │   └── app_database.dart
│   │   │
│   │   ├── models/
│   │   │   ├── club_model.dart
│   │   │   ├── event_model.dart
│   │   │   └── user_model.dart
│   │   │
│   │   └── repositories/
│   │       ├── auth_repository_impl.dart
│   │       ├── club_repository_impl.dart
│   │       └── event_repository_impl.dart
│   │
│   ├── core/                   # Core Layer (Utils, Constants, DI)
│   │   ├── constants/
│   │   │   └── app_constants.dart
│   │   │
│   │   ├── di/
│   │   │   └── injection.dart
│   │   │
│   │   ├── routes/
│   │   │   └── app_routes.dart
│   │   │
│   │   ├── themes/
│   │   │   └── app_theme.dart
│   │   │
│   │   └── utils/
│   │       ├── app_state.dart
│   │       └── helpers.dart
│   │
│   └── services/               # Services externes
│       ├── email_service.dart
│       ├── event_service.dart
│       ├── image_picker_service.dart
│       ├── image_upload_service.dart
│       ├── notification_service.dart
│       └── qr_code_service.dart
│
├── assets/
│   ├── fonts/
│   │   ├── Poppins-Bold.ttf
│   │   ├── Poppins-Medium.ttf
│   │   ├── Poppins-Regular.ttf
│   │   └── Poppins-SemiBold.ttf
│   └── images/
│       └── logos.png
│
├── test/
│   └── widget_test.dart
│
├── android/                    # Configuration Android générée par Flutter
├── ios/                        # Configuration iOS
├── web/                        # Configuration Web
├── pubspec.yaml
├── pubspec.lock
├── README.md
└── .gitignore

## Couches principales

### Presentation

La couche `presentation` contient l’interface utilisateur Flutter. Elle regroupe les pages, les ViewModels et les widgets réutilisables.

* `pages/` contient les écrans de l’application.
* `view_models/` contient la logique de présentation utilisée par les vues.
* `widgets/` contient les composants UI réutilisables comme les cartes, les dialogues et les badges.

### Domaine

La couche `domaine` contient les règles métier de l’application. Elle reste indépendante de Flutter et des détails techniques de stockage ou de services externes.

Elle contient :

* `entities/` : les objets métier comme `User`, `Club`, `Event` et `Notification` ;
* `repositories/` : les contrats que la couche `data` doit implémenter ;
* `usecases/` : les actions métier comme créer un événement, rejoindre un club ou mettre à jour un profil.

### Data

La couche `data` contient les implémentations concrètes des repositories, les modèles de données et les sources de données locales.

Elle permet de séparer les détails techniques de la logique métier.

### Core

La couche `core` regroupe les éléments partagés par toute l’application : constantes, injection de dépendances, routes, thème et utilitaires.

### Services

La couche `services` contient les services externes utilisés par l’application, notamment les notifications, les QR codes, l’upload d’images et les emails.

## Fonctionnalités principales

* Authentification : connexion, inscription, mot de passe oublié, réinitialisation et vérification de code.
* Gestion du profil : consultation, modification, image de profil et changement d’email.
* Gestion des clubs : création, modification, suppression, adhésion et gestion des membres.
* Gestion des événements : création, modification, suppression, inscription et désinscription.
* Conférences : création, modification et consultation des conférences.
* QR code : génération et scan liés aux événements.
* Notifications : affichage et badge de notifications.
* Administration : gestion des utilisateurs et des contenus depuis une page dédiée.

## Technologies

* Flutter
* Dart
* Clean Architecture
* MVVM
* Assets personnalisés avec police Poppins

## Lancer le projet

1. Clonez le dépôt :

git clone <url-du-repository>
cd Evenements_Campus

2. Installez les dépendances Flutter :

flutter pub get

3. Lancez l’application :

flutter run

## Tests

Exécutez les tests Flutter avec la commande suivante :

flutter test

## Assets

Le projet contient des assets dans le dossier `assets/` :

* `assets/fonts/` : polices Poppins utilisées par l’application ;
* `assets/images/logos.png` : logo de l’application.

Vérifiez que ces assets sont bien déclarés dans `pubspec.yaml` avant de lancer l’application.

## Convention d’organisation

Respectez les responsabilités de chaque couche lorsque vous ajoutez une nouvelle fonctionnalité :

1. Ajoutez les entités et contrats dans `domaine/`.
2. Ajoutez les cas d’utilisation dans `domaine/usecases/`.
3. Implémentez les repositories dans `data/repositories/`.
4. Ajoutez ou mettez à jour les ViewModels dans `presentation/view_models/`.
5. Créez les pages et widgets nécessaires dans `presentation/`.
6. Enregistrez les dépendances nécessaires dans `core/di/injection.dart`.

## Nom du projet

**CampusEvent** — application Flutter pour centraliser les événements, conférences, clubs et activités étudiantes du campus.
