//
//  SaveService.swift
//  101RoastLog
//
//  Created by Ethit Hu on 19.03.2026.
//

import Foundation

struct SaveService {
    
    static var lastUrl: URL? {
        get { UserDefaults.standard.url(forKey: "LastUrl") }
        set { UserDefaults.standard.set(newValue, forKey: "LastUrl") }
    }
}
