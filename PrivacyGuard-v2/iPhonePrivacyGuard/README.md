# iPhone Privacy Guard

App SwiftUI (iOS 16+, compatible iPhone 11) qui aide à **comprendre et repérer** les dispositifs de contrôle
(parental, MDM, profils) sur son iPhone. Elle ne modifie, ne supprime et ne contourne rien. Aucun réseau, aucune donnée sortante.

> Code non compilé ni testé dans mon environnement (pas de Xcode). Attendez-vous à corriger de petites erreurs au premier build.

## Installation (Mac avec Xcode 15+)
1. Xcode > File > New > Project > iOS > App. Nom : `PrivacyGuard`, Interface : SwiftUI, Langage : Swift.
2. Supprimez `ContentView.swift` et le fichier `...App.swift` généré. Glissez le dossier `Sources/` (cocher "Copy items", cible PrivacyGuard) et `Resources/known_apps.json` (cocher la cible).
3. Target > General > Minimum Deployments : iOS 16.0.
4. Target > Signing & Capabilities : choisissez votre Team (un compte Apple gratuit suffit pour installer sur votre iPhone). Adaptez le Bundle ID, et mettez le même identifiant dans `AlertService.taskID` (ex. `com.vous.privacyguard.refresh`).
5. Capability "Background Modes" > cochez "Background fetch".
6. Info.plist (onglet Info) ajoutez :
   - `BGTaskSchedulerPermittedIdentifiers` (Array) : votre `taskID`.
   - `LSApplicationQueriesSchemes` : générez le bloc avec `python3 tools/gen_schemes.py` et collez-le (Source Code view).
7. Branchez l'iPhone (Mode développeur activé : Réglages > Confidentialité et sécurité > Mode développeur), choisissez-le comme destination, Run. Avec un compte gratuit, l'app expire au bout de 7 jours.

## À vérifier absolument
Les schémas d'URL de `known_apps.json` sont des hypothèses (`"verified": false`). Une app n'est détectée que si son schéma réel est exact. Vérifiez-les (documentation de l'éditeur, ou `Info.plist` > `CFBundleURLTypes` de l'app) avant de vous y fier.

## Ce qui est possible / impossible
Possible : indices réseau (VPN/proxy), config d'app gérée, apps connues par schéma, guides pas à pas, alertes locales sur les indices automatiques, rappel hebdomadaire.
Impossible (API inexistante ou réservée au système) : lister les apps installées ; lire profils, MDM, supervision ; savoir si Temps d'écran/Partage familial est actif ; lire les autorisations des autres apps ; être notifié d'une installation de profil ; supprimer ou modifier une restriction. L'onglet « Vérifier » repose donc sur ce que **vous** voyez dans les Réglages.
Le refresh en arrière-plan (BGAppRefresh) est à la discrétion d'iOS : les alertes peuvent arriver en retard, voire pas.
Le VPN détecté peut être un faux positif (iCloud Private Relay, services système).

## Sans Mac : compilation cloud + installation depuis Windows
1. Créez un compte GitHub (gratuit) et un dépôt **public** (les Mac cloud y sont gratuits). Envoyez-y tout le contenu de ce dossier (bouton "Add file > Upload files" sur le site, y compris le dossier `.github`).
2. Onglet **Actions** > "Build IPA" > **Run workflow**. Après quelques minutes, ouvrez l'exécution terminée et téléchargez l'artefact `PrivacyGuard-ipa` (un zip contenant `PrivacyGuard.ipa`).
3. Sur le PC : installez iTunes et iCloud (versions du site d'Apple, pas du Microsoft Store), puis **Sideloadly**.
4. Branchez l'iPhone en USB (Faire confiance), glissez le .ipa dans Sideloadly, entrez votre Apple ID, Start.
5. iPhone : Réglages > Général > VPN et gestion de l'appareil > faites confiance à votre Apple ID. Activez le Mode développeur si demandé (Réglages > Confidentialité et sécurité).
6. L'app expire après 7 jours : refaites l'étape 4.
Si le build échoue, copiez le message d'erreur du journal Actions : on le corrige.
