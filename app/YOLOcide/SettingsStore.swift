import SwiftUI

enum AppLanguage: String, CaseIterable {
    case english = "en"
    case spanish = "es"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
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
        let dict = language == .spanish ? Self.es : Self.en
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
        "help.section.settings":    "Settings",
        "help.howto.body":          "Add your options with the + button, then spin the wheel. The app randomly picks a winner from all the segments. Tap the center of the wheel or the \"Spin my fate\" button to spin.",
        "help.rankmode.body":       "Enable \"Rank 'em all\" to rank every option. Each spin picks a winner and removes it from the wheel. Keep going until all options are ranked — the final order is saved to history.",
        "help.options.body":        "Tap \"Show options\" to manage your wheel. Use the pencil icon to rename, the color circle to change colors, and the trash icon in the color picker to delete an option.",
        "help.settings.language":          "Language",
        "help.settings.appearance":        "Appearance",
        "help.settings.appearance.system": "System",
        "help.settings.appearance.light":  "Light",
        "help.settings.appearance.dark":   "Dark",
        "help.settings.haptics":           "Haptic feedback",
        "add.option":                      "Add option",
        "signin.title":                    "Welcome to YOLOcide",
        "signin.subtitle":                 "Sign in to save your wheels and rankings across devices.",
        "signin.google":                   "Continue with Google",
        "signin.later":                    "Maybe later",
        "signin.signedin":                 "Signed in",
        "signin.signout":                  "Sign out",
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
        "help.section.settings":    "Ajustes",
        "help.howto.body":          "Añade tus opciones con el botón +, luego gira la ruleta. La app elige un ganador al azar entre todos los segmentos. Toca el centro de la ruleta o el botón \"¡Que decida el azar!\" para girar.",
        "help.rankmode.body":       "Activa \"Rankear todo\" para ordenar todas las opciones. Cada giro elige un ganador y lo elimina de la ruleta. Sigue girando hasta que todas estén rankeadas — el orden final se guarda en el historial.",
        "help.options.body":        "Toca \"Ver opciones\" para gestionar tu ruleta. Usa el icono del lápiz para renombrar, el círculo de color para cambiar colores, y el icono de papelera en el selector para eliminar.",
        "help.settings.language":          "Idioma",
        "help.settings.appearance":        "Apariencia",
        "help.settings.appearance.system": "Sistema",
        "help.settings.appearance.light":  "Claro",
        "help.settings.appearance.dark":   "Oscuro",
        "help.settings.haptics":           "Vibración táctil",
        "add.option":                      "Añadir opción",
        "signin.title":                    "Bienvenido a YOLOcide",
        "signin.subtitle":                 "Inicia sesión para guardar tus ruletas y rankings en todos tus dispositivos.",
        "signin.google":                   "Continuar con Google",
        "signin.later":                    "Quizás después",
        "signin.signedin":                 "Sesión iniciada",
        "signin.signout":                  "Cerrar sesión",
    ]
}
