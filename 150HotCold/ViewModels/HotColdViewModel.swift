//
//  HotColdViewModel.swift
//  150HotCold
//

import Combine
import Foundation

@MainActor
final class HotColdViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var logs: [HabitLog] = []
    @Published var streaks: [Streak] = []
    @Published var dayNotes: [DayNote] = []
    @Published var unlockedAchievementIds: Set<String> = []

    @Published var habitSearchQuery: String = ""
    @Published var habitSort: HabitSort = .favoritesFirst
    @Published var tagFilterMode: TagFilterMode = .all

    /// When today’s balance score (hot done − cold done) exceeds this, show a soft warning. 0 = off.
    @Published var maxHotLeadBeforeWarning: Int = 2
    /// When balance is below −this value, warn. 0 = off.
    @Published var maxColdLeadBeforeWarning: Int = 2

    private let habitsKey = "hotcold_habits"
    private let logsKey = "hotcold_logs"
    private let streaksKey = "hotcold_streaks"
    private let dayNotesKey = "hotcold_day_notes"
    private let achievementsKey = "hotcold_achievements"
    private let settingsKey = "hotcold_settings"

    private struct PersistedSettings: Codable {
        var maxHotLead: Int
        var maxColdLead: Int
        var habitSort: HabitSort
    }

    init() {
        loadFromUserDefaults()
    }

    // MARK: - Filtering

    private func habitPassesTagFilter(_ habit: Habit) -> Bool {
        switch tagFilterMode {
        case .all: return true
        case .untagged: return habit.tag == .none
        case .coral, .sky, .lime, .violet, .amber:
            guard let want = tagFilterMode.habitTag else { return true }
            return habit.tag == want
        }
    }

    private func habitPassesSearch(_ habit: Habit) -> Bool {
        let q = habitSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty { return true }
        return habit.name.localizedCaseInsensitiveContains(q)
    }

    private func sortHabits(_ list: [Habit]) -> [Habit] {
        var list = list
        switch habitSort {
        case .favoritesFirst:
            list.sort { a, b in
                if a.isFavorite != b.isFavorite { return a.isFavorite && !b.isFavorite }
                return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
            }
        case .nameAZ:
            list.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .hotTypeFirst, .coldTypeFirst:
            list.sort { a, b in
                if a.isFavorite != b.isFavorite { return a.isFavorite && !b.isFavorite }
                return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
            }
        }
        return list
    }

    func filteredHabits(type: HabitType) -> [Habit] {
        let base = habits.filter { habit in
            habit.type == type
                && habit.isActive
                && !habit.isArchived
                && shouldShowToday(habit)
                && habitPassesSearch(habit)
                && habitPassesTagFilter(habit)
        }
        return sortHabits(base)
    }

    /// Section order: `true` means show hot block before cold.
    var showHotSectionFirst: Bool {
        habitSort != .coldTypeFirst
    }

    // MARK: - Counts (non-archived, active)

    var totalHotHabits: Int {
        habits.filter { $0.type == .hot && $0.isActive && !$0.isArchived }.count
    }

    var totalColdHabits: Int {
        habits.filter { $0.type == .cold && $0.isActive && !$0.isArchived }.count
    }

    var todayHotHabits: [Habit] { filteredHabits(type: .hot) }
    var todayColdHabits: [Habit] { filteredHabits(type: .cold) }

    var todayHotTotal: Int { todayHotHabits.count }
    var todayColdTotal: Int { todayColdHabits.count }

    var todayHotCompleted: Int {
        todayHotHabits.filter { isHabitCompletedToday($0.id) }.count
    }

    var todayColdCompleted: Int {
        todayColdHabits.filter { isHabitCompletedToday($0.id) }.count
    }

    var todayBalance: Int {
        todayHotCompleted - todayColdCompleted
    }

    var balanceGoalWarning: String? {
        var parts: [String] = []
        if maxHotLeadBeforeWarning > 0, todayBalance > maxHotLeadBeforeWarning {
            parts.append("Hot side is ahead by more than your \(maxHotLeadBeforeWarning)-point comfort zone.")
        }
        if maxColdLeadBeforeWarning > 0, todayBalance < -maxColdLeadBeforeWarning {
            parts.append("Cold side is ahead by more than your \(maxColdLeadBeforeWarning)-point comfort zone.")
        }
        return parts.isEmpty ? nil : parts.joined(separator: " ")
    }

    func balanceScore(on day: Date) -> Int {
        let cal = Calendar.current
        let start = cal.startOfDay(for: day)
        let hotList = habits.filter { $0.type == .hot && !$0.isArchived }
        let coldList = habits.filter { $0.type == .cold && !$0.isArchived }
        let hotDone = hotList.filter { isHabitCompletedOnDate($0.id, date: start) }.count
        let coldDone = coldList.filter { isHabitCompletedOnDate($0.id, date: start) }.count
        return hotDone - coldDone
    }

    var yesterdayBalance: Int {
        let cal = Calendar.current
        guard let y = cal.date(byAdding: .day, value: -1, to: Date()) else { return 0 }
        return balanceScore(on: y)
    }

    var dailyHint: String {
        let y = yesterdayBalance
        let cal = Calendar.current
        let yDate = cal.date(byAdding: .day, value: -1, to: Date()).map { cal.startOfDay(for: $0) } ?? Date()
        let hadLogs = logs.contains { cal.isDate($0.date, inSameDayAs: yDate) }
        if !hadLogs {
            return "New day — set a small goal for hot and cold."
        }
        if y > 1 {
            return "Yesterday leaned hot — plan a cold recovery block today."
        }
        if y < -1 {
            return "Yesterday leaned cold — add one focused hot block today."
        }
        if abs(y) <= 1 {
            return "Yesterday was balanced. Keep alternating effort and recovery."
        }
        return "Check in with how you feel and adjust today’s mix."
    }

    struct WeeklyDayInsight: Identifiable {
        let id: String
        let day: String
        let balance: Int
    }

    var weeklyBalance: [WeeklyBalancePoint] {
        let calendar = Calendar.current
        let today = Date()
        let weekDays = Array((0..<7).compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }.reversed())
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "en_US")
        return weekDays.map { date in
            let hotCompleted = habits.filter { $0.type == .hot && !$0.isArchived && $0.isActive }
                .filter { isHabitCompletedOnDate($0.id, date: date) }.count
            let coldCompleted = habits.filter { $0.type == .cold && !$0.isArchived && $0.isActive }
                .filter { isHabitCompletedOnDate($0.id, date: date) }.count
            let key = formatter.string(from: date)
            return WeeklyBalancePoint(id: key + String(date.timeIntervalSince1970), day: key, balance: hotCompleted - coldCompleted)
        }
    }

    /// Closest to zero balance = “best” equilibrium; furthest from zero = “worst” stretch.
    var weeklyBestDay: WeeklyDayInsight? {
        let pts = weeklyBalance
        guard let best = pts.min(by: { abs($0.balance) < abs($1.balance) }) else { return nil }
        return WeeklyDayInsight(id: best.id + "b", day: best.day, balance: best.balance)
    }

    var weeklyWorstDay: WeeklyDayInsight? {
        let pts = weeklyBalance
        guard let worst = pts.max(by: { abs($0.balance) < abs($1.balance) }) else { return nil }
        return WeeklyDayInsight(id: worst.id + "w", day: worst.day, balance: worst.balance)
    }

    struct WeeklyBalancePoint: Identifiable {
        let id: String
        let day: String
        let balance: Int
    }

    var hotCompletionRate: Double {
        let allHotLogs = logs.filter { habit(for: $0.habitId)?.type == .hot }
        let total = allHotLogs.count
        let completed = allHotLogs.filter(\.completed).count
        return total > 0 ? Double(completed) / Double(total) * 100 : 0
    }

    var coldCompletionRate: Double {
        let allColdLogs = logs.filter { habit(for: $0.habitId)?.type == .cold }
        let total = allColdLogs.count
        let completed = allColdLogs.filter(\.completed).count
        return total > 0 ? Double(completed) / Double(total) * 100 : 0
    }

    var streakDays: Int {
        var streak = 0
        var date = Calendar.current.startOfDay(for: Date())
        let cal = Calendar.current
        while true {
            let hotH = habits.filter { $0.type == .hot && $0.isActive && !$0.isArchived }
            let coldH = habits.filter { $0.type == .cold && $0.isActive && !$0.isArchived }
            let hotCompleted = hotH.filter { isHabitCompletedOnDate($0.id, date: date) }.count
            let coldCompleted = coldH.filter { isHabitCompletedOnDate($0.id, date: date) }.count
            let totalActive = hotH.count + coldH.count
            let totalCompleted = hotCompleted + coldCompleted
            if totalActive == 0 { break }
            if totalCompleted > 0, Double(totalCompleted) >= Double(totalActive) / 2.0 {
                streak += 1
                guard let previous = cal.date(byAdding: .day, value: -1, to: date) else { break }
                date = previous
            } else {
                break
            }
        }
        return streak
    }

    struct TopHabit: Identifiable {
        let id: UUID
        let name: String
        let category: HabitCategory
        let type: HabitType
        let completionRate: Double
    }

    var topHabits: [TopHabit] {
        habits.filter { !$0.isArchived }.map { habit in
            let habitLogs = logs.filter { $0.habitId == habit.id }
            let totalDays = max(1, habitLogs.count)
            let completed = habitLogs.filter(\.completed).count
            return TopHabit(
                id: habit.id,
                name: habit.name,
                category: habit.category,
                type: habit.type,
                completionRate: Double(completed) / Double(totalDays) * 100
            )
        }
        .sorted { $0.completionRate > $1.completionRate }
        .prefix(5)
        .map { $0 }
    }

    var dailyBalances: [DailyBalance] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: logs) { calendar.startOfDay(for: $0.date) }
        let hotHabitsAll = habits.filter { $0.type == .hot && !$0.isArchived }
        let coldHabitsAll = habits.filter { $0.type == .cold && !$0.isArchived }
        return grouped.map { date, dayLogs in
            let hotCompleted = dayLogs.filter { log in hotHabitsAll.contains { $0.id == log.habitId } && log.completed }.count
            let coldCompleted = dayLogs.filter { log in coldHabitsAll.contains { $0.id == log.habitId } && log.completed }.count
            return DailyBalance(
                date: date,
                hotCompleted: hotCompleted,
                coldCompleted: coldCompleted,
                hotTotal: hotHabitsAll.count,
                coldTotal: coldHabitsAll.count
            )
        }
        .sorted { $0.date > $1.date }
    }

    func streak(for habitId: UUID) -> Streak? {
        streaks.first { $0.habitId == habitId }
    }

    func dayNote(for date: Date) -> String? {
        let key = dayStartKey(date)
        return dayNotes.first { $0.dayStart == key }?.text
    }

    func logForToday(habitId: UUID) -> HabitLog? {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return logs.first { $0.habitId == habitId && cal.isDate($0.date, inSameDayAs: today) }
    }

    // MARK: - Helpers

    private func shouldShowToday(_ habit: Habit) -> Bool {
        _ = habit
        return true
    }

    private func habit(for id: UUID) -> Habit? {
        habits.first { $0.id == id }
    }

    func isHabitCompletedToday(_ habitId: UUID) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return logs.contains { $0.habitId == habitId && calendar.isDate($0.date, inSameDayAs: today) && $0.completed }
    }

    func isHabitCompletedOnDate(_ habitId: UUID, date: Date) -> Bool {
        let calendar = Calendar.current
        return logs.contains { $0.habitId == habitId && calendar.isDate($0.date, inSameDayAs: date) && $0.completed }
    }

    private func dayStartKey(_ date: Date) -> TimeInterval {
        Calendar.current.startOfDay(for: date).timeIntervalSince1970
    }

    // MARK: - Completion flow

    func toggleHabitIncomplete(_ habit: Habit) {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        guard let idx = logs.firstIndex(where: { $0.habitId == habit.id && cal.isDate($0.date, inSameDayAs: today) }) else { return }
        logs[idx].completed = false
        evaluateAchievements()
        saveToUserDefaults()
    }

    func applyCompletion(habit: Habit, durationMinutes: Int, logNote: String?, dayNote: String?) {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let duration: Int? = durationMinutes > 0 ? durationMinutes : nil
        let logNoteFinal = logNote.flatMap { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.flatMap { $0.isEmpty ? nil : $0 }

        if let idx = logs.firstIndex(where: { $0.habitId == habit.id && cal.isDate($0.date, inSameDayAs: today) }) {
            logs[idx].completed = true
            logs[idx].duration = duration
            logs[idx].notes = logNoteFinal
        } else {
            logs.append(
                HabitLog(
                    id: UUID(),
                    habitId: habit.id,
                    habitName: habit.name,
                    date: today,
                    completed: true,
                    duration: duration,
                    notes: logNoteFinal
                )
            )
        }

        if let dn = dayNote?.trimmingCharacters(in: .whitespacesAndNewlines), !dn.isEmpty {
            upsertDayNote(dayStart: dayStartKey(today), text: dn)
        }

        updateStreak(for: habit)
        evaluateAchievements()
        saveToUserDefaults()
    }

    private func upsertDayNote(dayStart: TimeInterval, text: String) {
        if let i = dayNotes.firstIndex(where: { $0.dayStart == dayStart }) {
            dayNotes[i].text = text
        } else {
            dayNotes.append(DayNote(dayStart: dayStart, text: text))
        }
    }

    // MARK: - CRUD habits

    func addHabit(_ habit: Habit) {
        habits.append(habit)
        evaluateAchievements()
        saveToUserDefaults()
    }

    func updateHabit(_ habit: Habit) {
        guard let i = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[i] = habit
        saveToUserDefaults()
    }

    func archiveHabit(_ habit: Habit) {
        guard let i = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[i].isArchived = true
        saveToUserDefaults()
    }

    func unarchiveHabit(_ habit: Habit) {
        guard let i = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[i].isArchived = false
        evaluateAchievements()
        saveToUserDefaults()
    }

    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        logs.removeAll { $0.habitId == habit.id }
        streaks.removeAll { $0.habitId == habit.id }
        evaluateAchievements()
        saveToUserDefaults()
    }

    var archivedHabits: [Habit] {
        habits.filter(\.isArchived).sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    // MARK: - Streak update

    private func updateStreak(for habit: Habit) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if let index = streaks.firstIndex(where: { $0.habitId == habit.id }) {
            var streak = streaks[index]
            let lastDate = streak.lastCompletedDate
            if let last = lastDate, calendar.isDate(last, inSameDayAs: today) {
                streaks[index] = streak
                return
            }
            if let last = lastDate,
               let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
               calendar.isDate(last, inSameDayAs: yesterday) {
                streak.currentStreak += 1
            } else {
                streak.currentStreak = 1
            }
            if streak.currentStreak > streak.bestStreak {
                streak.bestStreak = streak.currentStreak
            }
            streak.lastCompletedDate = today
            streaks[index] = streak
        } else {
            streaks.append(
                Streak(
                    id: UUID(),
                    habitId: habit.id,
                    currentStreak: 1,
                    bestStreak: 1,
                    lastCompletedDate: today
                )
            )
        }
    }

    // MARK: - Achievements

    private func evaluateAchievements() {
        var next = unlockedAchievementIds
        if habits.count >= 1 { next.insert(AchievementID.firstHabit.rawValue) }
        if logs.contains(where: \.completed) { next.insert(AchievementID.firstCompletion.rawValue) }
        if habits.count >= 10 { next.insert(AchievementID.tenHabits.rawValue) }

        let coldDone = logs.filter { habit(for: $0.habitId)?.type == .cold && $0.completed }.count
        if coldDone >= 30 { next.insert(AchievementID.coldCompletions30.rawValue) }
        let hotDone = logs.filter { habit(for: $0.habitId)?.type == .hot && $0.completed }.count
        if hotDone >= 30 { next.insert(AchievementID.hotCompletions30.rawValue) }

        if streaks.contains(where: { $0.bestStreak >= 14 }) {
            next.insert(AchievementID.habitBestStreak14.rawValue)
        }
        if streakDays >= 7 {
            next.insert(AchievementID.usageStreak7.rawValue)
        }

        let cal = Calendar.current
        var bestRun = 0
        var run = 0
        for offset in 0..<365 {
            guard let d = cal.date(byAdding: .day, value: -offset, to: Date()) else { break }
            let start = cal.startOfDay(for: d)
            let b = dailyBalanceCached(on: start)
            let hadPlanned = b.hotTotal + b.coldTotal > 0
            if hadPlanned, b.isBalanced {
                run += 1
                bestRun = max(bestRun, run)
            } else {
                run = 0
            }
        }
        if bestRun >= 7 {
            next.insert(AchievementID.balancedWeek.rawValue)
        }

        let maxPerDay = Dictionary(grouping: logs.filter(\.completed)) { cal.startOfDay(for: $0.date) }
            .mapValues(\.count)
            .values
            .max() ?? 0
        if maxPerDay >= 10 {
            next.insert(AchievementID.tenCompletionsOneDay.rawValue)
        }

        unlockedAchievementIds = next
    }

    private func dailyBalanceCached(on day: Date) -> DailyBalance {
        let cal = Calendar.current
        let start = cal.startOfDay(for: day)
        let hotH = habits.filter { $0.type == .hot && !$0.isArchived }
        let coldH = habits.filter { $0.type == .cold && !$0.isArchived }
        let dayLogs = logs.filter { cal.isDate($0.date, inSameDayAs: start) }
        let hotC = dayLogs.filter { l in hotH.contains { $0.id == l.habitId } && l.completed }.count
        let coldC = dayLogs.filter { l in coldH.contains { $0.id == l.habitId } && l.completed }.count
        return DailyBalance(date: start, hotCompleted: hotC, coldCompleted: coldC, hotTotal: hotH.count, coldTotal: coldH.count)
    }

    // MARK: - Persistence

    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: habitsKey)
        }
        if let encoded = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(encoded, forKey: logsKey)
        }
        if let encoded = try? JSONEncoder().encode(streaks) {
            UserDefaults.standard.set(encoded, forKey: streaksKey)
        }
        if let encoded = try? JSONEncoder().encode(dayNotes) {
            UserDefaults.standard.set(encoded, forKey: dayNotesKey)
        }
        let ach = Array(unlockedAchievementIds)
        if let encoded = try? JSONEncoder().encode(ach) {
            UserDefaults.standard.set(encoded, forKey: achievementsKey)
        }
        let settings = PersistedSettings(
            maxHotLead: maxHotLeadBeforeWarning,
            maxColdLead: maxColdLeadBeforeWarning,
            habitSort: habitSort
        )
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }

    func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: habitsKey),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }
        if let data = UserDefaults.standard.data(forKey: logsKey),
           let decoded = try? JSONDecoder().decode([HabitLog].self, from: data) {
            logs = decoded
        }
        if let data = UserDefaults.standard.data(forKey: streaksKey),
           let decoded = try? JSONDecoder().decode([Streak].self, from: data) {
            streaks = decoded
        }
        if let data = UserDefaults.standard.data(forKey: dayNotesKey),
           let decoded = try? JSONDecoder().decode([DayNote].self, from: data) {
            dayNotes = decoded
        }
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            unlockedAchievementIds = Set(decoded)
        }
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let s = try? JSONDecoder().decode(PersistedSettings.self, from: data) {
            maxHotLeadBeforeWarning = s.maxHotLead
            maxColdLeadBeforeWarning = s.maxColdLead
            habitSort = s.habitSort
        }
        if habits.isEmpty {
            loadDemoData()
        }
        evaluateAchievements()
    }

    private func loadDemoData() {
        let habit1 = Habit(
            id: UUID(),
            name: "Morning run",
            category: .sport,
            type: .hot,
            targetDaysPerWeek: 3,
            reminderTime: nil,
            notes: nil,
            isActive: true,
            isFavorite: true,
            isArchived: false,
            tag: .coral,
            createdAt: Date()
        )
        let habit2 = Habit(
            id: UUID(),
            name: "Meditation",
            category: .meditation,
            type: .cold,
            targetDaysPerWeek: 5,
            reminderTime: nil,
            notes: nil,
            isActive: true,
            isFavorite: true,
            isArchived: false,
            tag: .sky,
            createdAt: Date()
        )
        habits = [habit1, habit2]

        let log1 = HabitLog(id: UUID(), habitId: habit1.id, habitName: habit1.name, date: Date(), completed: true, duration: nil, notes: nil)
        let log2 = HabitLog(id: UUID(), habitId: habit2.id, habitName: habit2.name, date: Date(), completed: false, duration: nil, notes: nil)
        logs = [log1, log2]
        saveToUserDefaults()
    }
}
