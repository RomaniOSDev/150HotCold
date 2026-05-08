//
//  StatsView.swift
//  150HotCold
//

import Charts
import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: HotColdViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                HCDeepBackdrop()

                List {
                    Section {
                        Text("Statistics")
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.hcHot, Color.orange.opacity(0.85)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .hcHot.opacity(0.4), radius: 10, y: 3)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }

                    Section {
                        statCardsGrid
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }

                    Section {
                        weeklyRecapContent
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    } header: {
                        Text("Week at a glance")
                            .foregroundColor(.gray)
                    }

                    Section {
                        weeklyChartContent
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    } header: {
                        Text("Weekly balance")
                            .foregroundColor(.gray)
                    }

                    Section {
                        achievementsListContent
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    } header: {
                        Text("Achievements")
                            .foregroundColor(.gray)
                    }

                    Section {
                        topHabitsContent
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    } header: {
                        Text("Top habits")
                            .foregroundColor(.gray)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }

    // MARK: - Stat cards (explicit rows — no LazyVGrid in ScrollView)

    private var statCardsGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(
                    title: "Hot habits",
                    value: "\(viewModel.totalHotHabits)",
                    icon: "flame.fill",
                    color: .hcHot
                )
                .frame(maxWidth: .infinity)
                StatCard(
                    title: "Cold habits",
                    value: "\(viewModel.totalColdHabits)",
                    icon: "snowflake",
                    color: .hcCold
                )
                .frame(maxWidth: .infinity)
            }
            HStack(spacing: 12) {
                StatCard(
                    title: "Hot completion",
                    value: String(format: "%.0f%%", viewModel.hotCompletionRate),
                    icon: "flame.fill",
                    color: .hcHot
                )
                .frame(maxWidth: .infinity)
                StatCard(
                    title: "Cold completion",
                    value: String(format: "%.0f%%", viewModel.coldCompletionRate),
                    icon: "snowflake",
                    color: .hcCold
                )
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 4)
    }

    private var weeklyRecapContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 16) {
                if let best = viewModel.weeklyBestDay {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Calmest day")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(best.day)
                            .font(.title3)
                            .bold()
                            .foregroundColor(.hcCold)
                        Text("Balance \(best.balance >= 0 ? "+" : "")\(best.balance)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                if let worst = viewModel.weeklyWorstDay {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Most tilted")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(worst.day)
                            .font(.title3)
                            .bold()
                            .foregroundColor(.hcHot)
                        Text("Balance \(worst.balance >= 0 ? "+" : "")\(worst.balance)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(12)
        .hcElevatedCard(cornerRadius: 16, accent: .hcCold)
    }

    private var weeklyChartContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Chart {
                ForEach(viewModel.weeklyBalance) { data in
                    BarMark(
                        x: .value("Day", data.day),
                        y: .value("Balance", data.balance)
                    )
                    .foregroundStyle(barColor(for: data.balance))
                }
            }
            .frame(height: 160)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.gray.opacity(0.3))
                    AxisValueLabel()
                        .foregroundStyle(Color.gray)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.gray.opacity(0.3))
                    AxisValueLabel()
                        .foregroundStyle(Color.gray)
                }
            }
        }
        .padding(12)
        .hcElevatedCard(cornerRadius: 16, accent: .hcHot)
    }

    private func barColor(for balance: Int) -> Color {
        if balance > 0 { return .hcHot }
        if balance < 0 { return .hcCold }
        return .gray
    }

    private var achievementsListContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Unlock badges as you use the app.")
                .font(.caption)
                .foregroundColor(.gray)

            VStack(spacing: 10) {
                ForEach(Array(AchievementID.allCases), id: \.rawValue) { aid in
                    achievementTile(
                        id: aid,
                        unlocked: viewModel.unlockedAchievementIds.contains(aid.rawValue)
                    )
                }
            }
        }
        .padding(.vertical, 6)
    }

    private func achievementTile(id: AchievementID, unlocked: Bool) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: id.icon)
                .font(.title3)
                .foregroundStyle(
                    LinearGradient(
                        colors: unlocked
                            ? [Color.hcHot, Color.orange.opacity(0.85)]
                            : [Color.gray.opacity(0.65), Color.gray.opacity(0.35)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: unlocked ? Color.hcHot.opacity(0.4) : .clear, radius: 6, y: 2)
                .frame(width: 32, alignment: .center)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(id.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: unlocked ? "checkmark.seal.fill" : "lock.fill")
                        .font(.caption)
                        .foregroundColor(unlocked ? .hcCold : .gray.opacity(0.7))
                }
                Text(id.detail)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .hcElevatedCard(cornerRadius: 12, accent: unlocked ? .hcHot : Color.gray.opacity(0.6))
    }

    private var topHabitsContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.topHabits.isEmpty {
                Text("Complete habits to see rankings.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                ForEach(viewModel.topHabits) { habit in
                    HStack {
                        Image(systemName: habit.category.icon)
                            .foregroundColor(habit.type.color)
                            .frame(width: 30)

                        Text(habit.name)
                            .foregroundColor(.white)

                        Spacer()

                        Text(String(format: "%.0f%%", habit.completionRate))
                            .foregroundColor(habit.type.color)
                            .bold()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(12)
        .hcElevatedCard(cornerRadius: 16, accent: .hcCold)
    }
}
