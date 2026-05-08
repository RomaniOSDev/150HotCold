//
//  StatCard.swift
//  150HotCold
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.65)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: color.opacity(0.45), radius: 6, y: 2)
                Text(title)
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            Text(value)
                .foregroundColor(.white)
                .font(.title2)
                .bold()
                .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
        }
        .padding()
        .frame(minWidth: 140, alignment: .leading)
        .hcElevatedCard(cornerRadius: 14, accent: color)
    }
}
