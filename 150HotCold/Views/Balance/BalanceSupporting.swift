//
//  BalanceSupporting.swift
//  150HotCold
//
//  Haptics + balance-related sheets (single file so the target always sees them).

import SwiftUI
import UIKit

enum HapticFeedback {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

// MARK: - Complete habit

struct CompleteHabitSheet: View {
    let habit: Habit
    @ObservedObject var viewModel: HotColdViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var durationMinutes: Double = 0
    @State private var logNote = ""
    @State private var dayNote = ""

    private var accent: Color {
        habit.type == .hot ? .hcHot : .hcCold
    }

    var body: some View {
        NavigationStack {
            ZStack {
                HCDeepBackdrop()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(habit.name)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.35), radius: 2, y: 1)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Duration (minutes)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(durationMinutes == 0 ? "None" : "\(Int(durationMinutes)) min")
                                .foregroundColor(accent)
                                .font(.headline)
                            Slider(value: $durationMinutes, in: 0...120, step: 5)
                                .tint(accent)
                        }
                        .padding()
                        .hcElevatedCard(cornerRadius: 16, accent: accent)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Log note")
                                .font(.caption)
                                .foregroundColor(.gray)
                            TextField("e.g. light workout", text: $logNote)
                                .foregroundColor(.white)
                                .tint(accent)
                        }
                        .padding()
                        .hcElevatedCard(cornerRadius: 16, accent: accent.opacity(0.9))

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Day note (optional)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            TextField("How the day feels overall", text: $dayNote, axis: .vertical)
                                .lineLimit(3...6)
                                .foregroundColor(.white)
                                .tint(accent)
                        }
                        .padding()
                        .hcElevatedCard(cornerRadius: 16, accent: Color.gray.opacity(0.6))
                    }
                    .padding()
                }
            }
            .navigationTitle("Log completion")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.hcBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.hcHot)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.applyCompletion(
                            habit: habit,
                            durationMinutes: Int(durationMinutes),
                            logNote: logNote,
                            dayNote: dayNote
                        )
                        HapticFeedback.success()
                        dismiss()
                    }
                    .foregroundColor(.hcHot)
                }
            }
            .onAppear {
                let cal = Calendar.current
                let today = cal.startOfDay(for: Date())
                if let existing = viewModel.logForToday(habitId: habit.id) {
                    durationMinutes = Double(existing.duration ?? 0)
                    logNote = existing.notes ?? ""
                }
                dayNote = viewModel.dayNote(for: today) ?? ""
            }
        }
    }
}

// MARK: - Archived habits

struct ArchivedHabitsSheet: View {
    @ObservedObject var viewModel: HotColdViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                HCDeepBackdrop()

                if viewModel.archivedHabits.isEmpty {
                    Text("No archived habits.")
                        .foregroundColor(.gray)
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .hcElevatedCard(cornerRadius: 18, accent: Color.gray.opacity(0.5))
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.archivedHabits) { habit in
                            HStack {
                                Image(systemName: habit.category.icon)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [habit.type.color, habit.type.color.opacity(0.65)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: habit.type.color.opacity(0.35), radius: 6, y: 2)
                                VStack(alignment: .leading) {
                                    Text(habit.name)
                                        .foregroundColor(.white)
                                    Text(habit.type == .hot ? "Hot" : "Cold")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Button("Restore") {
                                    viewModel.unarchiveHabit(habit)
                                }
                                .foregroundColor(.hcCold)
                            }
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.08),
                                                Color.white.opacity(0.03)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 4)
                            )
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Archived")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.hcBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.hcHot)
                }
            }
        }
    }
}

// MARK: - Balance goals

struct BalanceGoalsSheet: View {
    @ObservedObject var viewModel: HotColdViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                HCDeepBackdrop()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Daily balance comfort")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)

                        VStack(alignment: .leading, spacing: 12) {
                            Stepper(
                                "Hot lead warning: \(viewModel.maxHotLeadBeforeWarning == 0 ? "Off" : "+\(viewModel.maxHotLeadBeforeWarning)")",
                                value: $viewModel.maxHotLeadBeforeWarning,
                                in: 0...8
                            )
                            .foregroundColor(.white)
                            Text("When today’s balance (hot done − cold done) is above this number, a soft warning appears. 0 = off.")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Divider().background(Color.gray.opacity(0.3))

                            Stepper(
                                "Cold lead warning: \(viewModel.maxColdLeadBeforeWarning == 0 ? "Off" : "−\(viewModel.maxColdLeadBeforeWarning)")",
                                value: $viewModel.maxColdLeadBeforeWarning,
                                in: 0...8
                            )
                            .foregroundColor(.white)
                            Text("When balance is below minus this number (more cold completions than hot), a warning appears. 0 = off.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .hcElevatedCard(cornerRadius: 16, accent: Color.hcHot.opacity(0.4))
                    }
                    .padding()
                }
            }
            .navigationTitle("Balance goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.hcBackground, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        viewModel.saveToUserDefaults()
                        dismiss()
                    }
                    .foregroundColor(.hcHot)
                }
            }
        }
    }
}
