//
//  Models.swift
//  YOLOcide
//

import SwiftUI

struct WheelOption: Identifiable, Equatable {
    var id = UUID()
    var name: String
    var color: Color

    static func == (lhs: WheelOption, rhs: WheelOption) -> Bool {
        lhs.id == rhs.id
    }
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
