//
//  WinnersSheet.swift
//  YOLOcide
//

import SwiftUI

private struct SheetShape: Shape {
    let radius: CGFloat
    func path(in rect: CGRect) -> Path {
        let r = radius
        var p = Path()
        p.move(to: CGPoint(x: 0, y: rect.height + r))
        p.addLine(to: CGPoint(x: 0, y: r))
        p.addArc(center: CGPoint(x: r, y: r), radius: r,
                 startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        p.addLine(to: CGPoint(x: rect.width - r, y: 0))
        p.addArc(center: CGPoint(x: rect.width - r, y: r), radius: r,
                 startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)
        p.addLine(to: CGPoint(x: rect.width, y: rect.height + r))
        p.closeSubpath()
        return p
    }
}

struct WinnersSheet: View {
    let winners: [WheelOption]
    let onClose: () -> Void
    let onClear: () -> Void

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack(alignment: .bottom) {
            // Backdrop
            Color.black.opacity(0.35)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)

            // Sheet card
            VStack(alignment: .leading, spacing: 0) {
                // Drag handle
                Capsule()
                    .fill(scheme == .dark
                        ? Color.white.opacity(0.20)
                        : Color.black.opacity(0.15))
                    .frame(width: 36, height: 5)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 14)
                    .padding(.bottom, 20)

                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Rankings")
                            .font(.system(size: 22, weight: .black))
                            .tracking(-0.6)
                            .foregroundStyle(Color(.label))
                        Text("In the order fate decided.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color(.tertiaryLabel))
                    }
                    Spacer()
                    Button {
                        onClear()
                        onClose()
                    } label: {
                        Text("Start over")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color(.secondaryLabel))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(
                                Capsule()
                                    .fill(Color(.secondaryLabel).opacity(0.10))
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(Array(winners.enumerated()), id: \.element.id) { index, winner in
                            WinnerRow(position: index + 1, winner: winner)
                        }
                    }
                    .padding(.bottom, 8)
                }
                .frame(maxHeight: 360)

                PrimaryButton(label: "Done", disabled: false, action: onClose)
                    .padding(.top, 16)
                    .padding(.bottom, 34)
            }
            .padding(.horizontal, 20)
            .background(
                SheetShape(radius: 28)
                    .fill(scheme == .dark ? Color(hex: "#454856") : Color.white)
                    .ignoresSafeArea(edges: .bottom)
            )
            .shadow(color: Color(hex: "#3c288c").opacity(0.20), radius: 30, y: -10)
        }
        .ignoresSafeArea()
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

private struct WinnerRow: View {
    let position: Int
    let winner: WheelOption

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack(spacing: 14) {
            Text("#\(position)")
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(position == 1 ? Color.ycPurple : Color(.secondaryLabel))
                .frame(width: 32, alignment: .center)

            Circle()
                .fill(winner.color)
                .frame(width: 32, height: 32)
                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1.5))
                .shadow(color: winner.color.opacity(0.35), radius: 6, y: 3)

            Text(winner.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(.label))
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(scheme == .dark
                    ? Color.white.opacity(0.06)
                    : Color.ycBg)
        )
    }
}
