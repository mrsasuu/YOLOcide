//
//  WheelView.swift
//  YOLOcide
//

import SwiftUI

// MARK: - Pie slice shape

private struct WheelSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        var p = Path()
        p.move(to: center)
        p.addArc(center: center, radius: r,
                 startAngle: startAngle, endAngle: endAngle,
                 clockwise: false)
        p.closeSubpath()
        return p
    }
}

// MARK: - Dividers canvas (extracted so Canvas closure has a simple concrete type)

private struct WheelDividers: View {
    let count: Int
    let segAngle: Double
    let radius: CGFloat
    let center: CGPoint
    let color: Color

    var body: some View {
        Canvas { ctx, _ in
            for i in 0..<count {
                let rad = (Double(i) * segAngle - 90) * .pi / 180
                var line = Path()
                line.move(to: center)
                line.addLine(to: CGPoint(
                    x: center.x + radius * CGFloat(cos(rad)),
                    y: center.y + radius * CGFloat(sin(rad))
                ))
                ctx.stroke(line, with: .color(color), lineWidth: 2)
            }
        }
    }
}

// MARK: - Rotating disc (slices + dividers + labels)

private struct WheelDisc: View {
    let options: [WheelOption]
    let size: CGFloat
    @Environment(\.colorScheme) private var scheme

    private var n: Int { options.count }
    private var sa: Double { 360.0 / Double(max(n, 1)) }
    private var r: CGFloat { (size - 2) / 2 }
    private var cx: CGFloat { size / 2 }
    private var cy: CGFloat { size / 2 }

    var body: some View {
        ZStack {
            slicesLayer
            dividersLayer
            labelsLayer
        }
        .frame(width: size, height: size)
    }

    @ViewBuilder
    private var slicesLayer: some View {
        let opacity: Double = scheme == .dark ? 0.70 : 1.0
        ForEach(options.indices, id: \.self) { i in
            let start = Double(i) * sa - 90
            WheelSlice(startAngle: .degrees(start), endAngle: .degrees(start + sa))
                .fill(options[i].color.opacity(opacity))
        }
    }

    private var dividersLayer: some View {
        WheelDividers(count: n, segAngle: sa, radius: r - 1, center: CGPoint(x: cx, y: cy),
                      color: scheme == .dark ? Color.white.opacity(0.55) : .white)
    }

    @ViewBuilder
    private var labelsLayer: some View {
        let labelColor: Color = scheme == .dark
            ? Color.white.opacity(0.85)
            : Color(red: 0.11, green: 0.11, blue: 0.11).opacity(0.80)
        let fontSize: CGFloat = max(9, min(14, size * 0.046))
        let labelR: CGFloat = r * 0.62
        let frameW: CGFloat = r * 0.72
        ForEach(options.indices, id: \.self) { i in
            let midDeg = Double(i) * sa + sa / 2 - 90
            let midRad = midDeg * .pi / 180
            Text(options[i].name)
                .font(.system(size: fontSize, weight: .medium))
                .foregroundStyle(labelColor)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(width: frameW)
                .rotationEffect(.degrees(midDeg + 90))
                .position(x: cx + labelR * CGFloat(cos(midRad)), y: cy + labelR * CGFloat(sin(midRad)))
        }
    }
}

// MARK: - Center cap

struct WheelCenterCap: View {
    let size: CGFloat
    let isSpinning: Bool
    let onTap: () -> Void
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle().fill(outerGradient)
                Circle().fill(innerFill).padding(2)
                Text(isSpinning ? "· · ·" : "Spin!")
                    .font(.system(size: max(13, size * 0.23), weight: .bold))
                    .foregroundStyle(scheme == .dark ? Color.white : Color(hex: "#3a2d8a"))
                    .tracking(-0.015 * max(13, size * 0.23))
            }
            .shadow(color: capShadow, radius: 17, x: 0, y: 9)
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.95))
        .frame(width: size, height: size)
        .disabled(isSpinning)
    }

    private var capShadow: Color {
        scheme == .dark ? Color.black.opacity(0.55) : Color(hex: "#3c288c").opacity(0.22)
    }

    private var outerGradient: LinearGradient {
        scheme == .dark
            ? LinearGradient(
                colors: [Color.white.opacity(0.18), Color.ycPurple.opacity(0.25), Color.black.opacity(0.45)],
                startPoint: UnitPoint(x: 0.2, y: 0.1), endPoint: UnitPoint(x: 0.9, y: 0.95))
            : LinearGradient(
                colors: [.white, Color(hex: "#d8ceff"), Color(hex: "#a79bff")],
                startPoint: UnitPoint(x: 0.2, y: 0.1), endPoint: UnitPoint(x: 0.9, y: 0.95))
    }

    private var innerFill: RadialGradient {
        scheme == .dark
            ? RadialGradient(
                colors: [Color(hex: "#3a3d4a"), Color(hex: "#24262f"), Color(hex: "#1a1b22")],
                center: UnitPoint(x: 0.5, y: 0.28), startRadius: 0, endRadius: size * 0.5)
            : RadialGradient(
                colors: [.white, Color(hex: "#f5f2ff"), Color(hex: "#ebe5ff")],
                center: UnitPoint(x: 0.5, y: 0.28), startRadius: 0, endRadius: size * 0.5)
    }
}

// MARK: - Wheel view

struct WheelView: View {
    let options: [WheelOption]
    let rotation: Double
    let isSpinning: Bool
    let onSpin: () -> Void

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let cx = geo.size.width / 2
            let cy = geo.size.height / 2
            let ringColor: Color = scheme == .dark
                ? Color.white.opacity(0.08)
                : Color(hex: "#3c288c").opacity(0.08)
            let shadowColor: Color = scheme == .dark
                ? Color.black.opacity(0.35)
                : Color(hex: "#3c288c").opacity(0.14)

            ZStack {
                if options.isEmpty {
                    Circle()
                        .stroke(Color(.separator), lineWidth: 2)
                        .frame(width: size - 2, height: size - 2)
                        .position(x: cx, y: cy)
                } else {
                    WheelDisc(options: options, size: size)
                        .rotationEffect(.degrees(rotation))
                        .shadow(color: shadowColor, radius: 32, x: 0, y: 22)
                        .position(x: cx, y: cy)
                }

                Circle()
                    .stroke(ringColor, lineWidth: 1)
                    .frame(width: size - 2, height: size - 2)
                    .position(x: cx, y: cy)

                WheelCenterCap(size: size * 0.40, isSpinning: isSpinning, onTap: onSpin)
                    .position(x: cx, y: cy)
            }
        }
    }
}
