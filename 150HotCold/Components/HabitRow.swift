//
//  HabitRow.swift
//  150HotCold
//

import SwiftUI

struct HabitRow: View {
    @ObservedObject var viewModel: HotColdViewModel
    let habit: Habit
    let isCompleted: Bool
    let onCircleTap: () -> Void

    private var streakDays: Int {
        viewModel.streak(for: habit.id)?.currentStreak ?? 0
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            NavigationLink {
                HabitDetailView(habit: habit, viewModel: viewModel)
            } label: {
                HStack(spacing: 12) {
                    if habit.tag != .none {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [habit.tag.swatch, habit.tag.swatch.opacity(0.5)],
                                    center: .topLeading,
                                    startRadius: 2,
                                    endRadius: 14
                                )
                            )
                            .frame(width: 10, height: 10)
                            .shadow(color: habit.tag.swatch.opacity(0.5), radius: 4, y: 1)
                    }

                    Image(systemName: habit.category.icon)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [habit.type.color, habit.type.color.opacity(0.65)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: habit.type.color.opacity(0.35), radius: 4, y: 2)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(habit.name)
                            .font(.headline)
                            .foregroundColor(isCompleted ? .gray : .white)
                            .strikethrough(isCompleted)

                        HStack(spacing: 8) {
                            Text("\(habit.targetDaysPerWeek) d/wk")
                                .font(.caption)
                                .foregroundColor(.gray)
                            if streakDays > 0 {
                                Text("Streak \(streakDays)d")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(habit.type.color)
                            }
                        }
                    }
                }
            }
            .buttonStyle(.plain)

            Spacer(minLength: 8)

            Button(action: onCircleTap) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(
                        LinearGradient(
                            colors: isCompleted
                                ? [habit.type.color, habit.type.color.opacity(0.7)]
                                : [Color.gray.opacity(0.55), Color.gray.opacity(0.35)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .font(.title2)
                    .shadow(color: isCompleted ? habit.type.color.opacity(0.4) : .clear, radius: 6, y: 2)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .hcElevatedCard(cornerRadius: 12, accent: habit.type.color)
        .padding(.horizontal)
    }
}
