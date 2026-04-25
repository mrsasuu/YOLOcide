import SwiftUI

// MARK: - Circular segment shape
//
// Colored area = region between the outer arc and the polygon chord.
// When n is large the polygon vertex radius (polyR) shrinks inward so the
// arc band is always at least minArcFraction × outerRadius tall.

private struct WheelSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let outerRadius: CGFloat
    let innerRadius: CGFloat   // polygon vertex radius (≤ outerRadius)

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let s = startAngle.radians
        let e = endAngle.radians
        var p = Path()
        p.move(to: CGPoint(x: center.x + outerRadius * CGFloat(cos(s)),
                           y: center.y + outerRadius * CGFloat(sin(s))))
        p.addArc(center: center, radius: outerRadius,
                 startAngle: startAngle, endAngle: endAngle, clockwise: false)
        // Draw inward to the inner (polygon) vertex, then chord back to start
        p.addLine(to: CGPoint(x: center.x + innerRadius * CGFloat(cos(e)),
                              y: center.y + innerRadius * CGFloat(sin(e))))
        p.addLine(to: CGPoint(x: center.x + innerRadius * CGFloat(cos(s)),
                              y: center.y + innerRadius * CGFloat(sin(s))))
        p.closeSubpath()
        return p
    }
}

// MARK: - Rotating disc (arc segments + labels, no dividers)

private struct WheelDisc: View {
    let options: [WheelOption]
    let size: CGFloat
    @Environment(\.colorScheme) private var scheme

    // Minimum arc-band height as a fraction of the outer radius.
    // Below this threshold the polygon vertex radius shrinks inward.
    private static let minArcFraction: Double = 0.25

    private var n: Int { options.count }
    private var sa: Double { 360.0 / Double(max(n, 1)) }
    private var r: CGFloat { (size - 2) / 2 }
    private var cx: CGFloat { size / 2 }
    private var cy: CGFloat { size / 2 }

    /// Polygon vertex radius that keeps the arc band ≥ minArcFraction × r.
    /// Formula: polyR × cos(π/n) ≤ r × (1 − minArcFraction)
    ///       → polyR ≤ r × (1 − minArcFraction) / cos(π/n)
    /// Clamped to r so it never exceeds the outer circle.
    private var polyR: CGFloat {
        guard n > 1 else { return r }
        let cosVal = cos(.pi / Double(n))
        guard cosVal > 0 else { return r }
        return CGFloat(min(1.0, (1.0 - Self.minArcFraction) / cosVal)) * r
    }

    var body: some View {
        ZStack {
            slicesLayer
            labelsLayer
        }
        .frame(width: size, height: size)
        .drawingGroup()
    }

    @ViewBuilder
    private var slicesLayer: some View {
        let opacity: Double = scheme == .dark ? 0.70 : 1.0
        let pR = polyR
        ForEach(options.indices, id: \.self) { i in
            let start = Double(i) * sa - 90
            WheelSlice(
                startAngle: .degrees(start),
                endAngle: .degrees(start + sa),
                outerRadius: r,
                innerRadius: pR
            )
            .fill(options[i].color.opacity(opacity))
        }
    }

    @ViewBuilder
    private var labelsLayer: some View {
        let labelColor: Color = scheme == .dark
            ? Color.white.opacity(0.85)
            : Color(red: 0.11, green: 0.11, blue: 0.11).opacity(0.80)
        let pR = polyR
        let apothem: CGFloat = n > 1 ? pR * CGFloat(cos(.pi / Double(n))) : 0
        let labelR: CGFloat = n > 1 ? (apothem + r) / 2 : r * 0.67
        let chordLen: CGFloat = n > 1 ? 2 * pR * CGFloat(sin(.pi / Double(n))) : r * 1.6
        let fontSize: CGFloat = n == 1
            ? max(10, min(16, size * 0.06))
            : max(9, min(13, size * 0.042))
        ForEach(options.indices, id: \.self) { i in
            let midDeg = Double(i) * sa + sa / 2 - 90
            let midRad = midDeg * .pi / 180
            Text(options[i].name)
                .font(.system(size: fontSize, weight: .medium))
                .foregroundStyle(labelColor)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(width: chordLen * 0.85)
                // For n=1 the segment spans the full circle — render the label
                // horizontally at mid-ring so it doesn't land upside-down at the edge.
                .rotationEffect(.degrees(n == 1 ? 0 : midDeg + 90))
                .position(x: cx + labelR * CGFloat(cos(midRad)),
                          y: cy + labelR * CGFloat(sin(midRad)))
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
                        .shadow(color: isSpinning ? .clear : shadowColor,
                                radius: isSpinning ? 0 : 32,
                                x: 0,
                                y: isSpinning ? 0 : 22)
                        .position(x: cx, y: cy)
                }

WheelCenterCap(size: size * 0.40, isSpinning: isSpinning, onTap: onSpin)
                    .position(x: cx, y: cy)
            }
        }
    }
}
