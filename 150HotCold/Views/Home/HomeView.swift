//
//  HomeView.swift
//  150HotCold
//

import Charts
import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HotColdViewModel
    @Binding var selectedTab: Int
    @State private var showAddHabit = false

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }

    private var unlockedAchievements: Int {
        AchievementID.allCases.filter { viewModel.unlockedAchievementIds.contains($0.rawValue) }.count
    }

    private var totalAchievements: Int {
        AchievementID.allCases.count
    }

    private var todayProgress: Double {
        let done = viewModel.todayHotCompleted + viewModel.todayColdCompleted
        let total = max(viewModel.todayHotTotal + viewModel.todayColdTotal, 1)
        return Double(done) / Double(total)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                HCDeepBackdrop()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        headerBlock

                        heroBalanceWidget

                        HStack(alignment: .top, spacing: 12) {
                            streakWidget
                            todayProgressWidget
                        }

                        HStack(alignment: .top, spacing: 12) {
                            achievementsWidget
                            balanceComfortWidget
                        }

                        weeklyChartWidget

                        insightWidget

                        quickActionsRow
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 28)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddHabit = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color.white, Color.hcHot)
                            .font(.title2)
                    }
                    .accessibilityLabel("Add habit")
                }
            }
            .sheet(isPresented: $showAddHabit) {
                AddHabitView(viewModel: viewModel)
            }
        }
    }

    // MARK: - Header

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greeting)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            Text(formattedHeaderDate())
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    private func formattedHeaderDate() -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        f.locale = Locale(identifier: "en_US")
        return f.string(from: Date())
    }

    // MARK: - Widgets

    private var heroBalanceWidget: some View {
        Button {
            selectedTab = 1
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Today’s balance")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.85))
                        Text(scoreLabel(viewModel.todayBalance))
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.15), lineWidth: 10)
                            .frame(width: 72, height: 72)
                        Circle()
                            .trim(from: 0, to: min(todayProgress, 1))
                            .stroke(
                                AngularGradient(
                                    colors: [.hcCold, .hcHot],
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .frame(width: 72, height: 72)
                            .rotationEffect(.degrees(-90))
                        Text("\(Int(min(todayProgress, 1) * 100))%")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }

                HStack(spacing: 14) {
                    miniPill(
                        title: "Hot",
                        done: viewModel.todayHotCompleted,
                        total: viewModel.todayHotTotal,
                        color: .hcHot
                    )
                    miniPill(
                        title: "Cold",
                        done: viewModel.todayColdCompleted,
                        total: viewModel.todayColdTotal,
                        color: .hcCold
                    )
                }

                HStack {
                    Text("Open checklist")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                }
                .foregroundColor(.white.opacity(0.75))
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.hcHot.opacity(0.35),
                                Color.hcBackground.opacity(0.95),
                                Color.hcCold.opacity(0.22)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.45), radius: 22, y: 12)
            .shadow(color: Color.hcHot.opacity(0.18), radius: 28, y: 4)
        }
        .buttonStyle(.plain)
    }

    private func scoreLabel(_ balance: Int) -> String {
        if balance > 0 { return "+\(balance)" }
        return "\(balance)"
    }

    private func miniPill(title: String, done: Int, total: Int, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text("\(done)/\(total)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            ProgressView(value: Double(done) / Double(max(total, 1)))
                .tint(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.black.opacity(0.25))
        )
    }

    private var streakWidget: some View {
        Button {
            selectedTab = 1
        } label: {
            widgetShell(accent: .hcHot, icon: "flame.fill", title: "Activity streak", subtitle: "Days in a row") {
                Text("\(viewModel.streakDays)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("half+ habits done")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .buttonStyle(.plain)
    }

    private var todayProgressWidget: some View {
        Button {
            selectedTab = 1
        } label: {
            widgetShell(accent: .hcCold, icon: "checkmark.circle.fill", title: "Today’s progress", subtitle: "Hot + cold") {
                Text("\(viewModel.todayHotCompleted + viewModel.todayColdCompleted)/\(viewModel.todayHotTotal + viewModel.todayColdTotal)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                ProgressView(value: todayProgress)
                    .tint(.hcCold)
            }
        }
        .buttonStyle(.plain)
    }

    private var achievementsWidget: some View {
        Button {
            selectedTab = 4
        } label: {
            widgetShell(accent: .hcHot, icon: "trophy.fill", title: "Awards", subtitle: "Unlocked badges") {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(unlockedAchievements)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("/ \(totalAchievements)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                ProgressView(value: Double(unlockedAchievements), total: Double(max(totalAchievements, 1)))
                    .tint(.hcHot)
            }
        }
        .buttonStyle(.plain)
    }

    private var balanceComfortWidget: some View {
        Button {
            selectedTab = 1
        } label: {
            widgetShell(
                accent: viewModel.balanceGoalWarning == nil ? .hcCold : .hcHot,
                icon: viewModel.balanceGoalWarning == nil ? "checkmark.shield.fill" : "exclamationmark.triangle.fill",
                title: "Balance goals",
                subtitle: viewModel.balanceGoalWarning == nil ? "Within comfort" : "Heads up"
            ) {
                if let w = viewModel.balanceGoalWarning {
                    Text(w)
                        .font(.caption2)
                        .foregroundColor(.hcHot.opacity(0.95))
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text("Hot/cold lead is inside your limits today.")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var weeklyChartWidget: some View {
        Button {
            selectedTab = 2
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.hcHot)
                    Text("Week balance")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.gray)
                }
                Chart {
                    ForEach(viewModel.weeklyBalance) { data in
                        BarMark(
                            x: .value("Day", data.day),
                            y: .value("Balance", data.balance)
                        )
                        .foregroundStyle(barColor(for: data.balance))
                    }
                }
                .frame(height: 120)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color.gray)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color.gray.opacity(0.8))
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(widgetBackground())
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
    }

    private func barColor(for balance: Int) -> Color {
        if balance > 0 { return .hcHot }
        if balance < 0 { return .hcCold }
        return .gray
    }

    private var insightWidget: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundColor(.hcCold)
                Text("Insight")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            Text(viewModel.dailyHint)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.88))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(widgetBackground())
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.hcCold.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
    }

    private var quickActionsRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Shortcuts")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)

            HStack(spacing: 10) {
                shortcutChip(title: "Checklist", icon: "list.bullet", tab: 1)
                shortcutChip(title: "Stats", icon: "chart.bar.fill", tab: 2)
                shortcutChip(title: "History", icon: "clock.arrow.circlepath", tab: 3)
            }
        }
    }

    private func shortcutChip(title: String, icon: String, tab: Int) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.hcHot)
                Text(title)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Widget shell

    private func widgetShell<Content: View>(
        accent: Color,
        icon: String,
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(accent)
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.gray.opacity(0.6))
            }
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(widgetBackground())
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(accent.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.22), radius: 10, y: 5)
    }

    private func widgetBackground() -> some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color.white.opacity(0.055))
    }
}
