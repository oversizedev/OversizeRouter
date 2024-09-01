//
// Copyright © 2024 Alexander Romanov
// Tabable.swift, created on 14.04.2024
//

import SwiftUI

public protocol TabableView: Tabable {
    associatedtype ViewType: View
    func view() -> ViewType
}

public protocol Tabable: CaseIterable, Equatable, Identifiable, Hashable {
    var icon: Image { get }
    var title: String { get }
}

public extension Tabable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        if lhs.id == rhs.id {
            true
        } else {
            false
        }
    }
}
