//
//  ContentView.swift
//  YOLOcide
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var historyStore: HistoryStore
    @EnvironmentObject private var settings: SettingsStore

    @State private var options: [WheelOption] = {
        guard let data = UserDefaults.standard.data(forKey: "yolocide_options_v1"),
              let stored = try? JSONDecoder().decode([SessionOption].self, from: data),
              !stored.isEmpty
        else { return WheelOption.defaults }
        return stored.map { WheelOption(name: $0.name, color: Color(hex: $0.colorHex)) }
    }()
    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var result: WheelOption? = nil
    @State private var listOpen = false
    @State private var showAddSheet = false
    @State private var openPickerID: UUID? = nil
    @State private var rankAllMode = false
    @State private var winners: [WheelOption] = []
    @State private var showWinnersSheet = false
    @State private var showHistory = false
    @State private var showHelp = false
    @State private var rankSessionBaseOptions: [WheelOption] = []
    @State private var lastSpinOptions: [WheelOption] = []

    @Environment(\.colorScheme) private var scheme

    private let baseWheelSize: CGFloat = 270
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
            // Bottom panel: rank toggle + optional "view rankings" + CTA
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if !listOpen {
                    bottomPanel
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }

            // ── Overlays ──
            if let winner = result {
                ResultOverlay(
                    result: winner,
                    rankPosition: rankAllMode ? winners.count + 1 : nil,
                    buttonLabel: rankAllMode
                        ? (options.count <= 2 ? settings.t("result.seerankings") : settings.t("result.next"))
                        : settings.t("result.dismiss")
                ) {
                    dismissResult()
                }
                .zIndex(10)
                .transition(.opacity)
            }

            if showWinnersSheet {
                WinnersSheet(
                    winners: winners,
                    onClose: {
                        withAnimation(.spring(response: 0.34, dampingFraction: 0.8)) {
                            showWinnersSheet = false
                        }
                    },
                    onClear: clearRankResults
                )
                .zIndex(15)
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
        .fullScreenCover(isPresented: $showHistory) {
            HistoryView()
                .environmentObject(historyStore)
                .environmentObject(settings)
        }
        .fullScreenCover(isPresented: $showHelp) {
            HelpView()
                .environmentObject(settings)
        }
        .onChange(of: options) { _, newOptions in
            let stored = newOptions.map { $0.asSessionOption }
            if let data = try? JSONEncoder().encode(stored) {
                UserDefaults.standard.set(data, forKey: "yolocide_options_v1")
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

            // History button
            Button { showHistory = true } label: {
                headerIcon("clock.arrow.circlepath", size: 18)
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.trailing, 6)

            // Help button
            Button { showHelp = true } label: {
                headerIcon("questionmark", size: 17)
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.trailing, 8)

            // Glass "+" button
            Button {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.8)) {
                    showAddSheet = true
                }
            } label: {
                headerIcon("plus", size: 20)
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }

    private func headerIcon(_ name: String, size: CGFloat) -> some View {
        Image(systemName: name)
            .font(.system(size: size, weight: .medium))
            .foregroundStyle(Color(.label))
            .frame(width: 44, height: 44)
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

    // MARK: - Wheel stage (pointer + wheel)

    private var wheelStage: some View {
        ZStack(alignment: .top) {
            WheelView(
                options: options,
                rotation: rotation,
                isSpinning: isSpinning,
                onSpin: spin
            )
            .frame(width: baseWheelSize, height: baseWheelSize)
            .scaleEffect(wheelSize / baseWheelSize)
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
                Text(settings.t(listOpen ? "options.hide" : "options.show"))
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
                    Text(settings.t("options.empty"))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color(.tertiaryLabel))
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 40)
                } else {
                    ForEach(options) { opt in
                        OptionRowView(
                            option: opt,
                            openPickerID: $openPickerID,
                            onColorChange: { newColor in
                                guard let idx = options.firstIndex(of: opt) else { return }
                                withAnimation(.spring(response: 0.26, dampingFraction: 0.72)) {
                                    options[idx].color = newColor
                                }
                            },
                            onNameChange: { newName in
                                guard let idx = options.firstIndex(of: opt) else { return }
                                options[idx].name = newName
                            },
                            onDelete: {
                                withAnimation(.spring(response: 0.34, dampingFraction: 0.8)) {
                                    options.removeAll { $0.id == opt.id }
                                }
                                openPickerID = nil
                                result = nil
                            }
                        )
                        .zIndex(openPickerID == opt.id ? 1 : 0)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 6)
            .padding(.bottom, 24)
            .contentShape(Rectangle())
            .onTapGesture {
                if openPickerID != nil {
                    withAnimation(.spring(response: 0.26, dampingFraction: 0.72)) {
                        openPickerID = nil
                    }
                }
            }
        }
    }

    // MARK: - Bottom panel (rank toggle + CTA)

    private var bottomPanel: some View {
        VStack(spacing: 0) {
            rankAllToggle

            if rankAllMode && !winners.isEmpty {
                HStack(spacing: 10) {
                    Button {
                        withAnimation(.spring(response: 0.42, dampingFraction: 0.7)) {
                            showWinnersSheet = true
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "list.number")
                                .font(.system(size: 12, weight: .bold))
                            Text(String(format: settings.t("rank.view"), winners.count))
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(Color.ycPurple)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(
                            Capsule()
                                .fill(Color.ycPurple.opacity(0.12))
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())

                    Button {
                        withAnimation(.spring(response: 0.34, dampingFraction: 0.8)) {
                            clearRankResults()
                        }
                    } label: {
                        Text(settings.t("rank.clear"))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color(.secondaryLabel))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(
                                Capsule()
                                    .fill(Color(.secondaryLabel).opacity(0.10))
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(.bottom, 8)
            }

            PrimaryButton(
                label: settings.t(isSpinning ? "spin.inprogress" : "spin.cta"),
                disabled: options.count < 2 || isSpinning
            ) {
                spin()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 34)
        }
        .background(Color.ycBg.shadow(.inner(color: .clear, radius: 0)))
        .animation(.spring(response: 0.42, dampingFraction: 0.7), value: listOpen)
        .animation(.spring(response: 0.34, dampingFraction: 0.8), value: rankAllMode)
        .animation(.spring(response: 0.34, dampingFraction: 0.8), value: winners.count)
    }

    private var rankAllToggle: some View {
        HStack(spacing: 8) {
            Image(systemName: "list.number")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.ycPurple)
            Text(settings.t("rank.toggle"))
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color(.label))
            Spacer()
            Toggle("", isOn: $rankAllMode)
                .labelsHidden()
                .tint(Color.ycPurple)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .onChange(of: rankAllMode) { _, newValue in
            if !newValue { savePartialRankSession() }
            winners = []
            rankSessionBaseOptions = []
        }
    }

    // MARK: - Spin logic

    private func spin() {
        guard !isSpinning, options.count >= 2 else { return }
        isSpinning = true
        result = nil

        // Snapshot for session recording
        lastSpinOptions = options
        if rankAllMode && winners.isEmpty {
            rankSessionBaseOptions = options
        }

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

    // MARK: - Dismiss result (handles rank mode removal)

    private func dismissResult() {
        guard let winner = result else { return }
        if rankAllMode {
            winners.append(winner)
            withAnimation(.spring(response: 0.34, dampingFraction: 0.8)) {
                options.removeAll { $0.id == winner.id }
            }
            // If only 1 option remains, auto-rank it
            if options.count == 1 {
                winners.append(options[0])
                withAnimation(.spring(response: 0.34, dampingFraction: 0.8)) {
                    options.removeAll()
                }
            }
            withAnimation(.easeOut(duration: 0.22)) { result = nil }
            // When all options are ranked: record session and show winners sheet
            if options.count < 2 {
                let allWinners = winners
                let baseOptions = rankSessionBaseOptions
                historyStore.add(SpinSession(
                    timestamp: Date(),
                    winners: allWinners.map { $0.asSessionOption },
                    wheelOptions: baseOptions.map { $0.asSessionOption },
                    isRankSession: true
                ))
                rankSessionBaseOptions = []
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.7)) {
                        showWinnersSheet = true
                    }
                }
            }
        } else {
            // Record normal (single-winner) session
            historyStore.add(SpinSession(
                timestamp: Date(),
                winners: [winner.asSessionOption],
                wheelOptions: lastSpinOptions.map { $0.asSessionOption },
                isRankSession: false
            ))
            withAnimation(.easeOut(duration: 0.22)) { result = nil }
        }
    }

    // MARK: - Clear rank results (returns ranked options back to the wheel)

    private func clearRankResults() {
        // Only save as partial if the ranking wasn't complete (complete sessions are
        // already saved in dismissResult when the last option is ranked).
        if !options.isEmpty { savePartialRankSession() }
        result = nil
        options = winners + options
        winners = []
        rankSessionBaseOptions = []
    }

    // MARK: - Save partial rank session

    private func savePartialRankSession() {
        guard !winners.isEmpty, !rankSessionBaseOptions.isEmpty else { return }
        historyStore.add(SpinSession(
            timestamp: Date(),
            winners: winners.map { $0.asSessionOption },
            wheelOptions: rankSessionBaseOptions.map { $0.asSessionOption },
            isRankSession: true
        ))
    }

    // MARK: - Add option

    private func addOption(name: String) {
        // Adding an item while mid-ranking finishes the current partial session.
        if rankAllMode && !winners.isEmpty {
            savePartialRankSession()
            winners = []
            rankSessionBaseOptions = []
        }
        let nextColor = Color.wheelPastels[options.count % Color.wheelPastels.count]
        withAnimation(.spring(response: 0.34, dampingFraction: 0.8)) {
            options.append(WheelOption(name: name, color: nextColor))
        }
        result = nil
    }
}

#Preview {
    ContentView()
        .environmentObject(HistoryStore())
        .environmentObject(SettingsStore())
}
