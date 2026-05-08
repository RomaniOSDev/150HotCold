//
//  HCVisualStyle.swift
//  150HotCold
//

import SwiftUI

// MARK: - Screen backdrop

/// Full-screen depth: base gradient + soft hot/cold glow orbs.
struct HCDeepBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.075, blue: 0.11),
                    Color.hcBackground,
                    Color(red: 0.03, green: 0.04, blue: 0.07)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [Color.white.opacity(0.06), Color.clear],
                center: UnitPoint(x: 0.15, y: 0.1),
                startRadius: 20,
                endRadius: 420
            )

            Circle()
                .fill(Color.hcHot.opacity(0.16))
                .frame(width: 340, height: 340)
                .blur(radius: 75)
                .offset(x: 140, y: -260)

            Circle()
                .fill(Color.hcCold.opacity(0.12))
                .frame(width: 300, height: 300)
                .blur(radius: 68)
                .offset(x: -160, y: 420)

            Circle()
                .fill(Color.hcHot.opacity(0.06))
                .frame(width: 180, height: 180)
                .blur(radius: 40)
                .offset(x: -80, y: -120)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Elevated card (volume + gradient + shadow)

struct HCElevatedCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 14
    var accent: Color?

    func body(content: Content) -> some View {
        let strokeAccent = accent ?? Color.white.opacity(0.12)
        return content
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.12, green: 0.14, blue: 0.19),
                                    Color(red: 0.06, green: 0.07, blue: 0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.14), Color.clear],
                                startPoint: .top,
                                endPoint: UnitPoint(x: 0.5, y: 0.42)
                            )
                        )
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.28),
                                strokeAccent.opacity(0.35),
                                Color.black.opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: Color.black.opacity(0.48), radius: 16, x: 0, y: 10)
            .shadow(color: (accent ?? Color.hcHot).opacity(0.14), radius: 22, x: 0, y: 4)
    }
}

// MARK: - Gradient CTA button

struct HCGradientButtonStyle: ButtonStyle {
    var colors: [Color]
    var shadowColor: Color = .black

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: shadowColor.opacity(0.45), radius: 12, x: 0, y: 6)
    }
}

extension View {
    func hcElevatedCard(cornerRadius: CGFloat = 14, accent: Color? = nil) -> some View {
        modifier(HCElevatedCardModifier(cornerRadius: cornerRadius, accent: accent))
    }

    /// Softer inset panel (filters, secondary blocks).
    func hcSoftInset(cornerRadius: CGFloat = 12) -> some View {
        self
            .padding()
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.09),
                                Color.white.opacity(0.03)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.18), Color.black.opacity(0.35)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.32), radius: 10, x: 0, y: 5)
    }
}
