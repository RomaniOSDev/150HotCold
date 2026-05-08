//
//  SettingsView.swift
//  150HotCold
//

import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                HCDeepBackdrop()

                List {
                    Section {
                        settingsRow(
                            title: "Rate us",
                            systemImage: "star.fill",
                            tint: .yellow
                        ) {
                            rateApp()
                        }

                        settingsRow(
                            title: "Privacy Policy",
                            systemImage: "hand.raised.fill",
                            tint: .hcCold
                        ) {
                            openPrivacyPolicy()
                        }

                        settingsRow(
                            title: "Terms of Use",
                            systemImage: "doc.text.fill",
                            tint: .white.opacity(0.85)
                        ) {
                            openTermsOfUse()
                        }
                    } header: {
                        Text("Support")
                            .foregroundColor(.gray)
                    }
                    .listRowBackground(rowBackground)
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

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

    private func settingsRow(
        title: String,
        systemImage: String,
        tint: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [tint, tint.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 28, alignment: .center)
                Text(title)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.gray.opacity(0.6))
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private func openPrivacyPolicy() {
        if let url = URL(string: HCExternalLinks.privacyPolicy) {
            UIApplication.shared.open(url)
        }
    }

    private func openTermsOfUse() {
        if let url = URL(string: HCExternalLinks.termsOfUse) {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

#Preview {
    SettingsView()
}
