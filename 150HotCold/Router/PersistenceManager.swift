//
//  PersistenceManager.swift
//  101RoastLog
//
//  Created by Ethit Hu on 19.03.2026.
//

import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    
    private let savedUrlKey = "LastUrl"
    private let hasShownContentViewKey = "HasShownContentView"
    private let hasSuccessfulWebViewLoadKey = "HasSuccessfulWebViewLoad"
    
    var savedUrl: String? {
        get {
            // Синхронизация с SaveService для обратной совместимости
            if let url = SaveService.lastUrl {
                return url.absoluteString
            }
            return UserDefaults.standard.string(forKey: savedUrlKey)
        }
        set {
            if let urlString = newValue {
                print("💾 [LastUrl] WRITE UserDefaults key=\(savedUrlKey) url=\(urlString)")
                UserDefaults.standard.set(urlString, forKey: savedUrlKey)
                // Синхронизация с SaveService
                if let url = URL(string: urlString) {
                    SaveService.lastUrl = url
                    print("💾 [LastUrl] SYNC SaveService (URL) = \(url.absoluteString)")
                } else {
                    print("⚠️ [LastUrl] SKIP SaveService sync — invalid URL string")
                }
            } else {
                print("💾 [LastUrl] CLEAR UserDefaults key=\(savedUrlKey) + SaveService")
                UserDefaults.standard.removeObject(forKey: savedUrlKey)
                SaveService.lastUrl = nil
            }
        }
    }
    
    var hasShownContentView: Bool {
        get {
            UserDefaults.standard.bool(forKey: hasShownContentViewKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasShownContentViewKey)
        }
    }
    
    var hasSuccessfulWebViewLoad: Bool {
        get {
            UserDefaults.standard.bool(forKey: hasSuccessfulWebViewLoadKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasSuccessfulWebViewLoadKey)
        }
    }
    
    private init() {}
}
