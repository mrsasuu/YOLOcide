//
//  ContentView.swift
//  YOLOcide
//

import SwiftUI

struct ContentView: View {
    @State private var options: [WheelOption] = WheelOption.defaults
    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var result: WheelOption? = nil
    @State private var listOpen = false
    @State private var showAddSheet = false

    @Environment(\.colorScheme) private var scheme

    // Wheel shrinks from 270 → 170 when list opens
    private var wheelSize: CGFloat { listOpen ? 170 : 270 }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.ycBg.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                wheelStage
                    .padding(.top, listOpen ? 8 : 20)
                    .animation(.spring(response: 0.42, dampingFraction: 0.7), value: listOpen)

                toggleButton
                    .padding(.top, 10)

                // List or spacer
                if listOpen {
                    optionsList
                        .transition(
                            .move(edge: .bottom)
                            .combined(with: .opacity)
                        )
                } else {
                    Spacer(minLength: 0)
                }
            }
            .animation(.spring(response: 0.42, dampingFraction: 0.7), value: listOpen)
            // "Spin my fate" CTA docked at the bottom
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if !listOpen {
                    spinCtaButton
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }

            // ── Overlays ──
            if let winner = result {
                ResultOverlay(result: winner) {
                    withAnimation(.easeOut(duration: 0.22)) { result = nil }
                }
                .zIndex(10)
                .transition(.opacity)
            }

            if showAddSheet {
                AddOptionSheet(
                    onAdd: { name in
                        addOption(name: name)
                        withAnimation(.spring(response: 0.34, dampingFraction: 0.8)) {
                            showAddSheet = false
                        }
                    },
                    onClose: {
                        withAnimation(.spring(response: 0.34, dampingFraction: 0.8)) {
                            showAddSheet = false
                        }
                    }
                )
                .zIndex(20)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center) {
            // Brand wordmark: "YOLO" black + "cide" purple
            (Text("YOLO").foregroundStyle(Color(.label)) +
             Text("cide").foregroundStyle(Color.ycPurple))
                .font(.system(size: 34, weight: .black))
                .tracking(-1.2)

            Spacer()

            // Glass "+" button
            Button {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.8)) {
                    showAddSheet = true
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color(.label))
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(scheme == .dark
                                ? Color.white.opacity(0.10)
                                : Color.white.opacity(0.72))
                            .overlay(
                                Circle().stroke(
                                    scheme == .dark
                                        ? Color.white.opacity(0.12)
                                        : Color.black.opacity(0.05),
                                    lineWidth: 1
                                )
                            )
                    )
                    .shadow(color: Color(hex: "#1e1846").opacity(0.06), radius: 6, y: 2)
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }

    // MARK: - Wheel stage (pointer + wheel)

    private var wheelStage: some View {
        ZStack(alignment: .top) {
            WheelView(
                options: options,
                rotation: rotation,
                isSpinning: isSpinning,
                onSpin: spin
            )
            .frame(width: wheelSize, height: wheelSize)
            .padding(.top, 12)
            .animation(.spring(response: 0.42, dampingFraction: 0.7), value: wheelSize)

            // Fixed indicator arrow
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(scheme == .dark ? Color.white.opacity(0.9) : Color(hex: "#1c1c1e"))
        }
    }

    // MARK: - Show / Hide options toggle

    private var toggleButton: some View {
        Button {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.7)) {
                listOpen.toggle()
            }
        } label: {
            HStack(spacing: 6) {
                Text(listOpen ? "Hide options" : "Show options")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color(.secondaryLabel))

                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(.secondaryLabel))
                    .rotationEffect(.degrees(listOpen ? 180 : 0))
                    .animation(.spring(response: 0.26, dampingFraction: 0.72), value: listOpen)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Options list

    private var optionsList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                if options.isEmpty {
                    Text("Nothing to decide yet. Add an option.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color(.tertiaryLabel))
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 40)
                } else {
                    ForEach(options) { opt in
                        OptionRowView(
                            option: opt,
                            onColorChange: { newColor in
                                guard let idx = options.firstIndex(of: opt) else { return }
                                withAnimation(.spring(response: 0.26, dampingFraction: 0.72)) {
                                    options[idx].color = newColor
                                }
                            },
                            onDelete: {
                                withAnimation(.spring(response: 0.34, dampingFraction: 0.8)) {
                                    options.removeAll { $0.id == opt.id }
                                }
                                result = nil
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 6)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Spin my fate CTA

    private var spinCtaButton: some View {
        PrimaryButton(
            label: isSpinning ? "Spinning…" : "Spin my fate",
            disabled: options.count < 2 || isSpinning
        ) {
            spin()
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 34)
        .background(
            Color.ycBg
                .shadow(.inner(color: .clear, radius: 0))
        )
        .animation(.spring(response: 0.42, dampingFraction: 0.7), value: listOpen)
    }

    // MARK: - Spin logic

    private func spin() {
        guard !isSpinning, options.count >= 2 else { return }
        isSpinning = true
        result = nil

        let n = options.count
        let segAngle = 360.0 / Double(n)
        let winnerIdx = Int.random(in: 0..<n)

        // Mid-angle of winning segment in wheel coords (clockwise from top)
        let winnerMid = (Double(winnerIdx) + 0.5) * segAngle

        // After rotation R, the fixed top indicator points to (360 - R%360) % 360 in wheel space.
        // Solve for R: (360 - R%360) % 360 == winnerMid  →  R%360 == (360 - winnerMid + 360) % 360
        let targetMod = (360.0 - winnerMid + 360.0).truncatingRemainder(dividingBy: 360.0)
        let currentMod = rotation.truncatingRemainder(dividingBy: 360.0)
        var delta = targetMod - currentMod
        if delta < 0 { delta += 360.0 }

        // 6 full rotations + delta → lands exactly on winner
        let newRotation = rotation + 6 * 360.0 + delta

        // cubic-bezier(0.16, 1, 0.3, 1) ≈ SwiftUI timingCurve
        withAnimation(.timingCurve(0.16, 1, 0.3, 1, duration: 3.6)) {
            rotation = newRotation
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.7) {
            isSpinning = false
            withAnimation(.spring(response: 0.42, dampingFraction: 0.6)) {
                result = options[winnerIdx]
            }
        }
    }

    // MARK: - Add option

    private func addOption(name: String) {
        let nextColor = Color.wheelPastels[options.count % Color.wheelPastels.count]
        withAnimation(.spring(response: 0.34, dampingFraction: 0.8)) {
            options.append(WheelOption(name: name, color: nextColor))
        }
        result = nil
    }
}

#Preview {
    ContentView()
}
