//
//  OnboardingView.swift
//  150HotCold
//

import SwiftUI

/// Persisted when the user finishes or skips onboarding.
enum HCOnboardingStorage {
    static let completedKey = "hotcold_onboarding_completed"
}

struct OnboardingView: View {
    @Binding var isComplete: Bool
    @State private var page = 0

    var body: some View {
        ZStack {
            HCDeepBackdrop()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("Skip") {
                        finish()
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white.opacity(0.75))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                }
                .padding(.top, 8)

                TabView(selection: $page) {
                    onboardingPage(
                        title: "Two kinds of energy",
                        message: "Mark habits as Hot when they fire you up, or Cold when they help you slow down and recover. Both matter.",
                        content: { page1Visual }
                    )
                    .tag(0)

                    onboardingPage(
                        title: "Keep an eye on balance",
                        message: "The Balance tab shows how today’s completions line up. Home gives you a quick snapshot so nothing drifts too far.",
                        content: { page2Visual }
                    )
                    .tag(1)

                    onboardingPage(
                        title: "See how far you’ve come",
                        message: "Statistics chart your rhythm, History lists every day, and Awards celebrate streaks and milestones.",
                        content: { page3Visual }
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                VStack(spacing: 12) {
                    if page < 2 {
                        Button("Next") {
                            withAnimation(.easeInOut(duration: 0.28)) {
                                page += 1
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .buttonStyle(HCGradientButtonStyle(
                            colors: [Color.hcHot.opacity(0.75), Color.hcHot.opacity(0.32)],
                            shadowColor: .hcHot
                        ))
                    } else {
                        Button("Get started") {
                            finish()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .buttonStyle(HCGradientButtonStyle(
                            colors: [Color.hcCold.opacity(0.55), Color.hcHot.opacity(0.45)],
                            shadowColor: .hcCold
                        ))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
                .padding(.top, 8)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func finish() {
        HapticFeedback.success()
        isComplete = true
    }

    // MARK: - Pages

    private func onboardingPage<Content: View>(
        title: String,
        message: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        VStack(spacing: 28) {
            content()
                .frame(height: 200)

            VStack(spacing: 14) {
                Text(title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.35), radius: 2, y: 1)

                Text(message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(22)
            .frame(maxWidth: .infinity)
            .hcElevatedCard(cornerRadius: 22, accent: Color.hcHot.opacity(0.35))
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 16)
    }

    private var page1Visual: some View {
        HStack(spacing: 36) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.hcHot.opacity(0.55), Color.hcHot.opacity(0.08)],
                            center: .center,
                            startRadius: 8,
                            endRadius: 56
                        )
                    )
                    .frame(width: 112, height: 112)
                    .shadow(color: Color.hcHot.opacity(0.45), radius: 20, y: 8)
                Image(systemName: "flame.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.hcHot, Color.orange.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.hcCold.opacity(0.5), Color.hcCold.opacity(0.08)],
                            center: .center,
                            startRadius: 8,
                            endRadius: 56
                        )
                    )
                    .frame(width: 112, height: 112)
                    .shadow(color: Color.hcCold.opacity(0.4), radius: 18, y: 8)
                Image(systemName: "snowflake")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.hcCold, Color.cyan.opacity(0.75)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
    }

    private var page2Visual: some View {
        ZStack {
            Image(systemName: "scalemass.fill")
                .font(.system(size: 72))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.hcHot.opacity(0.9), Color.hcCold.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.hcHot.opacity(0.25), radius: 24, y: 10)
                .shadow(color: Color.hcCold.opacity(0.2), radius: 18, y: 6)

            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.35), Color.white.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 2
                )
                .frame(width: 168, height: 168)
        }
    }

    private var page3Visual: some View {
        HStack(spacing: 20) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 36))
                .foregroundStyle(
                    LinearGradient(colors: [Color.hcHot, Color.hcHot.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                )
                .shadow(color: Color.hcHot.opacity(0.35), radius: 8, y: 4)
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 36))
                .foregroundColor(.white.opacity(0.85))
                .shadow(color: .black.opacity(0.4), radius: 6, y: 3)
            Image(systemName: "trophy.fill")
                .font(.system(size: 36))
                .foregroundStyle(
                    LinearGradient(colors: [Color.yellow.opacity(0.95), Color.orange.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .shadow(color: Color.orange.opacity(0.35), radius: 10, y: 4)
        }
    }
}

#Preview {
    OnboardingView(isComplete: .constant(false))
}
