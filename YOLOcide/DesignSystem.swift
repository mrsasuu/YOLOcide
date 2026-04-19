//
//  DesignSystem.swift
//  YOLOcide
//

import SwiftUI

// MARK: - Color tokens

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    // Adaptive app background: #f4f4f7 light / #3a3d4a dark
    static let ycBg = Color(uiColor: UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(red: 0.227, green: 0.239, blue: 0.290, alpha: 1)
            : UIColor(red: 0.957, green: 0.957, blue: 0.969, alpha: 1)
    })

    // Adaptive elevated surface: white light / #454856 dark
    static let ycSurface = Color(uiColor: UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(red: 0.271, green: 0.282, blue: 0.337, alpha: 1)
            : UIColor.white
    })

    // Primary purple #6c5ce7
    static let ycPurple = Color(hex: "#6c5ce7")

    // Wheel pastel palette (20 colors, light-mode full opacity; dark mode apply 0.70 opacity)
    static let wheelPastels: [Color] = [
        Color(hex: "#c8bfff"),  // lavender
        Color(hex: "#bfdcff"),  // sky
        Color(hex: "#bfeed6"),  // mint
        Color(hex: "#ffd4b8"),  // peach
        Color(hex: "#ffc1d0"),  // rose
        Color(hex: "#d8b8ff"),  // violet
        Color(hex: "#ffe8a8"),  // butter
        Color(hex: "#b8ecec"),  // aqua
        Color(hex: "#ffb3b3"),  // salmon
        Color(hex: "#ffd6a5"),  // tangerine
        Color(hex: "#fdffb6"),  // lemon
        Color(hex: "#caffbf"),  // lime
        Color(hex: "#9bf6ff"),  // cyan
        Color(hex: "#a0c4ff"),  // cornflower
        Color(hex: "#bdb2ff"),  // periwinkle
        Color(hex: "#ffc6ff"),  // pink
        Color(hex: "#e8d5b7"),  // sand
        Color(hex: "#d4e8d7"),  // sage
        Color(hex: "#f0d9ff"),  // lilac
        Color(hex: "#ffe5d9"),  // blush
    ]
}

// MARK: - Button styles

struct ScaleButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.97
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.spring(response: 0.18, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Primary CTA button

struct PrimaryButton: View {
    let label: String
    let disabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(Color.ycPurple.opacity(disabled ? 0.4 : 1))
                        .shadow(
                            color: disabled ? .clear : Color.ycPurple.opacity(0.28),
                            radius: 10, y: 4
                        )
                )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(disabled)
    }
}
