//
//  AchievementsView.swift
//  150HotCold
//

import SwiftUI

/// Dedicated awards list (always lays out; avoids ScrollView + grid sizing bugs).
struct AchievementsView: View {
    @ObservedObject var viewModel: HotColdViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                HCDeepBackdrop()

                List {
                    Section {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "trophy.fill")
                                .font(.title)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.hcHot, Color.orange.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: .hcHot.opacity(0.45), radius: 8, y: 3)
                            Text("Track milestones as you log hot and cold habits.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }

                    Section {
                        ForEach(Array(AchievementID.allCases), id: \.rawValue) { aid in
                            achievementRow(
                                id: aid,
                                unlocked: viewModel.unlockedAchievementIds.contains(aid.rawValue)
                            )
                            .listRowInsets(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    } header: {
                        Text("All badges")
                            .foregroundColor(.hcHot)
                            .font(.headline)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Awards")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.hcBackground.opacity(0.001), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func achievementRow(id: AchievementID, unlocked: Bool) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: id.icon)
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: unlocked
                            ? [Color.hcHot, Color.orange.opacity(0.85)]
                            : [Color.gray.opacity(0.65), Color.gray.opacity(0.35)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: unlocked ? Color.hcHot.opacity(0.35) : .clear, radius: 6, y: 2)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(id.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: unlocked ? "checkmark.seal.fill" : "lock.fill")
                        .foregroundStyle(
                            LinearGradient(
                                colors: unlocked
                                    ? [.hcCold, .hcCold.opacity(0.75)]
                                    : [.gray.opacity(0.65), .gray.opacity(0.4)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                Text(id.detail)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .hcElevatedCard(cornerRadius: 16, accent: unlocked ? .hcHot : Color.gray.opacity(0.65))
    }
}
