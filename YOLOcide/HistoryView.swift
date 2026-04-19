//
//  HistoryView.swift
//  YOLOcide
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var historyStore: HistoryStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme

    @State private var showClearConfirm = false

    var body: some View {
        ZStack {
            Color.ycBg.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                if historyStore.sessions.isEmpty {
                    emptyState
                } else {
                    sessionList
                }
            }
        }
        .confirmationDialog("Clear all history?", isPresented: $showClearConfirm, titleVisibility: .visible) {
            Button("Clear all", role: .destructive) { historyStore.clearAll() }
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

            Text("History")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color(.label))

            Spacer()

            if historyStore.sessions.isEmpty {
                Color.clear.frame(width: 36, height: 36)
            } else {
                Button { showClearConfirm = true } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color(.secondaryLabel))
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
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }

    // MARK: - Session list

    private var sessionList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(historyStore.sessions) { session in
                    SessionCard(session: session)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(Color(.tertiaryLabel))
            Text("No sessions yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(.secondaryLabel))
            Text("Spin the wheel to start building your history.")
                .font(.system(size: 14))
                .foregroundStyle(Color(.tertiaryLabel))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }
}

// MARK: - Session card

private struct SessionCard: View {
    let session: SpinSession

    @State private var expanded = false
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            timestampRow
                .padding(.bottom, 14)

            if session.isRankSession {
                rankedWinners
            } else if let winner = session.winners.first {
                singleWinner(winner)
            }

            Rectangle()
                .fill(Color(.separator).opacity(0.6))
                .frame(height: 0.5)
                .padding(.vertical, 14)

            wheelSection
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(scheme == .dark ? Color(hex: "#454856") : Color.white)
        )
        .shadow(
            color: Color(hex: "#3c288c").opacity(scheme == .dark ? 0.12 : 0.06),
            radius: 14, y: 4
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: expanded)
    }

    // MARK: Timestamp + badge

    private var timestampRow: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(formatDate(session.timestamp))
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(.secondaryLabel))
            Spacer()
            if session.isRankSession {
                Label("Ranked", systemImage: "list.number")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.ycPurple)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.ycPurple.opacity(0.12)))
            }
        }
    }

    // MARK: Single winner

    private func singleWinner(_ w: SessionOption) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(w.color)
                .frame(width: 28, height: 28)
                .overlay(Circle().stroke(Color.white.opacity(0.55), lineWidth: 1.5))
                .shadow(color: w.color.opacity(0.4), radius: 8, y: 3)
            Text(w.name)
                .font(.system(size: 20, weight: .black))
                .tracking(-0.5)
                .foregroundStyle(Color(.label))
                .lineLimit(1)
        }
    }

    // MARK: Ranked winners list

    @ViewBuilder
    private var rankedWinners: some View {
        let shown = Array(session.winners.prefix(3))
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(shown.enumerated()), id: \.element.id) { idx, w in
                HStack(spacing: 10) {
                    Text("#\(idx + 1)")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(idx == 0 ? Color.ycPurple : Color(.tertiaryLabel))
                        .frame(width: 26, alignment: .center)
                    Circle()
                        .fill(w.color)
                        .frame(width: 20, height: 20)
                        .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
                    Text(w.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color(.label))
                        .lineLimit(1)
                }
            }
            if session.winners.count > 3 {
                Text("+\(session.winners.count - 3) more")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(.tertiaryLabel))
                    .padding(.leading, 36)
            }
        }
    }

    // MARK: Wheel section (collapsible)

    private var wheelSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Tap target: dots row + chevron
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                    expanded.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Text("Wheel")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(.tertiaryLabel))

                    HStack(spacing: -5) {
                        ForEach(Array(session.wheelOptions.prefix(10).enumerated()), id: \.element.id) { idx, opt in
                            Circle()
                                .fill(opt.color)
                                .frame(width: 18, height: 18)
                                .overlay(Circle().stroke(
                                    scheme == .dark ? Color(hex: "#454856") : Color.white,
                                    lineWidth: 1.5))
                                .zIndex(Double(10 - idx))
                        }
                    }

                    if session.wheelOptions.count > 10 {
                        Text("+\(session.wheelOptions.count - 10)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color(.tertiaryLabel))
                            .padding(.leading, 2)
                    }

                    Spacer()

                    Text("\(session.wheelOptions.count) options")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(.tertiaryLabel))

                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color(.tertiaryLabel))
                        .rotationEffect(.degrees(expanded ? 180 : 0))
                }
            }
            .buttonStyle(.plain)

            // Expanded options list
            if expanded {
                VStack(alignment: .leading, spacing: 0) {
                    Rectangle()
                        .fill(Color(.separator).opacity(0.5))
                        .frame(height: 0.5)
                        .padding(.top, 12)
                        .padding(.bottom, 10)

                    let columns = [GridItem(.flexible()), GridItem(.flexible())]
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                        ForEach(session.wheelOptions) { opt in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(opt.color)
                                    .frame(width: 12, height: 12)
                                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 0.5))
                                Text(opt.name)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(Color(.secondaryLabel))
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Date formatting

private func formatDate(_ date: Date) -> String {
    let cal = Calendar.current
    let tf = DateFormatter()
    tf.dateFormat = "h:mm a"
    let time = tf.string(from: date)
    if cal.isDateInToday(date)     { return "Today · \(time)" }
    if cal.isDateInYesterday(date) { return "Yesterday · \(time)" }
    let df = DateFormatter()
    df.dateFormat = "MMM d · h:mm a"
    return df.string(from: date)
}
