//
//  ProgramHubView.swift
//  150HotCold
//

import SwiftUI

struct ProgramHubView: View {
    @ObservedObject var viewModel: HotColdViewModel
    @State private var selectedLesson: AcademyLesson?
    @State private var expandedLevel: EquilibriumLevelDefinition?

    private var rowBackground: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color.white.opacity(0.1), Color.white.opacity(0.04)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                HCDeepBackdrop()

                List {
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Rhythm mode")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                            Picker("Mode", selection: Binding(
                                get: { viewModel.rhythmMode },
                                set: { viewModel.setRhythmMode($0) }
                            )) {
                                ForEach(EquilibriumRhythmMode.allCases) { mode in
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)

                            Text(viewModel.rhythmMode.shortBlurb)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.82))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.vertical, 6)
                        .listRowBackground(rowBackground)
                    } header: {
                        Text("How you want to train")
                            .foregroundColor(.gray)
                    }

                    Section {
                        if viewModel.rhythmMode != .equilibriumPath {
                            Text("Turn on Equilibrium Path mode to treat the levels below as your primary progression.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .listRowBackground(Color.clear)
                        }

                        ForEach(viewModel.sortedEquilibriumLevels) { level in
                            levelRow(level)
                                .listRowInsets(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                    } header: {
                        HStack {
                            Text("Equilibrium Path")
                                .foregroundColor(.hcHot)
                            Spacer()
                            Text("\(viewModel.sortedEquilibriumLevels.filter { viewModel.isEquilibriumLevelComplete($0.id) }.count)/\(viewModel.sortedEquilibriumLevels.count)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    Section {
                        HStack {
                            Image(systemName: "book.pages.fill")
                                .foregroundStyle(
                                    LinearGradient(colors: [.hcCold, .cyan.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                            Text("Six original lessons explain the 150HotCold method: balance score, pairing habits, weekly review, modes, and graduation.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Spacer(minLength: 0)
                        }
                        .listRowBackground(Color.clear)

                        ForEach(EquilibriumAcademyCatalog.lessons) { lesson in
                            Button {
                                selectedLesson = lesson
                            } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: viewModel.readAcademyLessonIds.contains(lesson.id) ? "checkmark.circle.fill" : "circle")
                                        .font(.title3)
                                        .foregroundColor(viewModel.readAcademyLessonIds.contains(lesson.id) ? .hcCold : .gray.opacity(0.5))

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(lesson.title)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.leading)
                                        Text("~\(lesson.estMinutes) min read")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(.gray.opacity(0.55))
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                            .listRowInsets(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14))
                            .listRowBackground(rowBackground)
                            .listRowSeparator(.hidden)
                        }
                    } header: {
                        HStack {
                            Text("Academy")
                                .foregroundColor(.hcCold)
                            Spacer()
                            Text("\(viewModel.academyReadCounts.done)/\(viewModel.academyReadCounts.total) read")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Program")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.hcBackground.opacity(0.001), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(item: $selectedLesson) { lesson in
                NavigationStack {
                    AcademyLessonDetailView(lesson: lesson, viewModel: viewModel)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Done") {
                                    selectedLesson = nil
                                }
                                .fontWeight(.semibold)
                            }
                        }
                }
            }
            .sheet(item: $expandedLevel) { level in
                EquilibriumLevelDetailSheet(level: level, viewModel: viewModel)
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func levelRow(_ level: EquilibriumLevelDefinition) -> some View {
        let unlocked = viewModel.isEquilibriumLevelUnlocked(level)
        let done = viewModel.isEquilibriumLevelComplete(level.id)
        let metNow = viewModel.equilibriumLevelGoalMetNow(level)

        Button {
            if unlocked {
                expandedLevel = level
            }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    if !unlocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray.opacity(0.55))
                    } else if done {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(
                                LinearGradient(colors: [.hcHot, .yellow.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                    } else {
                        Image(systemName: metNow ? "target" : "circle.dashed")
                            .foregroundColor(metNow ? .hcCold : .gray.opacity(0.6))
                    }
                }
                .font(.title2)
                .frame(width: 36, alignment: .center)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Level \(level.order)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.hcHot.opacity(0.9))
                    Text(level.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    Text(level.subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                if unlocked {
                    Image(systemName: "info.circle")
                        .font(.body)
                        .foregroundColor(.gray.opacity(0.65))
                }
            }
            .padding(14)
            .background(rowBackground)
        }
        .buttonStyle(.plain)
        .disabled(!unlocked)
        .opacity(unlocked ? 1 : 0.55)
    }
}

// MARK: - Lesson detail

private struct AcademyLessonDetailView: View {
    let lesson: AcademyLesson
    @ObservedObject var viewModel: HotColdViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("About \(lesson.estMinutes) minutes")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                ForEach(lesson.sections) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.heading)
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                        Text(section.body)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.88))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .hcElevatedCard(cornerRadius: 18, accent: Color.hcCold.opacity(0.35))
                }
            }
            .padding(16)
            .padding(.bottom, 32)
        }
        .background(HCDeepBackdrop())
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.markAcademyLessonRead(lesson.id)
        }
    }
}

// MARK: - Level sheet

private struct EquilibriumLevelDetailSheet: View {
    let level: EquilibriumLevelDefinition
    @ObservedObject var viewModel: HotColdViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                HCDeepBackdrop()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text(level.subtitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.hcHot)

                        Text(level.story)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)

                        VStack(alignment: .leading, spacing: 8) {
                            Label("Success rule", systemImage: "list.bullet.clipboard.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.hcCold)
                            Text(level.ruleSummary)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.88))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white.opacity(0.06))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.hcCold.opacity(0.28), lineWidth: 1)
                        )

                        statusBanner
                    }
                    .padding(20)
                    .padding(.bottom, 28)
                }
            }
            .navigationTitle("Level \(level.order)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private var statusBanner: some View {
        let done = viewModel.isEquilibriumLevelComplete(level.id)
        let met = viewModel.equilibriumLevelGoalMetNow(level)
        let priorOk = priorLevelsSatisfied

        if done {
            Label("Level cleared — progress is saved forever.", systemImage: "checkmark.seal.fill")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.hcHot)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.hcHot.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        } else if !priorOk {
            Label("Finish earlier Path levels first — unlock order stays strict so the curriculum builds real skill.", systemImage: "lock.rectangle.stack.fill")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.gray)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        } else if met {
            Label("Requirement met — this level stamps automatically on the next refresh.", systemImage: "sparkles")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.hcCold)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.hcCold.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        } else {
            Label("Keep logging — the checklist reads only real completions.", systemImage: "chart.line.uptrend.xyaxis")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.gray)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private var priorLevelsSatisfied: Bool {
        let sorted = viewModel.sortedEquilibriumLevels
        guard let idx = sorted.firstIndex(where: { $0.id == level.id }) else { return true }
        if idx == 0 { return true }
        return sorted[..<idx].allSatisfy { viewModel.isEquilibriumLevelComplete($0.id) }
    }
}

#Preview {
    ProgramHubView(viewModel: HotColdViewModel())
}
