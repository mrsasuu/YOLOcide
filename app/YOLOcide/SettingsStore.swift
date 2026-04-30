import SwiftUI

enum AppLanguage: String, CaseIterable {
    case english    = "en"
    case spanish    = "es"
    case french     = "fr"
    case portuguese = "pt"
    case german     = "de"
    case italian    = "it"
    case polish     = "pl"

    var displayName: String {
        switch self {
        case .english:    return "English"
        case .spanish:    return "Español"
        case .french:     return "Français"
        case .portuguese: return "Português"
        case .german:     return "Deutsch"
        case .italian:    return "Italiano"
        case .polish:     return "Polski"
        }
    }
}

enum AppAppearance: String, CaseIterable {
    case system, light, dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    var labelKey: String {
        switch self {
        case .system: return "help.settings.appearance.system"
        case .light:  return "help.settings.appearance.light"
        case .dark:   return "help.settings.appearance.dark"
        }
    }
}

final class SettingsStore: ObservableObject {
    @Published var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: "yolocide_language") }
    }
    @Published var appearance: AppAppearance {
        didSet { UserDefaults.standard.set(appearance.rawValue, forKey: "yolocide_appearance") }
    }
    @Published var hapticsEnabled: Bool {
        didSet { UserDefaults.standard.set(hapticsEnabled, forKey: "yolocide_haptics") }
    }

    init() {
        let code = UserDefaults.standard.string(forKey: "yolocide_language") ?? "en"
        language = AppLanguage(rawValue: code) ?? .english

        let appearanceRaw = UserDefaults.standard.string(forKey: "yolocide_appearance") ?? "system"
        appearance = AppAppearance(rawValue: appearanceRaw) ?? .system

        let hapticsSaved = UserDefaults.standard.object(forKey: "yolocide_haptics")
        hapticsEnabled = hapticsSaved == nil ? true : UserDefaults.standard.bool(forKey: "yolocide_haptics")
    }

    func t(_ key: String) -> String {
        let dict: [String: String]
        switch language {
        case .english:    dict = Self.en
        case .spanish:    dict = Self.es
        case .french:     dict = Self.fr
        case .portuguese: dict = Self.pt
        case .german:     dict = Self.de
        case .italian:    dict = Self.it
        case .polish:     dict = Self.pl
        }
        return dict[key] ?? Self.en[key] ?? key
    }

    // MARK: - English

    private static let en: [String: String] = [
        "options.show":             "Show options",
        "options.hide":             "Hide options",
        "options.empty":            "Nothing to decide yet. Add an option.",
        "spin.cta":                 "Spin my fate",
        "spin.inprogress":          "Spinning…",
        "rank.toggle":              "Rank 'em all",
        "rank.view":                "%d ranked — view",
        "rank.clear":               "Clear",
        "result.header":            "Fate has spoken",
        "result.rank.header":       "Pick #%d",
        "result.dismiss":           "Sounds good",
        "result.next":              "Next round",
        "result.seerankings":       "See rankings",
        "add.title":                "Add an option",
        "add.placeholder":          "e.g. Pizza",
        "add.button":               "Add to wheel",
        "winners.title":            "Rankings",
        "winners.subtitle":         "In the order fate decided.",
        "winners.startover":        "Start over",
        "winners.done":             "Done",
        "history.title":            "History",
        "history.empty.title":      "No sessions yet",
        "history.empty.subtitle":   "Spin the wheel to start building your history.",
        "history.clearall":         "Clear all",
        "history.clearall.confirm": "Clear all history?",
        "history.ranked.badge":     "Ranked",
        "history.wheel.label":      "Wheel",
        "history.options.count":    "%d options",
        "history.date.today":       "Today · %@",
        "history.date.yesterday":   "Yesterday · %@",
        "history.more":             "+%d more",
        "help.title":               "Help & Settings",
        "help.section.howto":       "How it works",
        "help.section.rankmode":    "Rank 'em all",
        "help.section.options":     "Managing options",
        "help.section.signin":      "Sign In & Sync",
        "help.section.settings":    "Settings",
        "help.howto.body":          "Add your options with the + button, then spin the wheel. The app randomly picks a winner from all the segments. Tap the center of the wheel or the \"Spin my fate\" button to spin.",
        "help.rankmode.body":       "Enable \"Rank 'em all\" to rank every option. Each spin picks a winner and removes it from the wheel. Keep going until all options are ranked — the final order is saved to history.",
        "help.options.body":        "Tap \"Show options\" to manage your wheel. Use the pencil icon to rename, the color circle to change colors, and the trash icon in the color picker to delete an option.",
        "help.signin.body":         "Sign in with Apple or Google to back up your wheels and spin history to the cloud. Your data syncs automatically across all your devices. Sessions recorded while offline or before signing in are queued and uploaded the next time you come online.",
        "help.settings.language":          "Language",
        "help.settings.appearance":        "Appearance",
        "help.settings.appearance.system": "System",
        "help.settings.appearance.light":  "Light",
        "help.settings.appearance.dark":   "Dark",
        "help.settings.haptics":           "Haptic feedback",
        "add.option":                      "Add option",
        "signin.title":                    "Welcome to YOLOcide",
        "signin.subtitle":                 "Back up your wheels and spin history, sync across all your devices, and never lose a session — it's free.",
        "signin.google":                   "Continue with Google",
        "signin.later":                    "Maybe later",
        "signin.signedin":                 "Signed in",
        "signin.signout":                  "Sign out",
        "signin.deleteaccount":            "Delete Account",
        "signin.deleteaccount.title":      "Delete Account?",
        "signin.deleteaccount.message":    "This will permanently delete your account and all your data. This cannot be undone.",
        "signin.deleteaccount.cancel":     "Cancel",
    ]

    // MARK: - Spanish

    private static let es: [String: String] = [
        "options.show":             "Ver opciones",
        "options.hide":             "Ocultar opciones",
        "options.empty":            "Nada que decidir todavía. Añade una opción.",
        "spin.cta":                 "¡Que decida el azar!",
        "spin.inprogress":          "Girando…",
        "rank.toggle":              "Rankear todo",
        "rank.view":                "%d rankeados — ver",
        "rank.clear":               "Borrar",
        "result.header":            "El destino ha hablado",
        "result.rank.header":       "Elección #%d",
        "result.dismiss":           "De acuerdo",
        "result.next":              "Siguiente ronda",
        "result.seerankings":       "Ver rankings",
        "add.title":                "Añadir opción",
        "add.placeholder":          "p. ej. Pizza",
        "add.button":               "Añadir a la ruleta",
        "winners.title":            "Rankings",
        "winners.subtitle":         "En el orden que decidió el destino.",
        "winners.startover":        "Empezar de nuevo",
        "winners.done":             "Hecho",
        "history.title":            "Historial",
        "history.empty.title":      "Sin sesiones aún",
        "history.empty.subtitle":   "Gira la ruleta para empezar a crear tu historial.",
        "history.clearall":         "Borrar todo",
        "history.clearall.confirm": "¿Borrar todo el historial?",
        "history.ranked.badge":     "Rankeado",
        "history.wheel.label":      "Ruleta",
        "history.options.count":    "%d opciones",
        "history.date.today":       "Hoy · %@",
        "history.date.yesterday":   "Ayer · %@",
        "history.more":             "+%d más",
        "help.title":               "Ayuda y Ajustes",
        "help.section.howto":       "Cómo funciona",
        "help.section.rankmode":    "Rankear todo",
        "help.section.options":     "Gestionar opciones",
        "help.section.signin":      "Iniciar Sesión y Sincronizar",
        "help.section.settings":    "Ajustes",
        "help.howto.body":          "Añade tus opciones con el botón +, luego gira la ruleta. La app elige un ganador al azar entre todos los segmentos. Toca el centro de la ruleta o el botón \"¡Que decida el azar!\" para girar.",
        "help.rankmode.body":       "Activa \"Rankear todo\" para ordenar todas las opciones. Cada giro elige un ganador y lo elimina de la ruleta. Sigue girando hasta que todas estén rankeadas — el orden final se guarda en el historial.",
        "help.options.body":        "Toca \"Ver opciones\" para gestionar tu ruleta. Usa el icono del lápiz para renombrar, el círculo de color para cambiar colores, y el icono de papelera en el selector para eliminar.",
        "help.signin.body":         "Inicia sesión con Apple o Google para guardar tus ruletas e historial en la nube. Tus datos se sincronizan automáticamente en todos tus dispositivos. Las sesiones registradas sin conexión o antes de iniciar sesión se ponen en cola y se suben la próxima vez que te conectes.",
        "help.settings.language":          "Idioma",
        "help.settings.appearance":        "Apariencia",
        "help.settings.appearance.system": "Sistema",
        "help.settings.appearance.light":  "Claro",
        "help.settings.appearance.dark":   "Oscuro",
        "help.settings.haptics":           "Vibración táctil",
        "add.option":                      "Añadir opción",
        "signin.title":                    "Bienvenido a YOLOcide",
        "signin.subtitle":                 "Guarda tus ruletas e historial de giros, sincroniza en todos tus dispositivos y nunca pierdas una sesión — es gratis.",
        "signin.google":                   "Continuar con Google",
        "signin.later":                    "Quizás después",
        "signin.signedin":                 "Sesión iniciada",
        "signin.signout":                  "Cerrar sesión",
        "signin.deleteaccount":            "Eliminar cuenta",
        "signin.deleteaccount.title":      "¿Eliminar cuenta?",
        "signin.deleteaccount.message":    "Se eliminará permanentemente tu cuenta y todos tus datos. Esta acción no se puede deshacer.",
        "signin.deleteaccount.cancel":     "Cancelar",
    ]

    // MARK: - French

    private static let fr: [String: String] = [
        "options.show":             "Afficher les options",
        "options.hide":             "Masquer les options",
        "options.empty":            "Rien à décider encore. Ajoutez une option.",
        "spin.cta":                 "Laisser le sort décider",
        "spin.inprogress":          "En cours…",
        "rank.toggle":              "Tout classer",
        "rank.view":                "%d classés — voir",
        "rank.clear":               "Effacer",
        "result.header":            "Le sort en a décidé",
        "result.rank.header":       "Choix #%d",
        "result.dismiss":           "D'accord",
        "result.next":              "Tour suivant",
        "result.seerankings":       "Voir le classement",
        "add.title":                "Ajouter une option",
        "add.placeholder":          "ex. Pizza",
        "add.button":               "Ajouter à la roue",
        "winners.title":            "Classement",
        "winners.subtitle":         "Dans l'ordre décidé par le sort.",
        "winners.startover":        "Recommencer",
        "winners.done":             "Terminé",
        "history.title":            "Historique",
        "history.empty.title":      "Aucune session",
        "history.empty.subtitle":   "Faites tourner la roue pour commencer votre historique.",
        "history.clearall":         "Tout effacer",
        "history.clearall.confirm": "Effacer tout l'historique ?",
        "history.ranked.badge":     "Classé",
        "history.wheel.label":      "Roue",
        "history.options.count":    "%d options",
        "history.date.today":       "Aujourd'hui · %@",
        "history.date.yesterday":   "Hier · %@",
        "history.more":             "+%d autres",
        "help.title":               "Aide & Paramètres",
        "help.section.howto":       "Comment ça marche",
        "help.section.rankmode":    "Tout classer",
        "help.section.options":     "Gérer les options",
        "help.section.signin":      "Connexion & Synchronisation",
        "help.section.settings":    "Paramètres",
        "help.howto.body":          "Ajoutez vos options avec le bouton +, puis faites tourner la roue. L'app choisit un gagnant au hasard parmi tous les segments. Touchez le centre de la roue ou le bouton « Laisser le sort décider » pour tourner.",
        "help.rankmode.body":       "Activez « Tout classer » pour ordonner toutes les options. Chaque tour choisit un gagnant et le retire de la roue. Continuez jusqu'à ce que tout soit classé — l'ordre final est sauvegardé dans l'historique.",
        "help.options.body":        "Touchez « Afficher les options » pour gérer votre roue. Utilisez l'icône crayon pour renommer, le cercle de couleur pour changer les couleurs, et l'icône corbeille dans le sélecteur pour supprimer une option.",
        "help.signin.body":         "Connectez-vous avec Apple ou Google pour sauvegarder vos roues et votre historique dans le cloud. Vos données se synchronisent automatiquement sur tous vos appareils. Les sessions enregistrées hors ligne ou avant la connexion sont mises en file d'attente et téléchargées à la prochaine connexion.",
        "help.settings.language":          "Langue",
        "help.settings.appearance":        "Apparence",
        "help.settings.appearance.system": "Système",
        "help.settings.appearance.light":  "Clair",
        "help.settings.appearance.dark":   "Sombre",
        "help.settings.haptics":           "Retour haptique",
        "add.option":                      "Ajouter une option",
        "signin.title":                    "Bienvenue sur YOLOcide",
        "signin.subtitle":                 "Sauvegardez vos roues et votre historique, synchronisez sur tous vos appareils et ne perdez jamais une session — c'est gratuit.",
        "signin.google":                   "Continuer avec Google",
        "signin.later":                    "Peut-être plus tard",
        "signin.signedin":                 "Connecté",
        "signin.signout":                  "Se déconnecter",
        "signin.deleteaccount":            "Supprimer le compte",
        "signin.deleteaccount.title":      "Supprimer le compte ?",
        "signin.deleteaccount.message":    "Cela supprimera définitivement votre compte et toutes vos données. Cette action est irréversible.",
        "signin.deleteaccount.cancel":     "Annuler",
    ]

    // MARK: - Portuguese

    private static let pt: [String: String] = [
        "options.show":             "Mostrar opções",
        "options.hide":             "Ocultar opções",
        "options.empty":            "Nada para decidir ainda. Adicione uma opção.",
        "spin.cta":                 "Deixa o destino decidir",
        "spin.inprogress":          "Girando…",
        "rank.toggle":              "Rankear tudo",
        "rank.view":                "%d rankeados — ver",
        "rank.clear":               "Limpar",
        "result.header":            "O destino falou",
        "result.rank.header":       "Escolha #%d",
        "result.dismiss":           "Combinado",
        "result.next":              "Próxima rodada",
        "result.seerankings":       "Ver rankings",
        "add.title":                "Adicionar opção",
        "add.placeholder":          "ex: Pizza",
        "add.button":               "Adicionar à roleta",
        "winners.title":            "Rankings",
        "winners.subtitle":         "Na ordem que o destino decidiu.",
        "winners.startover":        "Recomeçar",
        "winners.done":             "Feito",
        "history.title":            "Histórico",
        "history.empty.title":      "Nenhuma sessão ainda",
        "history.empty.subtitle":   "Gire a roleta para começar o seu histórico.",
        "history.clearall":         "Limpar tudo",
        "history.clearall.confirm": "Limpar todo o histórico?",
        "history.ranked.badge":     "Rankeado",
        "history.wheel.label":      "Roleta",
        "history.options.count":    "%d opções",
        "history.date.today":       "Hoje · %@",
        "history.date.yesterday":   "Ontem · %@",
        "history.more":             "+%d mais",
        "help.title":               "Ajuda & Configurações",
        "help.section.howto":       "Como funciona",
        "help.section.rankmode":    "Rankear tudo",
        "help.section.options":     "Gerenciar opções",
        "help.section.signin":      "Login & Sincronização",
        "help.section.settings":    "Configurações",
        "help.howto.body":          "Adicione suas opções com o botão +, depois gire a roleta. O app escolhe um vencedor aleatório entre todos os segmentos. Toque no centro da roleta ou no botão \"Deixa o destino decidir\" para girar.",
        "help.rankmode.body":       "Ative \"Rankear tudo\" para classificar todas as opções. Cada giro escolhe um vencedor e o remove da roleta. Continue até que todas estejam rankeadas — a ordem final é salva no histórico.",
        "help.options.body":        "Toque em \"Mostrar opções\" para gerenciar sua roleta. Use o ícone de lápis para renomear, o círculo de cor para mudar cores, e o ícone de lixeira no seletor para excluir.",
        "help.signin.body":         "Entre com Apple ou Google para fazer backup das suas roletas e histórico na nuvem. Seus dados sincronizam automaticamente em todos os seus dispositivos. Sessões gravadas offline ou antes de entrar ficam na fila e são enviadas na próxima vez que você se conectar.",
        "help.settings.language":          "Idioma",
        "help.settings.appearance":        "Aparência",
        "help.settings.appearance.system": "Sistema",
        "help.settings.appearance.light":  "Claro",
        "help.settings.appearance.dark":   "Escuro",
        "help.settings.haptics":           "Feedback tátil",
        "add.option":                      "Adicionar opção",
        "signin.title":                    "Bem-vindo ao YOLOcide",
        "signin.subtitle":                 "Salve suas roletas e histórico de giros, sincronize em todos os seus dispositivos e nunca perca uma sessão — é grátis.",
        "signin.google":                   "Continuar com o Google",
        "signin.later":                    "Talvez mais tarde",
        "signin.signedin":                 "Conectado",
        "signin.signout":                  "Sair",
        "signin.deleteaccount":            "Excluir conta",
        "signin.deleteaccount.title":      "Excluir conta?",
        "signin.deleteaccount.message":    "Isso excluirá permanentemente sua conta e todos os seus dados. Esta ação não pode ser desfeita.",
        "signin.deleteaccount.cancel":     "Cancelar",
    ]

    // MARK: - German

    private static let de: [String: String] = [
        "options.show":             "Optionen anzeigen",
        "options.hide":             "Optionen ausblenden",
        "options.empty":            "Noch nichts zu entscheiden. Füge eine Option hinzu.",
        "spin.cta":                 "Das Schicksal entscheiden lassen",
        "spin.inprogress":          "Dreht…",
        "rank.toggle":              "Alles ranken",
        "rank.view":                "%d gerankt — anzeigen",
        "rank.clear":               "Löschen",
        "result.header":            "Das Schicksal hat gesprochen",
        "result.rank.header":       "Auswahl #%d",
        "result.dismiss":           "Klingt gut",
        "result.next":              "Nächste Runde",
        "result.seerankings":       "Ranking ansehen",
        "add.title":                "Option hinzufügen",
        "add.placeholder":          "z. B. Pizza",
        "add.button":               "Zum Rad hinzufügen",
        "winners.title":            "Ranking",
        "winners.subtitle":         "In der Reihenfolge, die das Schicksal entschieden hat.",
        "winners.startover":        "Neu beginnen",
        "winners.done":             "Fertig",
        "history.title":            "Verlauf",
        "history.empty.title":      "Noch keine Sitzungen",
        "history.empty.subtitle":   "Drehe das Rad, um deinen Verlauf zu starten.",
        "history.clearall":         "Alles löschen",
        "history.clearall.confirm": "Gesamten Verlauf löschen?",
        "history.ranked.badge":     "Gerankt",
        "history.wheel.label":      "Rad",
        "history.options.count":    "%d Optionen",
        "history.date.today":       "Heute · %@",
        "history.date.yesterday":   "Gestern · %@",
        "history.more":             "+%d weitere",
        "help.title":               "Hilfe & Einstellungen",
        "help.section.howto":       "So funktioniert's",
        "help.section.rankmode":    "Alles ranken",
        "help.section.options":     "Optionen verwalten",
        "help.section.signin":      "Anmelden & Synchronisieren",
        "help.section.settings":    "Einstellungen",
        "help.howto.body":          "Füge deine Optionen mit dem +-Button hinzu und drehe das Rad. Die App wählt zufällig einen Gewinner aus allen Segmenten. Tippe auf die Mitte des Rades oder den Button \"Das Schicksal entscheiden lassen\", um zu drehen.",
        "help.rankmode.body":       "Aktiviere \"Alles ranken\", um alle Optionen zu bewerten. Jede Drehung wählt einen Gewinner und entfernt ihn vom Rad. Mache weiter, bis alle bewertet sind — die Reihenfolge wird im Verlauf gespeichert.",
        "help.options.body":        "Tippe auf \"Optionen anzeigen\", um dein Rad zu verwalten. Verwende das Bleistift-Symbol zum Umbenennen, den Farbkreis zum Ändern der Farben und das Papierkorb-Symbol im Farbwähler zum Löschen.",
        "help.signin.body":         "Melde dich mit Apple oder Google an, um deine Räder und deinen Verlauf in der Cloud zu sichern. Deine Daten werden automatisch auf all deinen Geräten synchronisiert. Sitzungen, die offline oder vor der Anmeldung aufgezeichnet wurden, werden in eine Warteschlange gestellt und beim nächsten Online-Gehen hochgeladen.",
        "help.settings.language":          "Sprache",
        "help.settings.appearance":        "Erscheinungsbild",
        "help.settings.appearance.system": "System",
        "help.settings.appearance.light":  "Hell",
        "help.settings.appearance.dark":   "Dunkel",
        "help.settings.haptics":           "Haptisches Feedback",
        "add.option":                      "Option hinzufügen",
        "signin.title":                    "Willkommen bei YOLOcide",
        "signin.subtitle":                 "Sichere deine Räder und deinen Verlauf, synchronisiere auf all deinen Geräten und verliere nie eine Sitzung — kostenlos.",
        "signin.google":                   "Mit Google fortfahren",
        "signin.later":                    "Vielleicht später",
        "signin.signedin":                 "Angemeldet",
        "signin.signout":                  "Abmelden",
        "signin.deleteaccount":            "Konto löschen",
        "signin.deleteaccount.title":      "Konto löschen?",
        "signin.deleteaccount.message":    "Dein Konto und alle deine Daten werden dauerhaft gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.",
        "signin.deleteaccount.cancel":     "Abbrechen",
    ]

    // MARK: - Italian

    private static let it: [String: String] = [
        "options.show":             "Mostra opzioni",
        "options.hide":             "Nascondi opzioni",
        "options.empty":            "Niente da decidere ancora. Aggiungi un'opzione.",
        "spin.cta":                 "Lascia decidere al caso",
        "spin.inprogress":          "Girando…",
        "rank.toggle":              "Classifica tutto",
        "rank.view":                "%d classificati — vedi",
        "rank.clear":               "Cancella",
        "result.header":            "Il destino ha parlato",
        "result.rank.header":       "Scelta #%d",
        "result.dismiss":           "Va bene",
        "result.next":              "Prossimo turno",
        "result.seerankings":       "Vedi classifica",
        "add.title":                "Aggiungi un'opzione",
        "add.placeholder":          "es. Pizza",
        "add.button":               "Aggiungi alla ruota",
        "winners.title":            "Classifica",
        "winners.subtitle":         "Nell'ordine deciso dal caso.",
        "winners.startover":        "Ricomincia",
        "winners.done":             "Fatto",
        "history.title":            "Cronologia",
        "history.empty.title":      "Nessuna sessione",
        "history.empty.subtitle":   "Gira la ruota per iniziare la tua cronologia.",
        "history.clearall":         "Cancella tutto",
        "history.clearall.confirm": "Cancellare tutta la cronologia?",
        "history.ranked.badge":     "Classificato",
        "history.wheel.label":      "Ruota",
        "history.options.count":    "%d opzioni",
        "history.date.today":       "Oggi · %@",
        "history.date.yesterday":   "Ieri · %@",
        "history.more":             "+%d altri",
        "help.title":               "Aiuto & Impostazioni",
        "help.section.howto":       "Come funziona",
        "help.section.rankmode":    "Classifica tutto",
        "help.section.options":     "Gestisci opzioni",
        "help.section.signin":      "Accesso & Sincronizzazione",
        "help.section.settings":    "Impostazioni",
        "help.howto.body":          "Aggiungi le tue opzioni con il pulsante +, poi gira la ruota. L'app sceglie casualmente un vincitore tra tutti i segmenti. Tocca il centro della ruota o il pulsante \"Lascia decidere al caso\" per girare.",
        "help.rankmode.body":       "Attiva \"Classifica tutto\" per classificare tutte le opzioni. Ogni giro sceglie un vincitore e lo rimuove dalla ruota. Continua finché tutte sono classificate — l'ordine finale viene salvato nella cronologia.",
        "help.options.body":        "Tocca \"Mostra opzioni\" per gestire la tua ruota. Usa l'icona della matita per rinominare, il cerchio colorato per cambiare i colori e l'icona del cestino nel selettore per eliminare.",
        "help.signin.body":         "Accedi con Apple o Google per salvare le tue ruote e la cronologia nel cloud. I tuoi dati si sincronizzano automaticamente su tutti i tuoi dispositivi. Le sessioni registrate offline o prima dell'accesso vengono messe in coda e caricate la prossima volta che vai online.",
        "help.settings.language":          "Lingua",
        "help.settings.appearance":        "Aspetto",
        "help.settings.appearance.system": "Sistema",
        "help.settings.appearance.light":  "Chiaro",
        "help.settings.appearance.dark":   "Scuro",
        "help.settings.haptics":           "Feedback aptico",
        "add.option":                      "Aggiungi opzione",
        "signin.title":                    "Benvenuto su YOLOcide",
        "signin.subtitle":                 "Salva le tue ruote e la cronologia, sincronizza su tutti i tuoi dispositivi e non perdere mai una sessione — è gratuito.",
        "signin.google":                   "Continua con Google",
        "signin.later":                    "Forse più tardi",
        "signin.signedin":                 "Accesso eseguito",
        "signin.signout":                  "Disconnetti",
        "signin.deleteaccount":            "Elimina account",
        "signin.deleteaccount.title":      "Eliminare l'account?",
        "signin.deleteaccount.message":    "Il tuo account e tutti i tuoi dati verranno eliminati definitivamente. Questa azione non può essere annullata.",
        "signin.deleteaccount.cancel":     "Annulla",
    ]

    // MARK: - Polish

    private static let pl: [String: String] = [
        "options.show":             "Pokaż opcje",
        "options.hide":             "Ukryj opcje",
        "options.empty":            "Nie ma jeszcze nic do zdecydowania. Dodaj opcję.",
        "spin.cta":                 "Niech los zdecyduje",
        "spin.inprogress":          "Kręci się…",
        "rank.toggle":              "Uszereguj wszystko",
        "rank.view":                "%d uszeregowanych — wyświetl",
        "rank.clear":               "Wyczyść",
        "result.header":            "Los przemówił",
        "result.rank.header":       "Wybór #%d",
        "result.dismiss":           "Brzmi dobrze",
        "result.next":              "Następna runda",
        "result.seerankings":       "Zobacz ranking",
        "add.title":                "Dodaj opcję",
        "add.placeholder":          "np. Pizza",
        "add.button":               "Dodaj do koła",
        "winners.title":            "Ranking",
        "winners.subtitle":         "W kolejności, jaką zdecydował los.",
        "winners.startover":        "Zacznij od nowa",
        "winners.done":             "Gotowe",
        "history.title":            "Historia",
        "history.empty.title":      "Brak sesji",
        "history.empty.subtitle":   "Zakręć kołem, aby rozpocząć historię.",
        "history.clearall":         "Wyczyść wszystko",
        "history.clearall.confirm": "Wyczyścić całą historię?",
        "history.ranked.badge":     "Uszeregowano",
        "history.wheel.label":      "Koło",
        "history.options.count":    "%d opcji",
        "history.date.today":       "Dziś · %@",
        "history.date.yesterday":   "Wczoraj · %@",
        "history.more":             "+%d więcej",
        "help.title":               "Pomoc i Ustawienia",
        "help.section.howto":       "Jak to działa",
        "help.section.rankmode":    "Uszereguj wszystko",
        "help.section.options":     "Zarządzanie opcjami",
        "help.section.signin":      "Logowanie i Synchronizacja",
        "help.section.settings":    "Ustawienia",
        "help.howto.body":          "Dodaj opcje przyciskiem +, a następnie zakręć kołem. Aplikacja losowo wybiera zwycięzcę spośród wszystkich segmentów. Dotknij środka koła lub przycisku \"Niech los zdecyduje\", aby zakręcić.",
        "help.rankmode.body":       "Włącz \"Uszereguj wszystko\", aby uszeregować każdą opcję. Każde kręcenie wybiera zwycięzcę i usuwa go z koła. Kontynuuj, aż wszystkie opcje zostaną uszeregowane — ostateczna kolejność jest zapisywana w historii.",
        "help.options.body":        "Dotknij \"Pokaż opcje\", aby zarządzać kołem. Użyj ikony ołówka do zmiany nazwy, kółka kolorów do zmiany koloru i ikony kosza w selektorze kolorów do usunięcia opcji.",
        "help.signin.body":         "Zaloguj się przez Apple lub Google, aby zapisać swoje koła i historię w chmurze. Dane synchronizują się automatycznie na wszystkich Twoich urządzeniach. Sesje zarejestrowane offline lub przed zalogowaniem są umieszczane w kolejce i przesyłane przy kolejnym połączeniu z internetem.",
        "help.settings.language":          "Język",
        "help.settings.appearance":        "Wygląd",
        "help.settings.appearance.system": "Systemowy",
        "help.settings.appearance.light":  "Jasny",
        "help.settings.appearance.dark":   "Ciemny",
        "help.settings.haptics":           "Wibracje",
        "add.option":                      "Dodaj opcję",
        "signin.title":                    "Witaj w YOLOcide",
        "signin.subtitle":                 "Zapisz swoje koła i historię kręceń, synchronizuj na wszystkich urządzeniach i nigdy nie trać sesji — to bezpłatne.",
        "signin.google":                   "Kontynuuj z Google",
        "signin.later":                    "Może później",
        "signin.signedin":                 "Zalogowano",
        "signin.signout":                  "Wyloguj",
        "signin.deleteaccount":            "Usuń konto",
        "signin.deleteaccount.title":      "Usunąć konto?",
        "signin.deleteaccount.message":    "Spowoduje to trwałe usunięcie Twojego konta i wszystkich danych. Tej operacji nie można cofnąć.",
        "signin.deleteaccount.cancel":     "Anuluj",
    ]
}
