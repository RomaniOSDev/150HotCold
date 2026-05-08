//
//  HistoryView.swift
//  150HotCold
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: HotColdViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                HCDeepBackdrop()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("History")
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

                        LazyVStack(spacing: 14) {
                            if viewModel.dailyBalances.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "calendar.badge.clock")
                                        .font(.system(size: 44))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.gray.opacity(0.6), .gray.opacity(0.3)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                    Text("No history yet. Log habits from the Balance tab.")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(24)
                                .hcElevatedCard(cornerRadius: 18, accent: Color.gray.opacity(0.7))
                            } else {
                                ForEach(viewModel.dailyBalances) { balance in
                                    DayBalanceCard(
                                        balance: balance,
                                        dayNote: viewModel.dayNote(for: balance.date)
                                    )
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
            }
        }
    }
}
