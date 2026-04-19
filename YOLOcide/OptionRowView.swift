//
//  OptionRowView.swift
//  YOLOcide
//

import SwiftUI

struct OptionRowView: View {
    let option: WheelOption
    @Binding var openPickerID: UUID?
    let onColorChange: (Color) -> Void
    let onNameChange: (String) -> Void
    let onDelete: () -> Void

    @State private var isEditing = false
    @State private var editText = ""
    @State private var customColor: Color = .white
    @FocusState private var fieldFocused: Bool
    @Environment(\.colorScheme) private var scheme

    private var pickerOpen: Bool { openPickerID == option.id }

    var body: some View {
        VStack(spacing: 4) {
            rowPill
            if pickerOpen {
                HStack {
                    Spacer()
                    colorPickerPopover
                }
                .transition(.scale(scale: 0.85, anchor: .topTrailing).combined(with: .opacity))
            }
        }
        .onAppear { customColor = option.color }
        .onChange(of: option.color) { customColor = $0 }
    }

    // MARK: - Row pill

    private var rowPill: some View {
        HStack(spacing: 10) {
            if isEditing {
                TextField("Option name", text: $editText)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color(.label))
                    .focused($fieldFocused)
                    .onSubmit { commitEdit() }
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button { commitEdit() } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.ycPurple)
                }
                .buttonStyle(.plain)
            } else {
                Text(option.name)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color(.label))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Edit button
                Button {
                    if pickerOpen {
                        withAnimation(.spring(response: 0.26, dampingFraction: 0.72)) {
                            openPickerID = nil
                        }
                    }
                    editText = option.name
                    isEditing = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { fieldFocused = true }
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(.secondaryLabel))
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)

                // Color dot
                Button {
                    withAnimation(.spring(response: 0.26, dampingFraction: 0.72)) {
                        openPickerID = pickerOpen ? nil : option.id
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
    }

    // MARK: - Color picker popup

    private var colorPickerPopover: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 5-column swatch grid
            let columns = Array(repeating: GridItem(.fixed(26), spacing: 6), count: 5)
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(Array(Color.wheelPastels.enumerated()), id: \.offset) { _, c in
                    swatchButton(c)
                }
            }

            Divider()

            HStack(spacing: 8) {
                ColorPicker("Custom", selection: Binding(
                    get: { customColor },
                    set: { customColor = $0; onColorChange($0) }
                ), supportsOpacity: false)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color(.label))

                Spacer()

                Divider().frame(height: 20)

                Button {
                    withAnimation(.spring(response: 0.26, dampingFraction: 0.72)) {
                        openPickerID = nil
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { onDelete() }
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(.label))
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.plain)
            }
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

    private func swatchButton(_ c: Color) -> some View {
        let isSelected = UIColor(c) == UIColor(option.color)
        return Button {
            onColorChange(c)
            withAnimation(.spring(response: 0.26, dampingFraction: 0.72)) {
                openPickerID = nil
            }
        } label: {
            Circle()
                .fill(c)
                .frame(width: 26, height: 26)
                .overlay(
                    Circle()
                        .stroke(Color.ycPurple, lineWidth: 2)
                        .opacity(isSelected ? 1 : 0)
                        .padding(-2)
                )
                .overlay(
                    Circle().stroke(
                        isSelected ? Color.white : Color.black.opacity(0.08),
                        lineWidth: 1.5
                    )
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func commitEdit() {
        let trimmed = editText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { onNameChange(trimmed) }
        withAnimation(.spring(response: 0.26, dampingFraction: 0.72)) { isEditing = false }
        fieldFocused = false
    }
}
