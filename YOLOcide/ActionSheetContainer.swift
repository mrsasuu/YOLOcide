import SwiftUI
import Combine

// MARK: - Sheet Background Shape
struct SheetShape: Shape {
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
class KeyboardHeightHelper: ObservableObject {
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

// MARK: - Reusable Action Sheet Container
struct ActionSheetContainer<Content: View>: View {
    let onClose: () -> Void
    let content: () -> Content
    
    @StateObject private var keyboardHelper = KeyboardHeightHelper()
    @State private var dragOffset: CGFloat = 0
    @Environment(\.colorScheme) private var scheme
    
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
                    .contentShape(Rectangle())
                
                content()
            }
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
    }
}
