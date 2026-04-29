import SwiftUI

struct WheelOption: Identifiable, Equatable {
    var id = UUID()
    var name: String
    var color: Color

    static func == (lhs: WheelOption, rhs: WheelOption) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name && lhs.color == rhs.color
    }
}

extension WheelOption {
    var asSessionOption: SessionOption {
        SessionOption(name: name, colorHex: color.hexString)
    }
}

// MARK: - Session history models

struct SessionOption: Identifiable, Codable {
    var id = UUID()
    var name: String
    var colorHex: String

    var color: Color { Color(hex: colorHex) }
}

struct SpinSession: Identifiable, Codable {
    var id = UUID()
    var timestamp: Date
    var winners: [SessionOption]
    var wheelOptions: [SessionOption]
    var isRankSession: Bool
    var isSynced: Bool = false
}

extension WheelOption {
    static let defaults: [WheelOption] = [
        WheelOption(name: "Tacos",       color: Color(hex: "#ffd4b8")),
        WheelOption(name: "Sushi",       color: Color(hex: "#bfeed6")),
        WheelOption(name: "Pizza",       color: Color(hex: "#ffc1d0")),
        WheelOption(name: "Ramen",       color: Color(hex: "#c8bfff")),
        WheelOption(name: "Salad",       color: Color(hex: "#bfdcff")),
        WheelOption(name: "Call it off", color: Color(hex: "#d8b8ff")),
    ]
}
