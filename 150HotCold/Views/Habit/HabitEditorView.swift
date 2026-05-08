//
//  HabitEditorView.swift
//  150HotCold
//

import SwiftUI

/// Add (`editing` == nil) or edit existing habit.
struct HabitEditorView: View {
    @ObservedObject var viewModel: HotColdViewModel
    @Environment(\.dismiss) private var dismiss

    private let editing: Habit?

    @State private var name = ""
    @State private var category: HabitCategory = .sport
    @State private var type: HabitType = .hot
    @State private var targetDaysPerWeek = 3
    @State private var hasReminder = false
    @State private var reminderTime = Date()
    @State private var notes = ""
    @State private var isActive = true
    @State private var isFavorite = false
    @State private var tag: HabitTag = .none

    init(viewModel: HotColdViewModel, editing: Habit?) {
        self.viewModel = viewModel
        self.editing = editing
    }

    private var accent: Color {
        type == .hot ? .hcHot : .hcCold
    }

    private var isEditing: Bool { editing != nil }

    var body: some View {
        NavigationStack {
            ZStack {
                HCDeepBackdrop()

                ScrollView {
                    VStack(spacing: 16) {
                        sectionCard(title: nil) {
                            TextField("Name", text: $name)
                                .foregroundColor(.white)
                                .tint(accent)

                            rowDivider

                            Picker("Category", selection: $category) {
                                ForEach(HabitCategory.allCases, id: \.self) { cat in
                                    HStack {
                                        Image(systemName: cat.icon)
                                            .foregroundColor(cat.type.color)
                                        Text(cat.rawValue)
                                            .foregroundColor(.white)
                                    }
                                    .tag(cat)
                                }
                            }
                            .tint(accent)
                            .onChange(of: category) { newValue in
                                type = newValue.type
                            }

                            rowDivider

                            Picker("Type", selection: $type) {
                                Text("Hot (effort)").tag(HabitType.hot)
                                Text("Cold (recovery)").tag(HabitType.cold)
                            }
                            .pickerStyle(.segmented)
                            .tint(accent)
                            .onChange(of: type) { newType in
                                if category.type != newType {
                                    category = HabitCategory.allCases.first { $0.type == newType } ?? category
                                }
                            }

                            rowDivider

                            Text("Color tag")
                                .font(.caption)
                                .foregroundColor(.gray)
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 72))], spacing: 10) {
                                ForEach(HabitTag.allCases) { t in
                                    Button {
                                        tag = t
                                    } label: {
                                        VStack(spacing: 6) {
                                            Circle()
                                                .fill(t.swatch)
                                                .frame(width: 28, height: 28)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white.opacity(tag == t ? 0.9 : 0.2), lineWidth: tag == t ? 2 : 1)
                                                )
                                            Text(t.rawValue)
                                                .font(.caption2)
                                                .foregroundColor(.white)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.white.opacity(tag == t ? 0.08 : 0.02))
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        sectionCard(title: "Schedule") {
                            HStack {
                                Text("Days per week goal")
                                    .foregroundColor(.white)
                                Spacer()
                                Stepper(value: $targetDaysPerWeek, in: 1...7) {
                                    Text("\(targetDaysPerWeek)")
                                        .foregroundColor(accent)
                                        .monospacedDigit()
                                }
                                .tint(accent)
                            }

                            rowDivider

                            Toggle("Reminder", isOn: $hasReminder)
                                .tint(accent)
                                .foregroundColor(.white)

                            if hasReminder {
                                rowDivider
                                DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                    .tint(accent)
                                    .foregroundColor(.white)
                            }
                        }

                        sectionCard(title: "Notes") {
                            TextEditor(text: $notes)
                                .frame(minHeight: 100)
                                .foregroundColor(.white)
                                .tint(accent)
                                .scrollContentBackground(.hidden)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.black.opacity(0.35))
                                )
                        }

                        sectionCard(title: nil) {
                            Toggle("Active", isOn: $isActive)
                                .tint(accent)
                                .foregroundColor(.white)

                            rowDivider

                            Toggle("Favorite", isOn: $isFavorite)
                                .tint(.hcHot)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle(isEditing ? "Edit habit" : "New habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.hcBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.hcHot)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .foregroundColor(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .hcHot)
                }
            }
            .onAppear {
                if let h = editing {
                    name = h.name
                    category = h.category
                    type = h.type
                    targetDaysPerWeek = h.targetDaysPerWeek
                    if let r = h.reminderTime {
                        hasReminder = true
                        reminderTime = r
                    } else {
                        hasReminder = false
                    }
                    notes = h.notes ?? ""
                    isActive = h.isActive
                    isFavorite = h.isFavorite
                    tag = h.tag
                } else {
                    type = category.type
                }
            }
        }
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.22))
            .frame(height: 1)
            .padding(.vertical, 4)
    }

    private func sectionCard<Content: View>(title: String?, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title, !title.isEmpty {
                Text(title.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
            }
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .hcElevatedCard(cornerRadius: 16, accent: accent)
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if let existing = editing {
            var h = existing
            h.name = trimmed
            h.category = category
            h.type = type
            h.targetDaysPerWeek = targetDaysPerWeek
            h.reminderTime = hasReminder ? reminderTime : nil
            h.notes = notes.isEmpty ? nil : notes
            h.isActive = isActive
            h.isFavorite = isFavorite
            h.tag = tag
            viewModel.updateHabit(h)
        } else {
            let habit = Habit(
                id: UUID(),
                name: trimmed,
                category: category,
                type: type,
                targetDaysPerWeek: targetDaysPerWeek,
                reminderTime: hasReminder ? reminderTime : nil,
                notes: notes.isEmpty ? nil : notes,
                isActive: isActive,
                isFavorite: isFavorite,
                isArchived: false,
                tag: tag,
                createdAt: Date()
            )
            viewModel.addHabit(habit)
        }
        dismiss()
    }
}
