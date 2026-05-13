//
//  HabitModels.swift
//  150HotCold
//

import SwiftUI

enum TagFilterMode: String, CaseIterable, Identifiable, Codable {
    case all = "All tags"
    case untagged = "No tag"
    case coral = "Coral"
    case sky = "Sky"
    case lime = "Lime"
    case violet = "Violet"
    case amber = "Amber"

    var id: String { rawValue }

    var habitTag: HabitTag? {
        switch self {
        case .all: return nil
        case .untagged: return HabitTag.none
        case .coral: return .coral
        case .sky: return .sky
        case .lime: return .lime
        case .violet: return .violet
        case .amber: return .amber
        }
    }
}

enum HabitType: String, CaseIterable, Codable {
    case hot = "Hot"
    case cold = "Cold"

    var color: Color {
        switch self {
        case .hot: return .hcHot
        case .cold: return .hcCold
        }
    }

    var icon: String {
        switch self {
        case .hot: return "flame.fill"
        case .cold: return "snowflake"
        }
    }
}

enum HabitCategory: String, CaseIterable, Codable {
    case sport = "Sport"
    case work = "Work"
    case study = "Study"
    case earlyRise = "Early Rise"
    case productivity = "Productivity"

    case meditation = "Meditation"
    case reading = "Reading"
    case walk = "Walk"
    case rest = "Rest"
    case selfCare = "Self-care"

    var type: HabitType {
        switch self {
        case .sport, .work, .study, .earlyRise, .productivity:
            return .hot
        case .meditation, .reading, .walk, .rest, .selfCare:
            return .cold
        }
    }

    var icon: String {
        switch self {
        case .sport: return "figure.run"
        case .work: return "briefcase.fill"
        case .study: return "book.fill"
        case .earlyRise: return "sunrise.fill"
        case .productivity: return "checklist"
        case .meditation: return "moon.stars.fill"
        case .reading: return "book.closed"
        case .walk: return "figure.walk"
        case .rest: return "bed.double.fill"
        case .selfCare: return "sparkles"
        }
    }
}

/// Color tag for filtering and quick visual grouping (not the hot/cold type color).
enum HabitTag: String, CaseIterable, Codable, Identifiable {
    case none = "None"
    case coral = "Coral"
    case sky = "Sky"
    case lime = "Lime"
    case violet = "Violet"
    case amber = "Amber"

    var id: String { rawValue }

    var swatch: Color {
        switch self {
        case .none: return Color.gray.opacity(0.35)
        case .coral: return Color(red: 0.95, green: 0.35, blue: 0.32)
        case .sky: return Color(red: 0.35, green: 0.65, blue: 0.95)
        case .lime: return Color(red: 0.45, green: 0.85, blue: 0.4)
        case .violet: return Color(red: 0.62, green: 0.45, blue: 0.95)
        case .amber: return Color(red: 0.95, green: 0.75, blue: 0.25)
        }
    }
}

struct Habit: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var category: HabitCategory
    var type: HabitType
    var targetDaysPerWeek: Int
    var reminderTime: Date?
    var notes: String?
    var isActive: Bool
    var isFavorite: Bool
    var isArchived: Bool
    var tag: HabitTag
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, category, type, targetDaysPerWeek, reminderTime, notes, isActive, isFavorite, createdAt
        case isArchived, tag
    }

    init(
        id: UUID,
        name: String,
        category: HabitCategory,
        type: HabitType,
        targetDaysPerWeek: Int,
        reminderTime: Date?,
        notes: String?,
        isActive: Bool,
        isFavorite: Bool,
        isArchived: Bool = false,
        tag: HabitTag = .none,
        createdAt: Date
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.type = type
        self.targetDaysPerWeek = targetDaysPerWeek
        self.reminderTime = reminderTime
        self.notes = notes
        self.isActive = isActive
        self.isFavorite = isFavorite
        self.isArchived = isArchived
        self.tag = tag
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        category = try c.decode(HabitCategory.self, forKey: .category)
        type = try c.decode(HabitType.self, forKey: .type)
        targetDaysPerWeek = try c.decode(Int.self, forKey: .targetDaysPerWeek)
        reminderTime = try c.decodeIfPresent(Date.self, forKey: .reminderTime)
        notes = try c.decodeIfPresent(String.self, forKey: .notes)
        isActive = try c.decode(Bool.self, forKey: .isActive)
        isFavorite = try c.decode(Bool.self, forKey: .isFavorite)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        isArchived = try c.decodeIfPresent(Bool.self, forKey: .isArchived) ?? false
        tag = try c.decodeIfPresent(HabitTag.self, forKey: .tag) ?? .none
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(category, forKey: .category)
        try c.encode(type, forKey: .type)
        try c.encode(targetDaysPerWeek, forKey: .targetDaysPerWeek)
        try c.encodeIfPresent(reminderTime, forKey: .reminderTime)
        try c.encodeIfPresent(notes, forKey: .notes)
        try c.encode(isActive, forKey: .isActive)
        try c.encode(isFavorite, forKey: .isFavorite)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(isArchived, forKey: .isArchived)
        try c.encode(tag, forKey: .tag)
    }
}

struct HabitLog: Identifiable, Codable, Equatable {
    let id: UUID
    let habitId: UUID
    let habitName: String
    let date: Date
    var completed: Bool
    var duration: Int?
    var notes: String?
}

struct DailyBalance: Identifiable, Codable, Equatable {
    var id: Date { date }
    let date: Date
    var hotCompleted: Int
    var coldCompleted: Int
    var hotTotal: Int
    var coldTotal: Int

    var balanceScore: Int {
        hotCompleted - coldCompleted
    }

    var isBalanced: Bool {
        abs(balanceScore) <= 1
    }
}

struct Streak: Identifiable, Codable, Equatable {
    let id: UUID
    let habitId: UUID
    var currentStreak: Int
    var bestStreak: Int
    var lastCompletedDate: Date?
}

struct DayNote: Identifiable, Codable, Equatable {
    var id: TimeInterval { dayStart }
    /// `Calendar.startOfDay` as `timeIntervalSince1970`
    var dayStart: TimeInterval
    var text: String
}

enum HabitSort: String, CaseIterable, Identifiable, Codable {
    case favoritesFirst = "Favorites first"
    case nameAZ = "Name A–Z"
    case hotTypeFirst = "Hot first"
    case coldTypeFirst = "Cold first"

    var id: String { rawValue }
}

enum AchievementID: String, CaseIterable, Codable {
    case firstHabit = "first_habit"
    case firstCompletion = "first_completion"
    case balancedWeek = "balanced_week"
    case coldCompletions30 = "cold_30"
    case hotCompletions30 = "hot_30"
    case habitBestStreak14 = "habit_streak_14"
    case usageStreak7 = "usage_streak_7"
    case tenHabits = "ten_habits"
    case tenCompletionsOneDay = "ten_one_day"
    case pathMilestone2 = "path_milestone_2"
    case pathMilestone4 = "path_milestone_4"
    case pathComplete = "path_complete"
    case academyReader = "academy_reader"
    case academyGraduate = "academy_graduate"

    var title: String {
        switch self {
        case .firstHabit: return "Getting started"
        case .firstCompletion: return "First step"
        case .balancedWeek: return "Balanced week"
        case .coldCompletions30: return "Cold depth"
        case .hotCompletions30: return "Hot drive"
        case .habitBestStreak14: return "Consistency"
        case .usageStreak7: return "Week of focus"
        case .tenHabits: return "Collector"
        case .tenCompletionsOneDay: return "Power day"
        case .pathMilestone2: return "Path · twin rails"
        case .pathMilestone4: return "Path · quartet"
        case .pathComplete: return "Path · seven strip"
        case .academyReader: return "Academy reader"
        case .academyGraduate: return "Academy graduate"
        }
    }

    var detail: String {
        switch self {
        case .firstHabit: return "Create your first habit."
        case .firstCompletion: return "Complete any habit once."
        case .balancedWeek: return "7 days in a row with a balanced day score."
        case .coldCompletions30: return "30 completed cold habit logs."
        case .hotCompletions30: return "30 completed hot habit logs."
        case .habitBestStreak14: return "Reach a 14-day best streak on one habit."
        case .usageStreak7: return "7-day activity streak (half+ habits done)."
        case .tenHabits: return "Have 10 habits in the app (any state)."
        case .tenCompletionsOneDay: return "Complete 10 habits in a single day."
        case .pathMilestone2: return "Finish the first two Equilibrium Path levels."
        case .pathMilestone4: return "Finish the first four Equilibrium Path levels."
        case .pathComplete: return "Finish all five Equilibrium Path levels."
        case .academyReader: return "Read three Academy lessons to the end."
        case .academyGraduate: return "Read every Academy lesson."
        }
    }

    var icon: String {
        switch self {
        case .firstHabit: return "star.fill"
        case .firstCompletion: return "checkmark.circle.fill"
        case .balancedWeek: return "calendar"
        case .coldCompletions30: return "snowflake"
        case .hotCompletions30: return "flame.fill"
        case .habitBestStreak14: return "bolt.fill"
        case .usageStreak7: return "flame.circle.fill"
        case .tenHabits: return "square.grid.3x3.fill"
        case .tenCompletionsOneDay: return "sparkles"
        case .pathMilestone2: return "point.3.connected.trianglepath.dotted"
        case .pathMilestone4: return "square.grid.2x2.fill"
        case .pathComplete: return "seal.fill"
        case .academyReader: return "book.fill"
        case .academyGraduate: return "graduationcap.fill"
        }
    }
}

struct HotColdStat {
    var totalHotHabits: Int
    var totalColdHabits: Int
    var hotCompletionRate: Double
    var coldCompletionRate: Double
    var currentBalance: Int
    var bestBalanceDay: Date?
    var weeklyScore: Int
}
