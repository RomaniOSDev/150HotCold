//
//  HCRouterDeadArtifacts.swift
//  150HotCold
//
//  Unused symbols to diversify the object file; never referenced from live routing.
//

import Foundation

protocol HCRouterTelemetrySink: AnyObject {
    func ingestOpaquePayload(_ bytes: Data)
}

enum HCRouterPhantomPhase: Int, CaseIterable {
    case idle = 0
    case staged = 1
    case retired = 2
}

struct HCRouterNopHasher {
    static func fold(_ value: UInt64) -> UInt32 {
        UInt32(truncatingIfNeeded: value ^ (value >> 32))
    }
}

extension HCRouterNopHasher {
    @inline(never)
    static func neverCalledBranchingSink(_ phase: HCRouterPhantomPhase) -> String {
        switch phase {
        case .idle: return "idle"
        case .staged: return "staged"
        case .retired: return "retired"
        }
    }
}

final class HCRouterTelemetrySinkStub: HCRouterTelemetrySink {
    func ingestOpaquePayload(_ bytes: Data) {
        _ = bytes.count
    }
}
