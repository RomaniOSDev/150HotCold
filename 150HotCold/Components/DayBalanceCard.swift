//
//  DayBalanceCard.swift
//  150HotCold
//

import SwiftUI

struct DayBalanceCard: View {
    let balance: DailyBalance
    let dayNote: String?

    private var accent: Color {
        balance.isBalanced ? Color.hcCold : Color.hcHot
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(formattedDate(balance.date))
                    .font(.headline)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)

                Spacer()

                Text(balance.isBalanced ? "✨ BALANCED" : "⚠️ IMBALANCED")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        accent.opacity(0.35),
                                        accent.opacity(0.12)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        Capsule()
                            .stroke(accent.opacity(0.45), lineWidth: 1)
                    )
                    .foregroundColor(accent)
            }

            HStack {
                Label("Hot: \(balance.hotCompleted)/\(balance.hotTotal)", systemImage: "flame.fill")
                    .font(.caption)
                    .foregroundStyle(
                        LinearGradient(colors: [.hcHot, .hcHot.opacity(0.75)], startPoint: .leading, endPoint: .trailing)
                    )

                Spacer()

                Label("Cold: \(balance.coldCompleted)/\(balance.coldTotal)", systemImage: "snowflake")
                    .font(.caption)
                    .foregroundStyle(
                        LinearGradient(colors: [.hcCold, .hcCold.opacity(0.75)], startPoint: .leading, endPoint: .trailing)
                    )
            }

            let totalDone = balance.hotCompleted + balance.coldCompleted
            let totalPlanned = max(balance.hotTotal + balance.coldTotal, 1)
            ProgressView(value: Double(totalDone) / Double(totalPlanned))
                .tint(balance.isBalanced ? .hcCold : .hcHot)

            if let note = dayNote, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.95))
                    .padding(.top, 4)
            }
        }
        .padding()
        .hcElevatedCard(cornerRadius: 16, accent: accent)
    }
}
