import SwiftUI

struct WinnersSheet: View {
    let winners: [WheelOption]
    let onClose: () -> Void
    let onClear: () -> Void

    @EnvironmentObject private var settings: SettingsStore
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ActionSheetContainer(onClose: onClose) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(settings.t("winners.title"))
                            .font(.system(size: 22, weight: .black))
                            .tracking(-0.6)
                            .foregroundStyle(Color(.label))
                        Text(settings.t("winners.subtitle"))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color(.tertiaryLabel))
                    }
                    Spacer()
                    Button {
                        onClear()
                        onClose()
                    } label: {
                        Text(settings.t("winners.startover"))
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
                .padding(.top, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(Array(winners.enumerated()), id: \.element.id) { index, winner in
                            WinnerRow(position: index + 1, winner: winner)
                        }
                    }
                    .padding(.bottom, 8)
                }
                .frame(maxHeight: 360)

                PrimaryButton(label: settings.t("winners.done"), disabled: false, action: onClose)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 34)
            }
            .padding(.horizontal, 20)
            .shadow(color: Color(hex: "#3c288c").opacity(0.20), radius: 30, y: -10)
        }
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
