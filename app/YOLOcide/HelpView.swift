import SwiftUI

struct HelpView: View {
    @EnvironmentObject private var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack {
            Color.ycBg.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        helpCard(
                            icon: "info.circle.fill",
                            title: settings.t("help.section.howto"),
                            body: settings.t("help.howto.body")
                        )
                        helpCard(
                            icon: "list.number",
                            title: settings.t("help.section.rankmode"),
                            body: settings.t("help.rankmode.body")
                        )
                        helpCard(
                            icon: "slider.horizontal.3",
                            title: settings.t("help.section.options"),
                            body: settings.t("help.options.body")
                        )
                        helpCard(
                            icon: "icloud.and.arrow.up",
                            title: settings.t("help.section.signin"),
                            body: settings.t("help.signin.body")
                        )
                        settingsCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(.label))
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(scheme == .dark
                                ? Color.white.opacity(0.10)
                                : Color.white.opacity(0.72))
                            .overlay(Circle().stroke(
                                scheme == .dark
                                    ? Color.white.opacity(0.12)
                                    : Color.black.opacity(0.05),
                                lineWidth: 1))
                    )
                    .shadow(color: Color(hex: "#1e1846").opacity(0.06), radius: 6, y: 2)
            }
            .buttonStyle(ScaleButtonStyle())

            Spacer()

            Text(settings.t("help.title"))
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color(.label))

            Spacer()

            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }

    // MARK: - Instruction card

    private func helpCard(icon: String, title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.ycPurple)
                    .frame(width: 38, height: 38)
                    .background(RoundedRectangle(cornerRadius: 11).fill(Color.ycPurple.opacity(0.12)))
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(.label))
            }
            Text(body)
                .font(.system(size: 14))
                .foregroundStyle(Color(.secondaryLabel))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
    }

    // MARK: - Settings card

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.ycPurple)
                    .frame(width: 38, height: 38)
                    .background(RoundedRectangle(cornerRadius: 11).fill(Color.ycPurple.opacity(0.12)))
                Text(settings.t("help.section.settings"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(.label))
            }
            .padding(.bottom, 20)

            // Language row
            HStack {
                Text(settings.t("help.settings.language"))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color(.label))
                Spacer()
                languagePicker
            }

            Rectangle()
                .fill(Color(.separator).opacity(0.6))
                .frame(height: 0.5)
                .padding(.vertical, 16)

            // Appearance row
            HStack {
                Text(settings.t("help.settings.appearance"))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color(.label))
                Spacer()
                appearancePicker
            }

            Rectangle()
                .fill(Color(.separator).opacity(0.6))
                .frame(height: 0.5)
                .padding(.vertical, 16)

            // Haptics row
            Toggle(isOn: $settings.hapticsEnabled) {
                Text(settings.t("help.settings.haptics"))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color(.label))
            }
            .tint(Color.ycPurple)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
    }

    // MARK: - Language picker

    private var languagePicker: some View {
        Picker("", selection: $settings.language) {
            ForEach(AppLanguage.allCases, id: \.self) { lang in
                Text(lang.displayName).tag(lang)
            }
        }
        .pickerStyle(.menu)
        .tint(Color.ycPurple)
    }

    // MARK: - Appearance picker

    private var appearancePicker: some View {
        HStack(spacing: 2) {
            ForEach(AppAppearance.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.spring(response: 0.26, dampingFraction: 0.72)) {
                        settings.appearance = mode
                    }
                } label: {
                    Text(settings.t(mode.labelKey))
                        .font(.system(size: 13,
                                      weight: settings.appearance == mode ? .semibold : .regular))
                        .foregroundStyle(settings.appearance == mode ? .white : Color(.secondaryLabel))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(settings.appearance == mode
                                ? Color.ycPurple
                                : Color.clear)
                        )
                }
                .buttonStyle(ScaleButtonStyle())
                .animation(.spring(response: 0.26, dampingFraction: 0.72), value: settings.appearance)
            }
        }
        .padding(3)
        .background(
            Capsule().fill(scheme == .dark
                ? Color.white.opacity(0.10)
                : Color.black.opacity(0.07))
        )
    }

    // MARK: - Shared card background

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(scheme == .dark ? Color(hex: "#454856") : Color.white)
            .shadow(color: Color(hex: "#3c288c").opacity(scheme == .dark ? 0.12 : 0.06),
                    radius: 14, y: 4)
    }
}
