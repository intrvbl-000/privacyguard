import Foundation

struct ChecklistItem: Identifiable {
    let id: String
    let question: String
    let path: String
    let finding: Finding
}

/// Contenus pédagogiques. Tout est en français, sans jargon.
enum Catalog {

    // MARK: Indices automatiques (heuristiques, jamais des preuves)

    static let vpn = Finding(
        id: "vpn_active",
        title: "Un tunnel réseau (VPN) semble actif",
        summary: "Votre trafic internet passe peut-être par un service intermédiaire.",
        consequences: "Le fournisseur du tunnel peut voir les sites visités (au moins leurs noms) et peut en bloquer certains. Cela peut aussi être un VPN que vous avez choisi, iCloud Private Relay ou un service système : ce n'est qu'un indice.",
        advice: "Vérifiez dans Réglages > VPN (ou Général > VPN et gestion de l'appareil) qui a configuré ce VPN. Si vous ne le reconnaissez pas, demandez à la personne qui gère l'appareil.",
        whereToCheck: "Réglages > VPN ; Réglages > Général > VPN et gestion de l'appareil",
        level: .low, origin: .automatic)

    static let proxy = Finding(
        id: "proxy_configured",
        title: "Un proxy réseau est configuré",
        summary: "Vos requêtes web passent par un serveur intermédiaire défini dans les réglages réseau ou un profil.",
        consequences: "Un proxy peut filtrer ou journaliser les adresses web demandées. Les contenus protégés par HTTPS restent chiffrés, sauf si un certificat racine a été installé et approuvé (voir la vérification manuelle).",
        advice: "Regardez Réglages > Wi-Fi > (i) à côté du réseau > Configurer le proxy.",
        whereToCheck: "Réglages > Wi-Fi > (i) > Configurer le proxy",
        level: .medium, origin: .automatic)

    static let managedConfig = Finding(
        id: "managed_config",
        title: "Une configuration d'app gérée est présente",
        summary: "Un outil de gestion d'appareil (MDM) a envoyé des réglages à cette app.",
        consequences: "L'appareil est géré par une organisation (école, entreprise, famille avec outil MDM). Elle peut imposer des réglages, des restrictions et des apps.",
        advice: "Consultez Réglages > Général > VPN et gestion de l'appareil pour voir qui gère l'appareil.",
        whereToCheck: "Réglages > Général > VPN et gestion de l'appareil",
        level: .high, origin: .automatic)

    static func knownApp(_ app: KnownApp) -> Finding {
        Finding(
            id: "app:\(app.id)",
            title: "App détectée : \(app.name)",
            summary: "Une app de type « \(app.category) » semble installée.",
            consequences: "Ce type d'app peut, selon sa configuration et les droits accordés, filtrer des contenus, limiter l'usage ou envoyer des rapports à un administrateur. Lisez ses autorisations dans Réglages > \(app.name).",
            advice: "Ouvrez l'app et lisez ce qu'elle indique. Si c'est un accord familial, parlez-en avec la personne concernée. L'app Privacy Guard ne désinstalle ni ne modifie jamais rien.",
            whereToCheck: "Réglages > \(app.name) ; bibliothèque d'apps",
            level: .medium, origin: .automatic)
    }

    // MARK: Vérifications manuelles (iOS ne permet pas à une app de les lire)

    static let checklist: [ChecklistItem] = [
        ChecklistItem(
            id: "supervised",
            question: "En haut de Réglages, voyez-vous « Cet iPhone est supervisé et géré par… » ?",
            path: "Réglages (tout en haut, sous votre nom)",
            finding: Finding(
                id: "supervised",
                title: "L'iPhone est supervisé et géré",
                summary: "Une organisation ou une personne gère cet appareil à distance.",
                consequences: "Un appareil supervisé peut recevoir des restrictions fortes : apps imposées ou retirées, filtre web, VPN, verrouillage de réglages, inventaire des apps, effacement à distance. En général, il ne donne pas accès à vos messages chiffrés ni à vos photos.",
                advice: "Seul l'administrateur peut lever cette supervision. Demandez-lui ce qui est configuré. L'app ne peut ni la détecter précisément ni la retirer.",
                whereToCheck: "Réglages > Général > VPN et gestion de l'appareil",
                level: .high, origin: .declared)),
        ChecklistItem(
            id: "mdm_profile",
            question: "Un profil de configuration apparaît-il ?",
            path: "Réglages > Général > VPN et gestion de l'appareil",
            finding: Finding(
                id: "mdm_profile",
                title: "Un profil de configuration est installé",
                summary: "Un profil peut modifier des réglages importants de l'iPhone.",
                consequences: "Un profil peut configurer Wi-Fi, VPN, comptes mail, restrictions et certificats. Ouvrez-le : la liste de ce qu'il contient s'affiche, avec le nom de l'émetteur.",
                advice: "Appuyez sur le profil pour lire son contenu. Selon sa nature, iOS propose ou non « Supprimer le profil ». C'est à vous de décider manuellement, après avoir compris les conséquences (par exemple perte d'accès au Wi-Fi de l'école).",
                whereToCheck: "Réglages > Général > VPN et gestion de l'appareil",
                level: .high, origin: .declared)),
        ChecklistItem(
            id: "cert_trust",
            question: "Un certificat racine est-il activé dans les réglages de confiance ?",
            path: "Réglages > Général > Informations > Réglages de confiance des certificats",
            finding: Finding(
                id: "cert_trust",
                title: "Un certificat racine est approuvé",
                summary: "Un certificat ajouté manuellement a la confiance totale de l'appareil.",
                consequences: "Un certificat racine approuvé peut permettre à un intermédiaire de lire le trafic web normalement chiffré (HTTPS). C'est utilisé par certains filtres d'entreprise ou d'école, mais aussi par des logiciels malveillants.",
                advice: "Si vous ne le reconnaissez pas, c'est un signal sérieux : voir Réglages > Sécurité de l'Apple Account et la section Comptes de cette app.",
                whereToCheck: "Réglages > Général > Informations > Réglages de confiance des certificats",
                level: .high, origin: .declared)),
        ChecklistItem(
            id: "screen_time_managed",
            question: "Temps d'écran indique-t-il que l'appareil est géré via Partage familial ?",
            path: "Réglages > Temps d'écran",
            finding: Finding(
                id: "screen_time_managed",
                title: "Temps d'écran est géré par un organisateur familial",
                summary: "Un parent ou tuteur gère des limites pour ce compte via Partage familial.",
                consequences: "L'organisateur peut fixer des limites d'apps, des temps d'arrêt, des filtres de contenu, demander à approuver des achats ou téléchargements, et consulter des rapports d'usage. Certains réglages sont alors verrouillés par un code.",
                advice: "Ces limites sont un dispositif Apple légitime et transparent. Pour les faire évoluer, discutez avec l'organisateur : seul lui (ou son code Temps d'écran) peut les modifier.",
                whereToCheck: "Réglages > Temps d'écran ; Réglages > [votre nom] > Partage familial",
                level: .medium, origin: .declared)),
        ChecklistItem(
            id: "content_restrictions",
            question: "Les « Restrictions de contenu et de confidentialité » sont-elles activées ?",
            path: "Réglages > Temps d'écran > Restrictions de contenu et de confidentialité",
            finding: Finding(
                id: "content_restrictions",
                title: "Des restrictions de contenu sont actives",
                summary: "Certains réglages ou contenus sont limités sur cet iPhone.",
                consequences: "Elles peuvent bloquer des achats, des apps, des sites, ou empêcher de modifier certains réglages (position, compte, code). Les options grisées en sont le signe.",
                advice: "Ouvrez l'écran pour voir précisément la liste. La modifier demande le code Temps d'écran.",
                whereToCheck: "Réglages > Temps d'écran > Restrictions de contenu et de confidentialité",
                level: .low, origin: .declared)),
        ChecklistItem(
            id: "location_sharing",
            question: "Partagez-vous votre position avec quelqu'un dans l'app Localiser ?",
            path: "App Localiser > onglet Moi / Personnes",
            finding: Finding(
                id: "location_sharing",
                title: "Votre position est partagée",
                summary: "Au moins une personne peut voir où se trouve votre iPhone.",
                consequences: "Les personnes listées peuvent voir votre position, parfois en temps réel. Le partage de position est un réglage de confidentialité à part entière, distinct du Temps d'écran.",
                advice: "Vous pouvez l'arrêter dans Localiser. Si c'est un accord familial, il est préférable d'en parler avant.",
                whereToCheck: "App Localiser > Personnes ; Réglages > Confidentialité et sécurité > Service de localisation > Partager ma position",
                level: .medium, origin: .declared)),
        ChecklistItem(
            id: "unknown_device",
            question: "Votre compte Apple liste-t-il un appareil que vous ne reconnaissez pas ?",
            path: "Réglages > [votre nom] > (liste des appareils en bas)",
            finding: Finding(
                id: "unknown_device",
                title: "Appareil inconnu sur votre compte Apple",
                summary: "Un appareil que vous ne reconnaissez pas est connecté à votre compte.",
                consequences: "Il peut accéder à des données synchronisées (iCloud, photos, messages iCloud selon réglages) et à votre position via Localiser.",
                advice: "Touchez l'appareil, puis « Supprimer du compte ». Changez ensuite le mot de passe et vérifiez l'authentification à deux facteurs. Sur iOS 16+, « Vérification de sécurité » aide à réinitialiser les accès.",
                whereToCheck: "Réglages > [votre nom] ; Réglages > Confidentialité et sécurité > Vérification de sécurité",
                level: .high, origin: .declared)),
    ]

    // MARK: Autorisations

    struct PermissionInfo: Identifiable {
        let id = UUID()
        let icon: String
        let name: String
        let access: String
        let risk: String
    }

    static let permissions: [PermissionInfo] = [
        .init(icon: "location.fill", name: "Localisation",
              access: "Position précise ou approximative, en continu ou seulement quand l'app est ouverte.",
              risk: "Déduire domicile, trajets, habitudes. Préférez « Pendant l'utilisation » et désactivez « Position précise » si inutile."),
        .init(icon: "photo.fill", name: "Photos",
              access: "Toute la photothèque, ou une sélection que vous choisissez.",
              risk: "Photos, vidéos, et leurs métadonnées (lieu, date). Préférez « Photos sélectionnées »."),
        .init(icon: "person.2.fill", name: "Contacts",
              access: "Noms, numéros, e-mails, adresses de vos contacts.",
              risk: "Données sur des tiers qui ne vous ont rien demandé."),
        .init(icon: "mic.fill", name: "Microphone",
              access: "Enregistrer le son quand l'app l'utilise (un point orange s'affiche en haut).",
              risk: "Écoute ambiante possible tant que l'app est active."),
        .init(icon: "camera.fill", name: "Caméra",
              access: "Prendre photos et vidéos (un point vert s'affiche).",
              risk: "Capture d'images de votre environnement."),
        .init(icon: "app.badge", name: "Suivi entre apps",
              access: "Relier votre activité entre apps et sites d'autres entreprises.",
              risk: "Profilage publicitaire. Vous pouvez refuser pour toutes les apps."),
        .init(icon: "keyboard", name: "Clavier tiers : accès complet",
              access: "Voir ce que vous tapez dans l'app clavier.",
              risk: "Mots de passe et messages peuvent transiter. À n'accorder qu'avec une confiance forte."),
        .init(icon: "heart.fill", name: "Santé et mouvement",
              access: "Données de santé, activité, mouvements.",
              risk: "Données très sensibles, à limiter aux apps de santé légitimes."),
        .init(icon: "wifi", name: "Réseau local et Bluetooth",
              access: "Découvrir les appareils proches ou du réseau domestique.",
              risk: "Cartographier votre environnement et vos appareils."),
        .init(icon: "bell.badge.fill", name: "Notifications",
              access: "Vous envoyer des alertes, sons et pastilles.",
              risk: "Faible pour la vie privée, mais peut servir à vous solliciter."),
    ]

    // MARK: Comptes

    struct AccountTask: Identifiable {
        let id: String
        let title: String
        let detail: String
    }

    static let accountTasks: [AccountTask] = [
        .init(id: "2fa", title: "Activer l'authentification à deux facteurs",
              detail: "Réglages > [votre nom] > Connexion et sécurité. Elle protège votre compte même si le mot de passe fuite."),
        .init(id: "password", title: "Utiliser un mot de passe unique et long",
              detail: "Utilisez le Trousseau iCloud ou un gestionnaire de mots de passe. Réglages > Mots de passe > Recommandations de sécurité."),
        .init(id: "devices", title: "Contrôler la liste des appareils",
              detail: "Réglages > [votre nom], faites défiler : supprimez tout appareil inconnu."),
        .init(id: "safety_check", title: "Lancer la Vérification de sécurité (iOS 16+)",
              detail: "Réglages > Confidentialité et sécurité > Vérification de sécurité : revoyez les personnes et apps qui ont accès à vos données."),
        .init(id: "privacy_report", title: "Lire le Rapport de confidentialité des apps",
              detail: "Réglages > Confidentialité et sécurité > Rapport de confidentialité des apps : il montre quelles apps ont utilisé micro, caméra, position, réseau."),
        .init(id: "passcode", title: "Choisir un code de verrouillage de 6 chiffres ou plus",
              detail: "Réglages > Face ID et code. Ne le partagez pas, sauf choix délibéré."),
        .init(id: "sign_in_apple", title: "Revoir les apps liées à votre compte",
              detail: "Réglages > [votre nom] > Connexion et sécurité > Se connecter avec Apple."),
    ]
}
