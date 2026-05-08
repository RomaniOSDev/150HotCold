//
//  BalanceView.swift
//  150HotCold
//

import SwiftUI

struct BalanceView: View {
    @ObservedObject var viewModel: HotColdViewModel
    @State private var showAddHabitSheet = false
    @State private var completionTarget: Habit?
    @State private var showArchived = false
    @State private var showGoals = false

    private var todayTitle: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: Date())
    }

    private var showCompletionSheet: Binding<Bool> {
        Binding(
            get: { completionTarget != nil },
            set: { if !$0 { completionTarget = nil } }
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                HCDeepBackdrop()

                List {
                    Section {
                        headerBlock
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }

                    if viewModel.showHotSectionFirst {
                        hotHabitsSection
                        coldHabitsSection
                    } else {
                        coldHabitsSection
                        hotHabitsSection
                    }

                    Section {
                        Button {
                            showAddHabitSheet = true
                        } label: {
                            Text("Add habit")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.hcHot.opacity(0.65), Color.hcHot.opacity(0.22)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                                )
                                .shadow(color: Color.hcHot.opacity(0.4), radius: 12, y: 5)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.clear)
                    }
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button("Archived habits") { showArchived = true }
                        Button("Balance comfort goals") { showGoals = true }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(Color.white, Color.hcHot)
                            .symbolRenderingMode(.palette)
                            .font(.title3)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddHabitSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color.white, Color.hcHot)
                            .font(.title2)
                    }
                    .accessibilityLabel("Add habit")
                }
            }
            .sheet(isPresented: $showAddHabitSheet) {
                AddHabitView(viewModel: viewModel)
            }
            .sheet(isPresented: $showArchived) {
                ArchivedHabitsSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showGoals) {
                BalanceGoalsSheet(viewModel: viewModel)
            }
            .sheet(isPresented: showCompletionSheet, onDismiss: { completionTarget = nil }) {
                if let h = completionTarget {
                    CompleteHabitSheet(habit: h, viewModel: viewModel)
                }
            }
        }
    }

    // MARK: - Header block (inside List)

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Today")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.hcHot, Color.orange.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .hcHot.opacity(0.45), radius: 12, y: 4)
                Text(todayTitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    StatCard(
                        title: "Hot habits",
                        value: "\(viewModel.totalHotHabits)",
                        icon: "flame.fill",
                        color: .hcHot
                    )
                    StatCard(
                        title: "Cold habits",
                        value: "\(viewModel.totalColdHabits)",
                        icon: "snowflake",
                        color: .hcCold
                    )
                    StatCard(
                        title: "Today's balance",
                        value: "\(viewModel.todayBalance)",
                        icon: "scalemass.fill",
                        color: balanceAccent
                    )
                    StatCard(
                        title: "Streak (days)",
                        value: "\(viewModel.streakDays)",
                        icon: "flame.fill",
                        color: .hcHot
                    )
                }
            }
            .frame(height: 120)

            weeklyInsightCard

            dailyHintCard

            if let warn = viewModel.balanceGoalWarning {
                Text(warn)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.95))
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.hcHot.opacity(0.55), Color.hcHot.opacity(0.18)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.hcHot.opacity(0.55), lineWidth: 1)
                    )
                    .shadow(color: Color.hcHot.opacity(0.35), radius: 14, y: 6)
            }

            todayBalanceSection

            filtersBlock
        }
        .padding(.vertical, 8)
    }

    private var weeklyInsightCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("This week")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            HStack {
                if let best = viewModel.weeklyBestDay {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Calmest day")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text("\(best.day) (\(best.balance >= 0 ? "+" : "")\(best.balance))")
                            .font(.subheadline)
                            .foregroundColor(.hcCold)
                    }
                }
                Spacer()
                if let worst = viewModel.weeklyWorstDay {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Most tilted")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text("\(worst.day) (\(worst.balance >= 0 ? "+" : "")\(worst.balance))")
                            .font(.subheadline)
                            .foregroundColor(.hcHot)
                    }
                }
            }
        }
        .padding()
        .hcElevatedCard(cornerRadius: 14, accent: .hcCold)
    }

    private var dailyHintCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(
                    LinearGradient(colors: [.hcCold, .hcCold.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                )
                .shadow(color: .hcCold.opacity(0.35), radius: 6, y: 2)
            Text(viewModel.dailyHint)
                .font(.caption)
                .foregroundColor(.white.opacity(0.92))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .hcElevatedCard(cornerRadius: 14, accent: .hcCold)
    }

    private var filtersBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField(
                "",
                text: Binding(
                    get: { viewModel.habitSearchQuery },
                    set: { viewModel.habitSearchQuery = $0 }
                ),
                prompt: Text("Search habits").foregroundColor(Color.gray.opacity(0.65))
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.black.opacity(0.35), Color.black.opacity(0.2)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .foregroundColor(.white)
            .tint(.hcHot)

            HStack {
                Picker("Sort", selection: Binding(
                    get: { viewModel.habitSort },
                    set: {
                        viewModel.habitSort = $0
                        viewModel.saveToUserDefaults()
                    }
                )) {
                    ForEach(HabitSort.allCases) { s in
                        Text(s.rawValue).tag(s)
                    }
                }
                .pickerStyle(.menu)
                .tint(.hcHot)
                .foregroundColor(.white)

                Picker("Tag", selection: $viewModel.tagFilterMode) {
                    ForEach(TagFilterMode.allCases) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                .pickerStyle(.menu)
                .tint(.hcCold)
                .foregroundColor(.white)
            }
        }
        .padding(12)
        .hcElevatedCard(cornerRadius: 14, accent: Color.gray.opacity(0.9))
    }

    private var balanceAccent: Color {
        if viewModel.todayBalance > 0 { return .hcHot }
        if viewModel.todayBalance < 0 { return .hcCold }
        return .gray
    }

    private var todayBalanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BALANCE TODAY")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)

            HStack(spacing: 20) {
                VStack {
                    Text("HOT")
                        .font(.caption)
                        .foregroundColor(.hcHot)
                    Text("\(viewModel.todayHotCompleted)/\(viewModel.todayHotTotal)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.hcHot)
                    ProgressView(
                        value: Double(viewModel.todayHotCompleted) / Double(max(viewModel.todayHotTotal, 1))
                    )
                    .tint(.hcHot)
                    .frame(width: 80)
                }
                .frame(maxWidth: .infinity)

                Text("⚖️")
                    .font(.title)
                    .foregroundColor(.gray)

                VStack {
                    Text("COLD")
                        .font(.caption)
                        .foregroundColor(.hcCold)
                    Text("\(viewModel.todayColdCompleted)/\(viewModel.todayColdTotal)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.hcCold)
                    ProgressView(
                        value: Double(viewModel.todayColdCompleted) / Double(max(viewModel.todayColdTotal, 1))
                    )
                    .tint(.hcCold)
                    .frame(width: 80)
                }
                .frame(maxWidth: .infinity)
            }

            balanceHintText
                .font(.caption)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding()
        .hcElevatedCard(cornerRadius: 16, accent: balanceAccent)
    }

    @ViewBuilder
    private var balanceHintText: some View {
        if viewModel.todayBalance > 0 {
            Text("🔥 You're running hot! Add cold habits to rebalance.")
                .foregroundColor(.hcHot)
        } else if viewModel.todayBalance < 0 {
            Text("❄️ You need more activity! Add hot habits.")
                .foregroundColor(.hcCold)
        } else {
            Text("✨ Perfect balance. Keep it up!")
                .foregroundColor(.gray)
        }
    }

    // MARK: - Habit sections

    private var hotHabitsSection: some View {
        Section {
            if viewModel.todayHotHabits.isEmpty {
                Text("No hot habits match filters.")
                    .foregroundColor(.gray)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(viewModel.todayHotHabits) { habit in
                    habitRow(habit)
                }
            }
        } header: {
            Text("🔥 HOT HABITS")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.hcHot)
        }
    }

    private var coldHabitsSection: some View {
        Section {
            if viewModel.todayColdHabits.isEmpty {
                Text("No cold habits match filters.")
                    .foregroundColor(.gray)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(viewModel.todayColdHabits) { habit in
                    habitRow(habit)
                }
            }
        } header: {
            Text("❄️ COLD HABITS")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.hcCold)
        }
    }

    private func habitRow(_ habit: Habit) -> some View {
        HabitRow(
            viewModel: viewModel,
            habit: habit,
            isCompleted: viewModel.isHabitCompletedToday(habit.id),
            onCircleTap: {
                if viewModel.isHabitCompletedToday(habit.id) {
                    viewModel.toggleHabitIncomplete(habit)
                    HapticFeedback.light()
                } else {
                    completionTarget = habit
                    HapticFeedback.light()
                }
            }
        )
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 0))
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                if viewModel.isHabitCompletedToday(habit.id) {
                    viewModel.toggleHabitIncomplete(habit)
                    HapticFeedback.light()
                } else {
                    completionTarget = habit
                    HapticFeedback.light()
                }
            } label: {
                Label(
                    viewModel.isHabitCompletedToday(habit.id) ? "Undo" : "Done",
                    systemImage: viewModel.isHabitCompletedToday(habit.id) ? "arrow.uturn.backward" : "checkmark"
                )
            }
            .tint(habit.type.color)
        }
        .swipeActions(edge: .trailing) {
            Button {
                viewModel.archiveHabit(habit)
            } label: {
                Label("Archive", systemImage: "archivebox.fill")
            }
            .tint(.gray)
        }
    }
}
