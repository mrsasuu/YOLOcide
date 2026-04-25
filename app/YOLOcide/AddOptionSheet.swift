import SwiftUI

struct AddOptionSheet: View {
    let onAdd: (String) -> Void
    let onClose: () -> Void

    @EnvironmentObject private var settings: SettingsStore
    @State private var text = ""
    @FocusState private var focused: Bool
    @Environment(\.colorScheme) private var scheme

    private var trimmed: String { text.trimmingCharacters(in: .whitespaces) }

    var body: some View {
        ActionSheetContainer(onClose: onClose) {
            VStack(alignment: .leading, spacing: 0) {
                Text(settings.t("add.title"))
                    .font(.system(size: 22, weight: .bold))
                    .tracking(-0.44)
                    .foregroundStyle(Color(.label))
                    .padding(.bottom, 14)
                    .padding(.top, 16)

                // Input field
                TextField(settings.t("add.placeholder"), text: $text)
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

                PrimaryButton(label: settings.t("add.button"), disabled: trimmed.isEmpty, action: submit)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 34)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
        }
        .onAppear { focused = true }
    }

    private func submit() {
        guard !trimmed.isEmpty else { return }
        onAdd(trimmed)
    }
}
