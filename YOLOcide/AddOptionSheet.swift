//
//  AddOptionSheet.swift
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

struct AddOptionSheet: View {
    let onAdd: (String) -> Void
    let onClose: () -> Void

    @State private var text = ""
    @FocusState private var focused: Bool
    @Environment(\.colorScheme) private var scheme

    private var trimmed: String { text.trimmingCharacters(in: .whitespaces) }

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
                    .padding(.bottom, 16)

                Text("Add an option")
                    .font(.system(size: 22, weight: .bold))
                    .tracking(-0.44)
                    .foregroundStyle(Color(.label))
                    .padding(.bottom, 14)

                // Input field
                TextField("e.g. Pizza", text: $text)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color(.label))
                    .tint(Color.ycPurple)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(scheme == .dark
                                ? Color.white.opacity(0.10)
                                : Color.ycBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        scheme == .dark
                                            ? Color.white.opacity(0.12)
                                            : Color.black.opacity(0.06),
                                        lineWidth: 1
                                    )
                            )
                    )
                    .focused($focused)
                    .onSubmit { submit() }
                    .submitLabel(.done)
                    .padding(.bottom, 14)

                PrimaryButton(label: "Add to wheel", disabled: trimmed.isEmpty, action: submit)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
            .background(
                SheetShape(radius: 28)
                    .fill(scheme == .dark ? Color(hex: "#454856") : Color.white)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear { focused = true }
        .transition(.move(edge: .bottom))
    }

    private func submit() {
        guard !trimmed.isEmpty else { return }
        onAdd(trimmed)
    }
}
