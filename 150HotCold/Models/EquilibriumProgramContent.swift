//
//  EquilibriumProgramContent.swift
//  150HotCold
//
//  Original curriculum: levels, rhythm modes, and in-app academy copy.
//

import Foundation

// MARK: - Rhythm modes

enum EquilibriumRhythmMode: String, CaseIterable, Identifiable, Codable {
    case freePlay = "Open tracking"
    case equilibriumPath = "Equilibrium Path"
    case recoveryBias = "Recovery bias"

    var id: String { rawValue }

    var shortBlurb: String {
        switch self {
        case .freePlay:
            return "Log habits freely. Path and Academy stay available as optional guides."
        case .equilibriumPath:
            return "Structured levels unlock as you prove hot/cold balance in the real data you log."
        case .recoveryBias:
            return "Daily nudges favor cold habits until your balance score leans cold again."
        }
    }
}

// MARK: - Level rules (evaluated in HotColdViewModel)

enum EquilibriumLevelCriterion: Equatable, Hashable {
    /// Some calendar day has at least this many completed hot and cold logs.
    case anyCalendarDayMinHotCold(hot: Int, cold: Int)
    /// From today backward: consecutive days where |balance| ≤ maxAbsBalance and each side has ≥ minEachSide completions.
    case consecutiveBalancedDays(count: Int, maxAbsBalance: Int, minEachSide: Int)
    /// Total completed logs (hot or cold) all-time.
    case lifetimeTotalCompletions(min: Int)
    /// Active, non-archived habits by type.
    case minActiveHabitsNonArchived(hot: Int, cold: Int)
    /// Last `dayCount` calendar days ending today: each day needs at least these completions per side.
    case consecutiveDaysMinEachType(hotMin: Int, coldMin: Int, dayCount: Int)
}

struct EquilibriumLevelDefinition: Identifiable, Equatable, Hashable {
    let id: String
    let order: Int
    let title: String
    let subtitle: String
    let story: String
    let ruleSummary: String
    let criterion: EquilibriumLevelCriterion
}

enum EquilibriumProgramCatalog {
    static let levels: [EquilibriumLevelDefinition] = [
        EquilibriumLevelDefinition(
            id: "lvl_spark_pair",
            order: 1,
            title: "Spark & still point",
            subtitle: "Prove you can move both energies",
            story: "Hot habits are output and focus. Cold habits are recovery and depth. The 150HotCold method starts by showing both on the same day — not perfection, just presence.",
            ruleSummary: "On one calendar day, complete at least 1 hot habit and 1 cold habit.",
            criterion: .anyCalendarDayMinHotCold(hot: 1, cold: 1)
        ),
        EquilibriumLevelDefinition(
            id: "lvl_twin_rails",
            order: 2,
            title: "Twin rails",
            subtitle: "Two balanced days in a row",
            story: "Balance is not always zero — it is staying inside a band so neither side hijacks the week. Here you tighten the rhythm across back-to-back days.",
            ruleSummary: "Two consecutive days (including today when applicable) with balance between −1 and +1, and at least one hot and one cold completion each of those days.",
            criterion: .consecutiveBalancedDays(count: 2, maxAbsBalance: 1, minEachSide: 1)
        ),
        EquilibriumLevelDefinition(
            id: "lvl_depth_twenty",
            order: 3,
            title: "Twenty reps",
            subtitle: "Volume builds memory",
            story: "Small repeats teach your nervous system what to expect. Twenty completed logs across any habits show you are past novelty and into practice.",
            ruleSummary: "Reach 20 lifetime completed habit logs in the app.",
            criterion: .lifetimeTotalCompletions(min: 20)
        ),
        EquilibriumLevelDefinition(
            id: "lvl_quartet_breadth",
            order: 4,
            title: "Quartet breadth",
            subtitle: "Design a fuller plate",
            story: "Two tracks on each side stop a single habit from carrying the whole story. Breadth spreads load and makes balance easier to tune day to day.",
            ruleSummary: "Keep at least 2 active hot habits and 2 active cold habits (not archived).",
            criterion: .minActiveHabitsNonArchived(hot: 2, cold: 2)
        ),
        EquilibriumLevelDefinition(
            id: "lvl_seven_strip",
            order: 5,
            title: "Seven-day strip",
            subtitle: "Daily hot and cold, no gaps",
            story: "The final level is a week-long ribbon: every day touches both temperatures. It is the signature 150HotCold endurance check before you graduate the Path.",
            ruleSummary: "Seven consecutive calendar days ending today: each day has at least 1 hot completion and 1 cold completion.",
            criterion: .consecutiveDaysMinEachType(hotMin: 1, coldMin: 1, dayCount: 7)
        )
    ]

    static func level(after id: String?) -> EquilibriumLevelDefinition? {
        guard let id else { return levels.first }
        guard let idx = levels.firstIndex(where: { $0.id == id }), idx + 1 < levels.count else { return nil }
        return levels[idx + 1]
    }

    static func definition(id: String) -> EquilibriumLevelDefinition? {
        levels.first { $0.id == id }
    }
}

// MARK: - Academy

struct AcademyLessonSection: Identifiable, Equatable, Hashable {
    let id: String
    let heading: String
    let body: String
}

struct AcademyLesson: Identifiable, Equatable, Hashable {
    let id: String
    let title: String
    let estMinutes: Int
    let sections: [AcademyLessonSection]
}

enum EquilibriumAcademyCatalog {
    static let lessons: [AcademyLesson] = [
        AcademyLesson(
            id: "academy_why_two_temperatures",
            title: "Why two temperatures?",
            estMinutes: 3,
            sections: [
                AcademyLessonSection(
                    id: "s1",
                    heading: "Metaphor, not weather",
                    body: "Hot is anything that spends focus, adrenaline, or social performance credits. Cold is anything that pays them back: sleep hygiene, slow breathing, unstructured time, or gentle movement."
                ),
                AcademyLessonSection(
                    id: "s2",
                    heading: "Why track both",
                    body: "Tracking only productivity rewards burnout. Tracking only rest ignores growth. 150HotCold keeps both visible so your week has a waveform, not a flat line."
                )
            ]
        ),
        AcademyLesson(
            id: "academy_balance_score",
            title: "Reading the balance score",
            estMinutes: 4,
            sections: [
                AcademyLessonSection(
                    id: "s1",
                    heading: "Simple math",
                    body: "Today’s score is hot completions minus cold completions. Positive means hot won the day; negative means cold did. Near zero means both sides spoke."
                ),
                AcademyLessonSection(
                    id: "s2",
                    heading: "Comfort bands",
                    body: "In Settings-derived warnings (Home → Balance goals), you set how far from zero feels uncomfortable. That is personal: athletes tolerate wider hot leads; recovery seasons tighten the band."
                )
            ]
        ),
        AcademyLesson(
            id: "academy_designing_pairs",
            title: "Designing habit pairs",
            estMinutes: 5,
            sections: [
                AcademyLessonSection(
                    id: "s1",
                    heading: "Pair hot with cold",
                    body: "After a hot block (deep work, hard training), schedule a cold anchor within two hours: walk, shower ritual, journaling, or breathwork. Pairs teach closure."
                ),
                AcademyLessonSection(
                    id: "s2",
                    heading: "Micro cold wins",
                    body: "Cold does not require an hour. Three minutes of silence still counts as cold depth if it is intentional — log it honestly."
                )
            ]
        ),
        AcademyLesson(
            id: "academy_week_review",
            title: "Weekly review ritual",
            estMinutes: 4,
            sections: [
                AcademyLessonSection(
                    id: "s1",
                    heading: "Friday five minutes",
                    body: "Open Statistics and History. Ask: which day was most lopsided? Was it planned (sprint week) or accidental drift? Adjust next week’s habit roster, not your self-worth."
                ),
                AcademyLessonSection(
                    id: "s2",
                    heading: "Archive honestly",
                    body: "If a habit never fires, archive it and replace it with something smaller. Empty checklists teach nothing."
                )
            ]
        ),
        AcademyLesson(
            id: "academy_recovery_bias_mode",
            title: "When to use Recovery bias",
            estMinutes: 3,
            sections: [
                AcademyLessonSection(
                    id: "s1",
                    heading: "Signal, not shame",
                    body: "Recovery bias mode nudges copy toward cold completions when your score stays hot-heavy. It is for seasons of injury, grief, post-launch fatigue, or travel recovery — not permanent use."
                ),
                AcademyLessonSection(
                    id: "s2",
                    heading: "Exit criteria",
                    body: "Return to Open tracking or Equilibrium Path once cold logs feel natural again for several days in a row."
                )
            ]
        ),
        AcademyLesson(
            id: "academy_graduation",
            title: "Graduating your own rules",
            estMinutes: 3,
            sections: [
                AcademyLessonSection(
                    id: "s1",
                    heading: "After the Path",
                    body: "Finishing all five levels proves you can operate both energies across time. The app becomes a dashboard; the intelligence moves into your calendar and environment."
                ),
                AcademyLessonSection(
                    id: "s2",
                    heading: "Teach someone else",
                    body: "Explain hot/cold balance to a friend in one minute. If you can, you have internalized the method better than any badge."
                )
            ]
        )
    ]
}
