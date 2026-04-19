import SwiftUI
import Combine

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

// MARK: - Keyboard Height Observer
private class KeyboardHeightHelper: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            withAnimation {
                self.keyboardHeight = keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        withAnimation {
            self.keyboardHeight = 0
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

struct AddOptionSheet: View {
    let onAdd: (String) -> Void
    let onClose: () -> Void

    @EnvironmentObject private var settings: SettingsStore
    @State private var text = ""
    @FocusState private var focused: Bool
    @Environment(\.colorScheme) private var scheme
    @State private var dragOffset: CGFloat = 0
    @StateObject private var keyboardHelper = KeyboardHeightHelper()

    private var trimmed: String { text.trimmingCharacters(in: .whitespaces) }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Backdrop - appears instantly
            Color.black.opacity(0.35)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)
                .transition(.opacity)

            // Sheet card with drag gesture
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
                    .contentShape(Rectangle())

                Text(settings.t("add.title"))
                    .font(.system(size: 22, weight: .bold))
                    .tracking(-0.44)
                    .foregroundStyle(Color(.label))
                    .padding(.bottom, 14)

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
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                SheetShape(radius: 28)
                    .fill(scheme == .dark ? Color(hex: "#454856") : Color.white)
            )
            .offset(y: dragOffset)
            .offset(y: -max(0, keyboardHelper.keyboardHeight - 34))
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.height > 0 {
                            dragOffset = gesture.translation.height
                        }
                    }
                    .onEnded { gesture in
                        if gesture.translation.height > 100 || gesture.predictedEndLocation.y > gesture.startLocation.y + 100 {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                onClose()
                            }
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                dragOffset = 0
                            }
                        }
                    }
            )
            .transition(.move(edge: .bottom))
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear { focused = true }
    }

    private func submit() {
        guard !trimmed.isEmpty else { return }
        onAdd(trimmed)
    }
}
