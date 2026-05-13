//
//  SaveService.swift
//  150HotCold
//

import Foundation

struct HCDefaultsURLRelay {
    static var lastUrl: URL? {
        get { UserDefaults.standard.url(forKey: HCRouterStringVault.udLastUrlKey) }
        set { UserDefaults.standard.set(newValue, forKey: HCRouterStringVault.udLastUrlKey) }
    }
}
