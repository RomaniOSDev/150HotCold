//
//  HabitDetailView.swift
//  150HotCold
//

import SwiftUI

struct HabitDetailView: View {
    let habit: Habit
    @ObservedObject var viewModel: HotColdViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showEdit = false
    @State private var showDeleteConfirm = false

    private var current: Habit {
        viewModel.habits.first { $0.id == habit.id } ?? habit
    }

    private var streak: Streak? {
        viewModel.streak(for: habit.id)
    }

    private var recentLogs: [HabitLog] {
        viewModel.logs
            .filter { $0.habitId == habit.id }
            .sorted { $0.date > $1.date }
            .prefix(20)
            .map { $0 }
    }

    var body: some View {
        ZStack {
            HCDeepBackdrop()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: current.category.icon)
                            .font(.largeTitle)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [current.type.color, current.type.color.opacity(0.65)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: current.type.color.opacity(0.45), radius: 10, y: 3)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(current.name)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
                            Text(current.category.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        if current.tag != .none {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [current.tag.swatch, current.tag.swatch.opacity(0.5)],
                                        center: .topLeading,
                                        startRadius: 2,
                                        endRadius: 16
                                    )
                                )
                                .frame(width: 22, height: 22)
                                .shadow(color: current.tag.swatch.opacity(0.5), radius: 6, y: 2)
                        }
                    }
                    .padding(16)
                    .hcElevatedCard(cornerRadius: 18, accent: current.type.color)

                    streakCard

                    if let desc = current.notes, !desc.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Habit notes")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(desc)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .hcElevatedCard(cornerRadius: 16, accent: Color.gray.opacity(0.7))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent logs")
                            .font(.headline)
                            .foregroundColor(.white)
                        if recentLogs.isEmpty {
                            Text("No logs yet.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(Array(recentLogs.enumerated()), id: \.element.id) { index, log in
                                logRow(log, showDivider: index < recentLogs.count - 1)
                            }
                        }
                    }
                    .padding()
                    .hcElevatedCard(cornerRadius: 16, accent: current.type.color.opacity(0.85))

                    VStack(spacing: 12) {
                        Button("Edit habit") {
                            showEdit = true
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .buttonStyle(HCGradientButtonStyle(
                            colors: [Color.hcHot.opacity(0.75), Color.hcHot.opacity(0.35)],
                            shadowColor: .hcHot
                        ))

                        if current.isArchived {
                            Button("Restore from archive") {
                                viewModel.unarchiveHabit(current)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .buttonStyle(HCGradientButtonStyle(
                                colors: [Color.hcCold.opacity(0.7), Color.hcCold.opacity(0.28)],
                                shadowColor: .hcCold
                            ))
                        } else {
                            Button("Archive") {
                                viewModel.archiveHabit(current)
                                dismiss()
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .buttonStyle(HCGradientButtonStyle(
                                colors: [Color.white.opacity(0.14), Color.white.opacity(0.06)],
                                shadowColor: .black
                            ))
                        }

                        Button("Delete permanently", role: .destructive) {
                            showDeleteConfirm = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.red.opacity(0.55), Color.red.opacity(0.22)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.red.opacity(0.45), lineWidth: 1)
                        )
                        .shadow(color: Color.red.opacity(0.35), radius: 10, y: 4)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEdit) {
            HabitEditorView(viewModel: viewModel, editing: viewModel.habits.first { $0.id == habit.id })
        }
        .alert("Delete this habit?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deleteHabit(current)
                dismiss()
            }
        } message: {
            Text("All logs for this habit will be removed.")
        }
    }

    private var streakCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Streak")
                .font(.headline)
                .foregroundColor(.white)
            if let s = streak {
                HStack(spacing: 24) {
                    VStack(alignment: .leading) {
                        Text("Current")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(s.currentStreak) days")
                            .font(.title2)
                            .bold()
                            .foregroundColor(current.type.color)
                    }
                    VStack(alignment: .leading) {
                        Text("Best")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(s.bestStreak) days")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                    }
                }
            } else {
                Text("Complete this habit on a day to start a streak.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .hcElevatedCard(cornerRadius: 16, accent: current.type.color)
    }

    private func logRow(_ log: HabitLog, showDivider: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(formattedDate(log.date))
                    .font(.subheadline)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: log.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(
                        LinearGradient(
                            colors: log.completed
                                ? [current.type.color, current.type.color.opacity(0.7)]
                                : [Color.gray.opacity(0.55), Color.gray.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            if let m = log.duration, m > 0 {
                Text("\(m) min")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            if let n = log.notes, !n.isEmpty {
                Text(n)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) {
            if showDivider {
                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 1)
            }
        }
    }
}
