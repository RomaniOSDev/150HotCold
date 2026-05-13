//
//  PersistenceManager.swift
//  150HotCold
//

import Foundation

final class HCLaunchStateVault {
    static let shared = HCLaunchStateVault()

    var savedUrl: String? {
        get {
            if let url = HCDefaultsURLRelay.lastUrl {
                return url.absoluteString
            }
            return UserDefaults.standard.string(forKey: HCRouterStringVault.udLastUrlKey)
        }
        set {
            if let urlString = newValue {
                UserDefaults.standard.set(urlString, forKey: HCRouterStringVault.udLastUrlKey)
                if let url = URL(string: urlString) {
                    HCDefaultsURLRelay.lastUrl = url
                }
            } else {
                UserDefaults.standard.removeObject(forKey: HCRouterStringVault.udLastUrlKey)
                HCDefaultsURLRelay.lastUrl = nil
            }
        }
    }

    var hasShownContentView: Bool {
        get {
            UserDefaults.standard.bool(forKey: HCRouterStringVault.udHasShownContentViewKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: HCRouterStringVault.udHasShownContentViewKey)
        }
    }

    var hasSuccessfulWebViewLoad: Bool {
        get {
            UserDefaults.standard.bool(forKey: HCRouterStringVault.udHasSuccessfulWebViewLoadKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: HCRouterStringVault.udHasSuccessfulWebViewLoadKey)
        }
    }

    private init() {}
}
