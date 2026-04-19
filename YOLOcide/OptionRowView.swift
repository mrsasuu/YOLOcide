//
//  OptionRowView.swift
//  YOLOcide
//

import SwiftUI

struct OptionRowView: View {
    let option: WheelOption
    let onColorChange: (Color) -> Void
    let onDelete: () -> Void

    @State private var pickerOpen = false
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Row pill
            HStack(spacing: 0) {
                Text(option.name)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color(.label))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 12)

                // Color dot — tapping opens picker
                Button {
                    withAnimation(.spring(response: 0.26, dampingFraction: 0.72)) {
                        pickerOpen.toggle()
                    }
                } label: {
                    Circle()
                        .fill(option.color)
                        .frame(width: 22, height: 22)
                        .overlay(Circle().stroke(
                            scheme == .dark
                                ? Color.white.opacity(0.20)
                                : Color.black.opacity(0.08),
                            lineWidth: 1
                        ))
                }
                .buttonStyle(.plain)
            }
            .padding(.leading, 18)
            .padding(.trailing, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(scheme == .dark
                        ? Color.white.opacity(0.10)
                        : Color.white.opacity(0.72)
                    )
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

            // Color swatch picker (shown below the dot)
            if pickerOpen {
                colorPickerPopover
                    .offset(x: 0, y: 54)
                    .zIndex(20)
                    .transition(.scale(scale: 0.85, anchor: .topTrailing).combined(with: .opacity))
            }
        }
    }

    private var colorPickerPopover: some View {
        HStack(spacing: 8) {
            ForEach(Array(Color.wheelPastels.prefix(6).enumerated()), id: \.offset) { _, c in
                Button {
                    onColorChange(c)
                    withAnimation(.spring(response: 0.26, dampingFraction: 0.72)) {
                        pickerOpen = false
                    }
                } label: {
                    Circle()
                        .fill(c)
                        .frame(width: 26, height: 26)
                        .overlay(
                            Circle()
                                .stroke(Color.ycPurple, lineWidth: 2)
                                .opacity(UIColor(c) == UIColor(option.color) ? 1 : 0)
                                .padding(-2)
                        )
                        .overlay(
                            Circle().stroke(
                                UIColor(c) == UIColor(option.color)
                                    ? Color.white
                                    : Color.black.opacity(0.08),
                                lineWidth: 1.5
                            )
                        )
                }
                .buttonStyle(.plain)
            }

            Divider()
                .frame(height: 20)
                .padding(.horizontal, 2)

            Button(action: {
                withAnimation(.spring(response: 0.26, dampingFraction: 0.72)) {
                    pickerOpen = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    onDelete()
                }
            }) {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(.label))
                    .frame(width: 26, height: 26)
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(scheme == .dark
                    ? Color(hex: "#32343e").opacity(0.96)
                    : Color.white.opacity(0.96)
                )
                .shadow(color: Color(hex: "#1e1846").opacity(0.20), radius: 20, y: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
        )
    }
}
