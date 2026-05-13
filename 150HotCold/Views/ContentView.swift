//
//  ContentView.swift
//  150HotCold
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = HotColdViewModel()
    @State private var selectedTab = 0
    @AppStorage(HCOnboardingStorage.completedKey) private var onboardingCompleted = false

    var body: some View {
        Group {
            if onboardingCompleted {
                mainTabs
            } else {
                OnboardingView(isComplete: $onboardingCompleted)
            }
        }
    }

    private var mainTabs: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: viewModel, selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            BalanceView(viewModel: viewModel)
                .tabItem {
                    Label("Balance", systemImage: "scalemass.fill")
                }
                .tag(1)

            StatsView(viewModel: viewModel)
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
                .tag(2)

            HistoryView(viewModel: viewModel)
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(3)

            AchievementsView(viewModel: viewModel)
                .tabItem {
                    Label("Awards", systemImage: "trophy.fill")
                }
                .tag(4)

            ProgramHubView(viewModel: viewModel)
                .tabItem {
                    Label("Program", systemImage: "book.pages.fill")
                }
                .tag(5)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(6)
        }
        .tint(.hcHot)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
