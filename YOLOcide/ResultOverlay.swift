//
//  ResultOverlay.swift
//  YOLOcide
//

import SwiftUI

struct ResultOverlay: View {
    let result: WheelOption
    let onDismiss: () -> Void

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack {
            // Backdrop: blur + dark tint
            Rectangle()
                .fill(scheme == .dark
                    ? Color.black.opacity(0.45)
                    : Color.black.opacity(0.25))
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            // Card
            VStack(spacing: 0) {
                Text("Fate has spoken")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(.tertiaryLabel))
                    .kerning(0.96)
                    .textCase(.uppercase)
                    .padding(.bottom, 16)

                Circle()
                    .fill(result.color)
                    .frame(width: 52, height: 52)
                    .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 2))
                    .shadow(color: result.color.opacity(0.4), radius: 12, y: 6)
                    .padding(.bottom, 16)

                Text(result.name)
                    .font(.system(size: 32, weight: .black))
                    .tracking(-0.96)
                    .foregroundStyle(Color(.label))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 24)

                PrimaryButton(label: "Sounds good", disabled: false, action: onDismiss)
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)
            .padding(.bottom, 28)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(scheme == .dark ? Color(hex: "#454856") : Color.white)
            )
            .shadow(color: Color(hex: "#3c288c").opacity(0.25), radius: 30, y: 14)
            .padding(.horizontal, 24)
        }
        .transition(.opacity)
    }
}
